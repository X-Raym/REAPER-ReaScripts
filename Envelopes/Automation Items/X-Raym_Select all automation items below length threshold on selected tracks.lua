--[[
 * ReaScript Name: Select all automation items below length threshold on selected tracks
 * About: Use this in a custom action to delete selected items, for eg.
 * Instructions: Select a track. Execute the script.
 * Screenshot: http://i.giphy.com/3o6QKX2WdiZllRt5e0.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Items selection (Various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1600647
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2020-12-08)
  + Initial Release
--]]

function main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  reaper.SelectAllMediaItems(0, false)

  selected_tracks_count = reaper.CountSelectedTracks(0)

  if selected_tracks_count > 0 then

    for l = 0, selected_tracks_count-1  do

      -- GET THE TRACK
      track = reaper.GetSelectedTrack(0, l)

              -- LOOP THROUGH ENVELOPES
          env_count = reaper.CountTrackEnvelopes(track)
          for j = 0, env_count-1 do

            -- GET THE ENVELOPE
            env = reaper.GetTrackEnvelope(track, j)
          br_env = reaper.BR_EnvAlloc(env, false)

          active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, type, faderScaling = reaper.BR_EnvGetProperties(br_env, true, true, true, true, 0, 0, 0, 0, 0, 0, true)

          -- IF ENVELOPE IS A CANDIDATE
          if visible == true and active == true then

             automation_items_count = reaper.CountAutomationItems( env )

             for z = 0, automation_items_count - 1 do

               automation_items_length =  reaper.GetSetAutomationItemInfo( env, z, "D_LENGTH", 0, false )
               if automation_items_length < threshold then
                 reaper.GetSetAutomationItemInfo( env, z, "D_UISEL", 1, true )
               end

              end


          end

          reaper.BR_EnvFree(br_env, 0)

        end -- ENDLOOP through envelopes

    end -- end loop track

    reaper.Undo_EndBlock("Select all automation items below length threshold on selected tracks", -1) -- End of the undo block. Leave it at the bottom of your main function.

  else -- no selected track
    reaper.ShowMessageBox("Select a track before running the script","Please",0)
  end -- ENDIF a track is selected

end -- of main

retval, retvals_csv = reaper.GetUserInputs("Select Items", 1, "Length Threshold (s):", 1)

if retval then -- if user complete the fields

  threshold = retvals_csv

  if threshold ~= nil then

    threshold = math.abs(tonumber(threshold))

    if threshold ~= nil then

      reaper.PreventUIRefresh(1)

      main() -- Execute your main function

      reaper.PreventUIRefresh(-1)

      reaper.UpdateArrange() -- Update the arrangement (often needed)

    end

  end

end