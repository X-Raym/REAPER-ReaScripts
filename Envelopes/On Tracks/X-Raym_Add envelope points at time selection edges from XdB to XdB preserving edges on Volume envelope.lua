--[[
 * ReaScript Name: Add envelope points at time selection edges from XdB to XdB preserving edges on Volume envelope
 * About: Insert points at time selection edges. You can deactivate the pop up window within the script.
 * Instructions: Make a selection area. Execute the script. Works on selected envelope or selected tracks envelope with armed visible envelope.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts (Lua): Multiple Tracks and Multiple Envelope Operations
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1499882
 * REAPER: 5.0
 * Extensions: 2.8.3
 * Version: 1.0.2
--]]

--[[
 * Changelog:
 * v1.0.2 (2025-10-15)
  # Better dB calculation
 * v1.0.1 (2018-04-10)
   # FaderScaling support
 * v1.0 (2016-01-17)
  + Initial release
--]]

--[[
CREDITS:
For Cam Perridge
https://www.youtube.com/user/honestcam
--]]


-- USER CONFIG AREA -----------------------

valueIn = -1 -- number : destination value in dB
prompt = true -- true/false : display a prompt window at script run

------------------- END OF USER CONFIF AREA

function dBFromVal(val) return 20*math.log(val, 10) end
function ValFromdB(dB_val) return 10^(dB_val/20) end

function GetDeleteTimeLoopPoints(envelope, env_point_count, start_time, end_time)
  local set_first_start = 0
  local set_first_end = 0
  for i = 0, env_point_count do
    retval, time, valueOut, shape, tension, selectedOut = reaper.GetEnvelopePoint(envelope,i)

    if start_time == time and set_first_start == 0 then
      set_first_start = 1
      first_start_idx = i
      first_start_val = valueOut
    end
    if end_time == time and set_first_end == 0 then
      set_first_end = 1
      first_end_idx = i
      first_end_val = valueOut
    end
    if set_first_end == 1 and set_first_start == 1 then
      break
    end
  end

  local set_last_start = 0
  local set_last_end = 0
  for i = 0, env_point_count do
    retval, time, valueOut, shape, tension, selectedOut = reaper.GetEnvelopePoint(envelope,env_point_count-1-i)

    if start_time == time and set_last_start == 0 then
      set_last_start = 1
      last_start_idx = env_point_count-1-i
      last_start_val = valueOut
    end
    if end_time == time and set_last_end == 0 then
      set_last_end = 1
      last_end_idx = env_point_count-1-i
      last_end_val = valueOut
    end
    if set_last_start == 1 and set_last_end == 1 then
      break
    end
  end

  if first_start_val == nil then
    retval_start_time, first_start_val, dVdS_start_time, ddVdS_start_time, dddVdS_start_time = reaper.Envelope_Evaluate(envelope, start_time, 0, 0)
  end
  if last_end_val == nil then
    retval_end_time, last_end_val, dVdS_end_time, ddVdS_end_time, dddVdS_end_time = reaper.Envelope_Evaluate(envelope, end_time, 0, 0)
  end

  if last_start_val == nil then
    last_start_val = first_start_val
  end
  if first_end_val == nil then
    first_end_val = last_end_val
  end

  reaper.DeleteEnvelopePointRange(envelope, start_time-0.000000001, end_time+0.000000001)

  return first_start_val, last_start_val, first_end_val, last_end_val

end

function AddPoints(env)
    -- GET THE ENVELOPE
  br_env = reaper.BR_EnvAlloc(env, false)

  active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, type, faderScaling = reaper.BR_EnvGetProperties(br_env, true, true, true, true, 0, 0, 0, 0, 0, 0, true)

  if visible == true and armed == true then

    if faderScaling == true then
      minValue = reaper.ScaleToEnvelopeMode(1, minValue)
      maxValue = reaper.ScaleToEnvelopeMode(1, maxValue)
      centerValue = reaper.ScaleToEnvelopeMode(1, centerValue)
    end

    env_points_count = reaper.CountEnvelopePoints(env)

    if env_points_count > 0 then
      for k = 0, env_points_count+1 do
        reaper.SetEnvelopePoint(env, k, timeInOptional, valueInOptional, shapeInOptional, tensionInOptional, false, true)
      end
    end

    first_start_val, last_start_val, first_end_val, last_end_val = GetDeleteTimeLoopPoints(env, env_points_count, start_time, end_time)


    reaper.InsertEnvelopePoint(env, start_time, first_start_val, 0, 0, true, true) -- INSERT startLoop point

    -- MOD
    if env_scale == 1 then valueIn = reaper.ScaleToEnvelopeMode(1, valueIn) end

    reaper.InsertEnvelopePoint(env, start_time, valueIn, 0, 0, true, true)
    reaper.InsertEnvelopePoint(env, end_time, valueIn, 0, 0, true, true)

    reaper.InsertEnvelopePoint(env, end_time, last_end_val, 0, 0, true, true) -- INSERT startLoop point


    reaper.BR_EnvFree(br_env, 0)
    reaper.Envelope_SortPoints(env)
  end
end

function main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  -- GET CURSOR POS
  offset = reaper.GetCursorPosition()

  -- GET TIME SELECTION EDGES
  start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)

  -- IF TIME SELECTION
  if start_time ~= end_time then

    -- ROUND LOOP TIME SELECTION EDGES
    start_time = math.floor(start_time * 100000000+0.5)/100000000
    end_time = math.floor(end_time * 100000000+0.5)/100000000

    -- LOOP TRHOUGH SELECTED TRACKS
    env = reaper.GetSelectedEnvelope(0)

    if env == nil then

      selected_tracks_count = reaper.CountSelectedTracks(0)
      for i = 0, selected_tracks_count-1  do

        -- GET THE TRACK
        track = reaper.GetSelectedTrack(0, i) -- Get selected track i

        -- LOOP THROUGH ENVELOPES
        env_count = reaper.CountTrackEnvelopes(track)
        for j = 0, env_count-1 do

          -- GET THE ENVELOPE
          env = reaper.GetTrackEnvelope(track, j)

          retval, envName = reaper.GetEnvelopeName(env, "")
          if envName == "Volume" then
            AddPoints(env)
          end

        end -- ENDLOOP through envelopes

      end -- ENDLOOP through selected tracks

    else

      retval, envName = reaper.GetEnvelopeName(env, "")
      if envName == "Volume" then
        AddPoints(env)
      end

    end -- endif sel envelope

    reaper.Undo_EndBlock("Add envelope points at time selection edges from XdB to XdB preserving edges on Volume envelope", -1) -- End of the undo block. Leave it at the bottom of your main function.

  end-- ENDIF time selection

end -- end main()

--------------------
-- INIT

if prompt == true then
  valueIn = tostring(valueIn)
  retval, valueIn = reaper.GetUserInputs("Set Envelope Value", 1, "Value (dB)", valueIn)
end

if retval or prompt == false then -- if user complete the fields

  valueIn = tonumber(valueIn)

  if valueIn ~= nil then

  if valueIn > 12 then valueIn = 12 end
    valueIn = ValFromdB(valueIn)
  if valueIn < 0 then valueIn = 0 end

    reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

    main() -- Execute your main function

    reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

    reaper.UpdateArrange() -- Update the arrangement (often needed)

    reaper.TrackList_AdjustWindows( false )

  end

end
