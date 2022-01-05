--[[
 * ReaScript Name: Copy visible armed envelope points in time selection of last touched track and insert in selected tracks
 * About: A way to copy paste envelope sections across tracks.
 * Instructions: Make a track selection. Touch a track. Have sure you have source and destination envelope armed and visible. It will copy point from source to destination if envelope name match. It will preserve value at time selection edges.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Script (LUA): Copy points envelopes in time selection and paste them at edit cursor
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1497832#post1497832
 * REAPER: 5.0 pre 18b
 * Version: 1.0.1
--]]

--[[
 * Changelog:
 * v1.0.1 (2015-05-07)
  # Time selection bug fix
 * v1.0 (2015-03-18)
  + Initial release
  + Redraw envelope value at cursor pos in TCP (thanks to HeDa!)
--]]

-- INIT
time = {}
valueSource = {}
shape = {}
tension = {}
selectedOut = {}

function main()

  -- GET AND UNSELECT LAST TRACK
  last_track = reaper.GetLastTouchedTrack()
  if reaper.IsTrackSelected(last_track) == true then
    reaper.SetTrackSelected(last_track, false)
    restore_sel = true
  end -- ENFIF last track is selected

  startLoop, endLoop = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  -- LOOP THROUGH LAST TOUCHED TRACK ENVELOPES
  env_count = reaper.CountTrackEnvelopes(last_track)
  for j = 0, env_count-1 do

    -- GET THE ENVELOPE
    env = reaper.GetTrackEnvelope(last_track, j)
    retval, env_name = reaper.GetEnvelopeName(env, "")

    -- IF VISIBLE AND ARMED
    retval, strNeedBig = reaper.GetEnvelopeStateChunk(env, "", true)
    x, y = string.find(strNeedBig, "VIS 1")
    w, z = string.find(strNeedBig, "ARM 1")

    if x ~= nil and w ~= nil then

      -- SAVE LAST TOUCHED TRACK ENVELOPES POINTS
      env_points_count = reaper.CountEnvelopePoints(env)

      if env_points_count > 0 then

        -- LOOP THROUGH POINTS
        for k = 0, env_points_count-1 do

          retval, time[k], valueSource[k], shape[k], tension[k], selectedOut[k] = reaper.GetEnvelopePoint(env, k)

        end -- ENDIF points on the envelope

      end -- ENDIF there was envelope envelope point

      -- LOOP TRHOUGH SELECTED TRACKS
      selected_tracks_count = reaper.CountSelectedTracks(0)
      for i = 0, selected_tracks_count-1  do

        -- GET THE TRACK
        track = reaper.GetSelectedTrack(0, i) -- Get selected track i

        env_count = reaper.CountTrackEnvelopes(track)
        for m = 0, env_count-1 do

          -- GET THE ENVELOPE
          env_dest = reaper.GetTrackEnvelope(track, m)
          retval, env_name_dest = reaper.GetEnvelopeName(env_dest, "")

          -- IF VISIBLE AND ARMED
          retval, strNeedBig_dest = reaper.GetEnvelopeStateChunk(env_dest, "", true)
          a, c = string.find(strNeedBig_dest, "VIS 1")
          b, d = string.find(strNeedBig_dest, "ARM 1")

          if a ~= nil and b ~= nil and env_name_dest == env_name then

            -- UNSELECT POINTS ON TRACK
            env_points_count = reaper.CountEnvelopePoints(env)

            if env_points_count > 0 then
              for t = 0, env_points_count-1 do
                reaper.SetEnvelopePoint(env, t, timeInOptional, valueInOptional, shapeInOptional, tensionInOptional, false, true)
              end
            end

            retval3, valueOut3, dVdSOutOptional3, ddVdSOutOptional3, dddVdSOutOptional3 = reaper.Envelope_Evaluate(env_dest, startLoop, 0, 0)
            retval4, valueOut4, dVdSOutOptional4, ddVdSOutOptional4, dddVdSOutOptional4 = reaper.Envelope_Evaluate(env_dest, endLoop, 0, 0)

            reaper.DeleteEnvelopePointRange(env_dest, startLoop, endLoop)

            retval, valueOut, dVdSOutOptional, ddVdSOutOptional, dddVdSOutOptional = reaper.Envelope_Evaluate(env, startLoop, 0, 0)
            retval2, valueOut2, dVdSOutOptional2, ddVdSOutOptional2, dddVdSOutOptional2 = reaper.Envelope_Evaluate(env, endLoop, 0, 0)

            -- ADD POINTS ON LOOP START AND END
            reaper.InsertEnvelopePoint(env_dest, startLoop, valueOut3, 0, 0, true, true) -- INSERT startLoop point
            reaper.InsertEnvelopePoint(env_dest, startLoop, valueOut, 0, 0, true, true) -- INSERT startLoop point
            reaper.InsertEnvelopePoint(env_dest, endLoop, valueOut2, 0, 0, true, true) -- INSERT startLoop point
            reaper.InsertEnvelopePoint(env_dest, endLoop, valueOut4, 0, 0, true, true) -- INSERT startLoop point

            for p = 0, env_points_count-1 do

              if time[p] >= startLoop and time[p] <= endLoop then

                reaper.InsertEnvelopePoint(env_dest, time[p], valueSource[p], shape[p], tension[p], true, true)

              end

            end -- END LOOP THROUGH SAVED POINTS

          end -- ENDIF envelope passed

          reaper.Envelope_SortPoints(env_dest)

        end -- ENDLOOP selected tracks envelope

      end -- ENDLOOP selected tracks

    end -- ENFIF visible

  end -- ENDLOOP through envelopes

  -- RESTORE LAST TRACK SELECTION
  if restore_sel == true then
    reaper.SetTrackSelected(last_track, true)
  end

  reaper.Undo_EndBlock("Copy visible armed envelope points in time selection of last touched track and paste to selected tracks", 0) -- End of the undo block. Leave it at the bottom of your main function.

end -- end main()



reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)



-- BEWARE OF CTRL+Z as last touched track will Changelog

-- Update the TCP envelope value at edit cursor position
reaper.TrackList_AdjustWindows( false )