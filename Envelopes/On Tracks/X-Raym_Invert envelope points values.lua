--[[
 * ReaScript Name: Invert envelope points values
 * About: A way to invert envelope points value across tracks. Volume track is based on 0db.
 * Instructions: Select tracks with visible and armed envelopes. Execute the script.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Script (LUA): Copy points envelopes in time selection and paste them at edit cursor
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1497832#post1497832
 * REAPER: 5.0 pre 18b
 * Extensions: SWS 2.6.3 #0
 * Version: 1.4.2
--]]

--[[
 * Changelog:
 * v1.4.2 (2026-06-04)
  # Localize envelope name
 * v1.4.1 (2025-10-15)
  # Better dB calculation
 * v1.4 (2015-09-09)
  + Fader scaling support
 * v1.3 (2015-07-11)
  + Send support
 * v1.2 (2015-06-25)
  # Dual pan track support
 * v1.1 (2015-05-07)
  # Time selection bug fix
 * v1.1 (2015-03-21)
  + Selected envelope overides armed and visible envelope on selected tracks
  + Facultative time selection
 * v1.0 (2015-03-19)
  + Initial release
--]]


-- ----- CONFIG ====>

preserve_edges = false -- True will insert points à time selection edges before the action.

local env_db_scale = {}
env_db_scale["Volume"] = true
env_db_scale["Volume (Pre-FX)"] = true
env_db_scale["Send Volume"] = true
env_db_scale["Trim Volume"] = true

local env_no_mulitply = {}
env_no_mulitply["Mute"] = true
env_no_mulitply["Send Mute"] = true
env_no_mulitply["Pitch"] = true
env_no_mulitply["Tempo map"] = true

local env_multiply = {}
env_multiply["Width"] = -1
env_multiply["Width (Pre-FX)"] = -1
env_multiply["Pan"] = -1
env_multiply["Pan (Pre-FX)"] = -1
env_multiply["Pan (Left)"] = -1
env_multiply["Pan (Right)"] = -1
env_multiply["Pan (Left, Pre-FX)"] = -1
env_multiply["Pan (Right, Pre-FX)"] = -1
env_multiply["Send Pan"] = -1
env_multiply["Playrate"] = 100 -- TODO: work with playrate env

function LocalizeEnvTableNameS( t )
  for env_name, val in pairs( t ) do
    t[ reaper.LocalizeString( env_name, "envname") ] = val
  end
end

LocalizeEnvTableNameS( env_db_scale )
LocalizeEnvTableNameS( env_no_mulitply )
LocalizeEnvTableNameS( env_multiply )

-- <==== CONFIG -----

function dBFromVal(val) return 20*math.log(val, 10) end
function ValFromdB(dB_val) return 10^(dB_val/20) end

function SetAtTimeSelection(env, k, point_time, value, shape, tension)

  if time_selection == true then

    if point_time > start_time and point_time < end_time then
      reaper.SetEnvelopePoint(env, k, point_time, valueIn, shape, tension, true, true)
    end

  else
    reaper.SetEnvelopePoint(env, k, point_time, valueIn, shape, tension, false, true)
  end

end

function Action(env)

  -- PRESERVE EDGES EVALUATION
  if time_selection == true and preserve_edges == true then -- IF we want to preserve edges of time selection

    retval3, valueOut3, dVdSOutOptional3, ddVdSOutOptional3, dddVdSOutOptional3 = reaper.Envelope_Evaluate(env, start_time, 0, 0)
    retval4, valueOut4, dVdSOutOptional4, ddVdSOutOptional4, dddVdSOutOptional4 = reaper.Envelope_Evaluate(env, end_time, 0, 0)

  end -- preserve edges of time selection

  -- GET THE ENVELOPE
  retval, env_name = reaper.GetEnvelopeName(env, "envelopeName")
  br_env = reaper.BR_EnvAlloc(env, false)

  active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, type, faderScaling = reaper.BR_EnvGetProperties(br_env, true, true, true, true, 0, 0, 0, 0, 0, 0, true)

  -- IF ENVELOPE IS A CANDIDATE
  if visible == true and armed == true then

    -- LOOP THROUGH POINTS
    env_points_count = reaper.CountEnvelopePoints(env)

    if env_points_count > 0 then
      for k = 0, env_points_count-1 do
        retval, point_time, valueOut, shapeOutOptional, tensionOutOptional, selectedOutOptional = reaper.GetEnvelopePoint(env, k)

        if faderScaling == true then valueOut = reaper.ScaleFromEnvelopeMode(1, valueOut) end

        -- BEGIN ACTION
        valueIn = -(valueOut-1)

        if env_db_scale[ env_name ] then

          -- CALC
          OldVolDB = 20*(math.log(valueOut, 10)) -- thanks to spk77!

          calc = -OldVolDB -- it invert volume based on 0db

          valueIn = ValFromdB(calc)

          if valueIn >= 2 then
            valueIn = 2
          end

        end -- ENDIF Volume

        if faderScaling == true then valueIn = reaper.ScaleToEnvelopeMode(1, valueIn) end

        if env_multiply[ env_name ] then

          valueIn = -valueOut

        end -- ENDIF Pan or Width

        -- END ACTION

        SetAtTimeSelection(env, k, point_time, valueIn, shapeInOptional, tensionInOptional)

      end
    end

    -- PRESERVE EDGES INSERTION
    if time_selection == true and preserve_edges == true then

      reaper.DeleteEnvelopePointRange(env, start_time-0.000000001, start_time+0.000000001)
      reaper.DeleteEnvelopePointRange(env, end_time-0.000000001, end_time+0.000000001)

      reaper.InsertEnvelopePoint(env, start_time, valueOut3, 0, 0, true, true) -- INSERT startLoop point
      reaper.InsertEnvelopePoint(env, end_time, valueOut4, 0, 0, true, true) -- INSERT startLoop point

    end

    reaper.BR_EnvFree(br_env, 0)
    reaper.Envelope_SortPoints(env)

  end

end

function main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  -- GET CURSOR POS
  offset = reaper.GetCursorPosition()

  start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)

  if start_time ~= end_time then
    time_selection = true
  end

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

        Action(env)

      end -- ENDLOOP through envelopes

    end -- ENDLOOP through selected tracks

  else

    Action(env)

  end -- endif sel envelope

  reaper.Undo_EndBlock("Invert envelope points values", -1) -- End of the undo block. Leave it at the bottom of your main function.

end -- end main()



reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

reaper.PreventUIRefresh(-1)  -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)



-- Update the TCP envelope value at edit cursor position
reaper.TrackList_AdjustWindows( false )