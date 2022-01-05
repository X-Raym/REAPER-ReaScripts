--[[
 * ReaScript Name: Add envelope point on edit cursor position from previous point value
 * Screenshot: https://i.imgur.com/qIqelYP.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Script (LUA): Copy points envelopes in time selection and paste them at edit cursor
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1497832#post1497832
 * REAPER: 5.0 pre 18b
 * Extensions: SWS 2.6.3 #0
 * Version: 1.0.1
--]]

--[[
 * Changelog:
 * v1.0 (2020-10-29)
  + Index fix
 * v1.0 (2020-10-27)
  + Initial release
--]]

function AddPoints(env)
    -- GET THE ENVELOPE
  br_env = reaper.BR_EnvAlloc(env, false)

  active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, type, faderScaling = reaper.BR_EnvGetProperties(br_env, true, true, true, true, 0, 0, 0, 0, 0, 0, true)

  if visible == true and armed == true then

    env_points_count = reaper.CountEnvelopePoints(env)

    if env_points_count > 0 then
      for k = 0, env_points_count+1 do
        reaper.SetEnvelopePoint(env, k, timeInOptional, valueInOptional, shapeInOptional, tensionInOptional, false, true)
      end
    end

    -- IF THERE IS PREVIOUS POINT
    cursor_point = reaper.GetEnvelopePointByTime(env, offset)

    if cursor_point ~= -1 then

      -- GET NEXT POINT VALUE
      retval3, timeOut3, valueOut3, shapeOutOptional3, tensionOutOptional3, selectedOutOptional3 = reaper.GetEnvelopePoint(env, cursor_point)

      -- IF THERE IS A NEXT POINT
      if retval3 == true then
        --reaper.SetEnvelopePoint(env, cursor_point, timeInOptional, valueOut2, shapeInOptional, tensionInOptional, true, false)

        -- SET CURSOR POINT
        reaper.InsertEnvelopePoint(env, offset, valueOut3, 0, 0, true, true)

      end -- ENDIF there is a next point

    end -- ENDIF there is a previous point
  end

  reaper.BR_EnvFree(br_env, 0)
  reaper.Envelope_SortPoints(env)

end

function main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  -- GET CURSOR POS
  offset = reaper.GetCursorPosition()

  -- LOOP TRHOUGH SELECTED TRACKS
  env = reaper.GetSelectedEnvelope(0)

  if env == nil then

    selected_tracks_count = reaper.CountSelectedTracks(0)
    for i = 0, selected_tracks_count-1  do

      -- GET THE TRACK
      track = reaper.GetSelectedTrack(0, i) -- Get selected track i

      -- LOOP THROUGH ENVELOPES
      env_count = reaper.CountTrackEnvelopes(track)
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

  reaper.Undo_EndBlock("Add envelope point on edit cursor position from previous point value", -1) -- End of the undo block. Leave it at the bottom of your main function.

end -- end main()

main() -- Execute your main function

reaper.TrackList_AdjustWindows( false )

reaper.UpdateArrange() -- Update the arrangement (often needed)

