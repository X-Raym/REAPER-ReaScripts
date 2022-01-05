--[[
 * ReaScript Name: Reset envelope with value at edit cursor
 * About: A way to reset multiple envelopes according to value at edit carsor.
 * Instructions: Select tracks with visible and armed envelopes. Execute the script. Note that if there is an envelope selected, it will work only for it.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts (Lua): Multiple Tracks and Multiple Envelope Operations
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=157483
 * REAPER: 5.0 RC5
 * Extensions: SWS 2.7.3 #0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2015-07-20)
  + Initial release
--]]

-- ------ USER CONFIG AREA =====>
-- here you can customize the script
-- Envelope Output Properties
active_out = true -- true or false
visible_out = true -- true or false. If active_out is false, then set visible to false too.
armed_out = true -- true or false
-- <===== USER CONFIG AREA ------

function Msg(val)
  reaper.ShowConsoleMsg(tostring(val).."\n")
end

function Action(env)

  -- GET THE ENVELOPE
  br_env = reaper.BR_EnvAlloc(env, false)

  active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, type, faderScaling = reaper.BR_EnvGetProperties(br_env, true, true, true, true, 0, 0, 0, 0, 0, 0, true)

  -- IF ENVELOPE IS A CANDIDATE
  if visible == true and armed == true then

    -- OUTPUT VALUE ANALYSIS
    retval_eval, value_eval, dVdSOut_eval, ddVdSOut_eval, dddVdSOut_eval = reaper.Envelope_Evaluate(env, edit_pos, 0, 0)

    -- GET LAST POINT TIME OF DEST TRACKS AND DELETE ALL
    env_points_count = reaper.CountEnvelopePoints(env)
    if env_points_count > 1 then

      retval, point_time, point_value, point_shape, point_tension, point_selected = reaper.GetEnvelopePoint(env, 0)

      for p = 0, env_points_count-2 do

        reaper.BR_EnvDeletePoint(br_env, (env_points_count-1-p))

      end

    end

    reaper.BR_EnvSetPoint(br_env, 0, 0, value_eval, 0, false, 0)
    --reaper.BR_EnvSetProperties(BR_Envelope envelope, boolean active, boolean visible, boolean armed, boolean inLane, integer laneHeight, integer defaultShape, boolean faderScaling)
    -- reaper.BR_EnvSetProperties(br_env, false, false, true, true, laneHeight, defaultShape, faderScaling)
    reaper.BR_EnvSetProperties(br_env, active_out, visible_out, armed_out, inLane, laneHeight, defaultShape, faderScaling)

  end

  reaper.BR_EnvFree(br_env, 1)
  reaper.Envelope_SortPoints(env)

end

function main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  edit_pos = reaper.GetCursorPosition()

  -- LOOP TRHOUGH SELECTED TRACKS
  env = reaper.GetSelectedEnvelope(0)

  if env == nil then

    selected_tracks_count = reaper.CountSelectedTracks(0)

    -- if selected_tracks_count > 0 and UserInput() then
    if selected_tracks_count > 0 then
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

    -- if UserInput() then
      Action(env)
    -- end

  end -- endif sel envelope

  reaper.Undo_EndBlock("Reset envelope with value at edit cursor", -1) -- End of the undo block. Leave it at the bottom of your main function.

end -- end main()



reaper.PreventUIRefresh(1)-- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)
