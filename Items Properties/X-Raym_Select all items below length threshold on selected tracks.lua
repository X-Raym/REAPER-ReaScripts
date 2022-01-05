--[[
 * ReaScript Name: Select all items below length threshold on selected tracks
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
 * v1.0 (2015-11-25)
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

      item_on_track = reaper.CountTrackMediaItems(track)

      if item_on_track > 0 then

        -- INITIALIZE loop through items on track
        for i = 0, item_on_track - 1  do

          -- GET ITEMS
          item = reaper.GetTrackMediaItem(track, i) -- Get selected item i

          item_length = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")

          if item_length < threshold then

            reaper.SetMediaItemSelected(item, true)

          end


        end

        reaper.Undo_EndBlock("Select all items below length threshold on selected tracks", -1) -- End of the undo block. Leave it at the bottom of your main function.

      end -- if item on track

    end -- end loop track
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