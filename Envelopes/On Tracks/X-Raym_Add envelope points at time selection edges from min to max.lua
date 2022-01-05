--[[
 * ReaScript Name: Add envelope points at time selection edges from min to max
 * About: Insert points at time selection edges.
 * Instructions: Make a selection area. Execute the script. Works on selected envelope or selected tracks envelope with armed visible envelope.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Script (LUA): Copy points envelopes in time selection and paste them at edit cursor
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1497832#post1497832
 * REAPER: 5.0 pre 18b
 * Extensions: 2.6.3 #0
 * Version: 1.1.2
--]]

--[[
 * Changelog:
 * v1.1.2 (2018-04-10)
   # FaderScaling support
 * v1.1.1 (2015-05-07)
  # Time selection bug fix
 * v1.1 (2015-03-23)
  + Clean inside area
 * v1.0 (2015-03-21)
  + Initial release
--]]

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

    retval, valueOut, dVdSOutOptional, ddVdSOutOptional, dddVdSOutOptional = reaper.Envelope_Evaluate(env, start_time, 0, 0)
    retval2, valueOut2, dVdSOutOptional2, ddVdSOutOptional2, dddVdSOutOptional2 = reaper.Envelope_Evaluate(env, end_time, 0, 0)

    reaper.DeleteEnvelopePointRange(env, start_time-0.000000001, end_time+0.000000001)

    -- ADD POINTS ON LOOP START AND END
    --reaper.InsertEnvelopePoint(env, start_time, valueOut, 0, 0, 1, 0)
    reaper.InsertEnvelopePoint(env, start_time, minValue, 0, 0, true, true)
    reaper.InsertEnvelopePoint(env, end_time, maxValue, 0, 0, true, true)
    --reaper.InsertEnvelopePoint(env, end_time, valueOut2, 0, 0, 1, 0)

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

          AddPoints(env)

        end -- ENDLOOP through envelopes

      end -- ENDLOOP through selected tracks

    else

      AddPoints(env)

    end -- endif sel envelope

  reaper.Undo_EndBlock("Add envelope points at time selection edges from min to max", 0) -- End of the undo block. Leave it at the bottom of your main function.

  end-- ENDIF time selection

end -- end main()




main() -- Execute your main function


reaper.UpdateArrange() -- Update the arrangement (often needed)



-- Update the TCP envelope value at edit cursor position
reaper.TrackList_AdjustWindows( false )
