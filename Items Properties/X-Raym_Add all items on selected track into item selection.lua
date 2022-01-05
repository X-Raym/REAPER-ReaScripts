--[[
 * ReaScript Name: Add all items on selected track into item selection
 * About: Add all items on selected track into item selection
 * Instructions: Select tracks. Use it.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: ReaScript: Select all items on selected tracks
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1489411
 * Version: 1.0
 * Version Date: 2015-02-27
 * REAPER: 5.0 pre 11
--]]

--[[
 * Changelog:
 * v1.1 (2015-03-05)
  + Rename
 * v1.0 (2015-02-27)
  + Initial Release
--]]

function selected_items_on_tracks()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  -- LOOP TRHOUGH SELECTED TRACKS

  selected_tracks_count = reaper.CountSelectedTracks(0)

  for i = 0, selected_tracks_count-1  do
    -- GET THE TRACK
    track_sel = reaper.GetSelectedTrack(0, i) -- Get selected track i

    item_num = reaper.CountTrackMediaItems(track_sel)

    -- ACTIONS
    for j = 0, item_num-1 do
      item = reaper.GetTrackMediaItem(track_sel, j)
      reaper.SetMediaItemSelected(item, 1)
    end

  end -- ENDLOOP through selected tracks


  reaper.Undo_EndBlock("Select all items on selected tracks", 0) -- End of the undo block. Leave it at the bottom of your main function.

end



selected_items_on_tracks() -- Execute your main function

reaper.UpdateArrange() -- Update the arrangement (often needed)


