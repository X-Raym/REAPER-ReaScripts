--[[
 * ReaScript Name: Add envelope points at regular interval and set all points to linear
 * About: A way to delete multiple points across different envelopes and tracks.
 * Instructions: Make a selection area or no. Select track with visible armed envelope or no. Execute the script.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Script (LUA): Scripts (Lua): Multiple Tracks and Multiple Envelope Operations
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=157483
 * REAPER: 5.0 RC5
 * Extensions: SWS 2.7.3 #0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2015-07-25)
  + Initial release
--]]

-- ----- CONFIG =====>

preserve_edges = true
interval = 0.1

-- <===== CONFIG -----


function UserInput()
  retval, user_input_str = reaper.GetUserInputs("Replace with Linear Points", 1, "Interval ? (s)", interval) -- We suppose that the user know the scale he want
    if retval then
    interval = tonumber(user_input_str)
  end
  return retval
end

function DeleteAtTimeSelection()

  if time_selection == true then

    if point_time > start_time and point_time < end_time then
      reaper.DeleteEnvelopePointRange(env, start_time, end_time)
    end

  else
    retval_last, time_last, valueSource_last, shape_last, tension_last, selectedOut_last = reaper.GetEnvelopePoint(env, env_points_count-1)
    reaper.DeleteEnvelopePointRange(env, 0, time_last+1)
  end

end

function Action(env)

  -- PRESERVE EDGES EVALUATION
  if time_selection == true and preserve_edges == true then -- IF we want to preserve edges of time selection

    retval3, valueOut3, dVdSOutOptional3, ddVdSOutOptional3, dddVdSOutOptional3 = reaper.Envelope_Evaluate(env, start_time, 0, 0)
    retval4, valueOut4, dVdSOutOptional4, ddVdSOutOptional4, dddVdSOutOptional4 = reaper.Envelope_Evaluate(env, end_time, 0, 0)

  end -- preserve edges of time selection

  -- GET THE ENVELOPE
  retval, envelopeName = reaper.GetEnvelopeName(env, "envelopeName")
  br_env = reaper.BR_EnvAlloc(env, false)

  active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, type, faderScaling = reaper.BR_EnvGetProperties(br_env, true, true, true, true, 0, 0, 0, 0, 0, 0, true)

  -- IF ENVELOPE IS A CANDIDATE
  if visible == true and armed == true then

    -- LOOP THROUGH POINTS
    env_points_count = reaper.CountEnvelopePoints(env)

    -- IF THERE IS MORE THAN POINT (aka, if there is something to analyse)
    if env_points_count > 1 then

      -- EVAL
      -- get last point aka get envelope limit
      retval_last, time_last, valueSource_last, shape_last, tension_last, selectedOut_last = reaper.GetEnvelopePoint(env, env_points_count-1)

      if time_selection == true then
        iterations  = math.ceil((end_time - start_time) / interval)
      else
        iterations = math.ceil(time_last / interval)
      end

      value_eval = {} -- init table

      for m = 1, iterations do

        retval_eval, value_eval[m], dVdSOut_eval, ddVdSOut_eval, dddVdSOut_eval = reaper.Envelope_Evaluate(env, m * interval + start_time, 0, 0)

      end

      -- DELETE AREA
      if env_points_count > 0 then
        for k = 0, env_points_count-1 do
          retval, point_time, valueOut, shapeOutOptional, tensionOutOptional, selectedOutOptional = reaper.GetEnvelopePoint(env, k)

          reaper.SetEnvelopePoint(env, k, point_time, valueOut, 0, 0, 1, true)
          --DeleteAtTimeSelection()

        end
      end

      -- INSERTION
      for m = 1, iterations do

        reaper.InsertEnvelopePoint(env, m * interval + start_time, value_eval[m], 0, 0, true, true) -- INSERT startLoop point

      end

      -- PRESERVE EDGES INSERTION
      if time_selection == true and preserve_edges == true then

        --reaper.DeleteEnvelopePointRange(env, start_time-0.000000001, start_time+0.000000001)
        --reaper.DeleteEnvelopePointRange(env, end_time-0.000000001, end_time+0.000000001)

        reaper.InsertEnvelopePoint(env, start_time, valueOut3, 0, 0, true, true) -- INSERT startLoop point
        reaper.InsertEnvelopePoint(env, end_time, valueOut4, 0, 0, true, true) -- INSERT startLoop point

      end

    end

    reaper.BR_EnvFree(br_env, 0)
    reaper.Envelope_SortPoints(env)

  end

end

function main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  -- GET CURSOR POS
  offset = reaper.GetCursorPosition()

  -- GET TIME SELECTION
  start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)

  -- IF TIME SELECTION
  if start_time ~= end_time then
    time_selection = true
  end

  -- LOOP TRHOUGH SELECTED TRACKS
  env = reaper.GetSelectedEnvelope(0)

  if env == nil then

    selected_tracks_count = reaper.CountSelectedTracks(0)

    if selected_tracks_count > 0 and UserInput() then

      for i = 0, selected_tracks_count-1  do

        -- GET THE TRACK
        track = reaper.GetSelectedTrack(0, i) -- Get selected track i

        -- LOOP THROUGH ENVELOPES
        env_count = reaper.CountTrackEnvelopes(track)
        for j = 0, env_count-1 do

          -- GET THE ENVELOPE
          env = reaper.GetTrackEnvelope(track, j)

          Action(env)

        end -- ENDLOOP through envelopes

      end -- ENDLOOP through selected tracks

    end

  else

    if UserInput() then
      Action(env)
    end

  end -- endif sel envelope

  reaper.Undo_EndBlock("Add envelope points at regular interval and set all points to linear", -1) -- End of the undo block. Leave it at the bottom of your main function.

end -- end main()



reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)


-- Update the TCP envelope value at edit cursor position
reaper.TrackList_AdjustWindows( false )