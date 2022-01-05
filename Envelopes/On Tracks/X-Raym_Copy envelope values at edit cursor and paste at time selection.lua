--[[
 * ReaScript Name: Copy visible armed envelope values at edit cursor and insert at time selection
 * About: A way to copy paste multiple points envelope from the same track. Preserve original time selected envelope area, and value at destination area edges. In only works with visible armed tracks.
 * Instructions: Make a selection area. Place the edit cursor somewhere. Execute the script.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Script (LUA): Copy points envelopes in time selection and paste them at edit cursor
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1497832#post1497832
 * Version: 1.1
 * Version Date: 2015-03-21
 * REAPER: 5.0 pre 18b
 * Extensions: SWS 2.6.3 #0
--]]

--[[
 * Changelog:
 * v1.1.1 (2015-05-07)
  # Time selection bug fix
 * v1.1 (2015-03-21)
  + Selected envelope overides armed and visible envelope on selected tracks
 * v1.0 (2015-03-18)
  + Initial release
  + Redraw envelope value at cursor pos in TCP (thanks to HeDa!)
--]]

function Actions(env)
    -- GET THE ENVELOPE
  br_env = reaper.BR_EnvAlloc(env, false)

  active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, type, faderScaling = reaper.BR_EnvGetProperties(br_env, true, true, true, true, 0, 0, 0, 0, 0, 0, true)

  if visible == true and armed == true then

    retval, valueOut, dVdSOutOptional, ddVdSOutOptional, dddVdSOutOptional = reaper.Envelope_Evaluate(env, offset, 0, 0)

    env_points_count = reaper.CountEnvelopePoints(env)

    if env_points_count > 0 then
      for k = 0, env_points_count+1 do
        reaper.SetEnvelopePoint(env, k, timeInOptional, valueInOptional, shapeInOptional, tensionInOptional, false, true)
      end
    end

    retval, valueOut, dVdSOutOptional, ddVdSOutOptional, dddVdSOutOptional = reaper.Envelope_Evaluate(env, offset, 0, 0)
    --retval2, valueOut2, dVdSOutOptional2, ddVdSOutOptional2, dddVdSOutOptional2 = reaper.Envelope_Evaluate(env, start_time, 0, 0)
    --retval3, valueOut3, dVdSOutOptional3, ddVdSOutOptional3, dddVdSOutOptional3 = reaper.Envelope_Evaluate(env, end_time, 0, 0)

    reaper.DeleteEnvelopePointRange(env, start_time, end_time)

    -- ADD POINTS ON LOOP START AND END
    reaper.InsertEnvelopePoint(env, offset, valueOut, 0, 0, true, true) -- INSERT startLoop point
    --reaper.InsertEnvelopePoint(env, start_time, valueOut2, 0, 0, true, true) -- INSERT startLoop point
    reaper.InsertEnvelopePoint(env, start_time, valueOut, 0, 0, true, true) -- INSERT startLoop point
    reaper.InsertEnvelopePoint(env, end_time, valueOut, 0, 0, true, true) -- INSERT startLoop points
    --reaper.InsertEnvelopePoint(env, end_time, valueOut3, 0, 0, true, true) -- INSERT startLoop points

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

          Actions(env)

        end -- ENDLOOP through envelopes

      end -- ENDLOOP through selected tracks

    else

      Actions(env)

    end -- endif sel envelope

    reaper.Undo_EndBlock("Copy envelope values at edit cursor and paste at time selection", 0) -- End of the undo block. Leave it at the bottom of your main function.

  end-- ENDIF time selection

end -- end main()




main() -- Execute your main function


reaper.UpdateArrange() -- Update the arrangement (often needed)



-- Update the TCP envelope value at edit cursor position
reaper.TrackList_AdjustWindows( false )
