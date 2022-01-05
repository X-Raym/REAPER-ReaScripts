--[[
 * ReaScript Name: Expand first selected item per track to end of last selected ones and delete inbetween ones
 * About: Expand first selected item per track to end of last selected ones and delete inbetween ones
 * Instructions: Here is how to use it. (optional)
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Editing (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1538604
 * REAPER: 5.0 pre 15
 * Extensions: SWS/S&M 2.7.1 (optional)
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2015-25-06)
  + Initial Release
--]]


function main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  UnselectAllTracks()

  -- LOOP THROUGH SELECTED ITEMS
  selected_items_count = reaper.CountSelectedMediaItems(0)

  -- INITIALIZE loop through selected items
  -- Select tracks with selected items
  for i = 0, selected_items_count - 1  do
    -- GET ITEMS
    item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i

    -- GET ITEM PARENT TRACK AND SELECT IT
    track = reaper.GetMediaItem_Track(item)
    reaper.SetTrackSelected(track, true)

  end -- ENDLOOP through selected items


  -- LOOP TRHOUGH SELECTED TRACKS
  for i = 0, reaper.CountSelectedTracks(0) - 1  do
    -- GET THE TRACK
    track = reaper.GetSelectedTrack(0, i) -- Get selected track i

    count_items_on_track = reaper.CountTrackMediaItems(track)

    -- REINITILIAZE THE TABLE
    item_to_delete = {}
    sel_items_on_tracks_end = 0
    first = false

    -- LOOP THROUGH ITEMS ON TRACKS AND STORE SELECTED ITEMS (for later moving) AND OFFSET
    for j = 0, count_items_on_track - 1  do

      item = reaper.GetTrackMediaItem(track, j)

      if reaper.IsMediaItemSelected(item) == true then

        if first == false then

          first_sel_item = item
          first = true

        end

        -- CHECK IF IT ITEM END IS AFTER PREVIOUS ITEM ENDS
        item_on_tracks_end = reaper.GetMediaItemInfo_Value(item, "D_POSITION") + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")

        if item_on_tracks_end > sel_items_on_tracks_end then

          sel_items_on_tracks_end = item_on_tracks_end

        end

        table.insert(item_to_delete, item)

      end

    end

    for k = 2, #item_to_delete do

      reaper.DeleteTrackMediaItem(track, item_to_delete[k])

    end

    first_sel_item_pos = reaper.GetMediaItemInfo_Value(first_sel_item, "D_POSITION")

    reaper.BR_SetItemEdges(first_sel_item, first_sel_item_pos, sel_items_on_tracks_end)

  end -- ENDLOOP through selected tracks

  reaper.Undo_EndBlock("Expand first selected item per track to end of last selected ones and delete inbetween ones", -1) -- End of the undo block. Leave it at the bottom of your main function.

end


--[[ ----- INITIAL SAVE AND RESTORE ====> ]]

-- TRACKS
-- UNSELECT ALL TRACKS
function UnselectAllTracks()
  first_track = reaper.GetTrack(0, 0)
  reaper.SetOnlyTrackSelected(first_track)
  reaper.SetTrackSelected(first_track, false)
end

-- SAVE INITIAL TRACKS SELECTION
init_sel_tracks = {}
local function SaveSelectedTracks (table)
  for i = 0, reaper.CountSelectedTracks(0)-1 do
    table[i+1] = reaper.GetSelectedTrack(0, i)
  end
end

-- RESTORE INITIAL TRACKS SELECTION
local function RestoreSelectedTracks (table)
  UnselectAllTracks()
  for _, track in ipairs(table) do
    reaper.SetTrackSelected(track, true)
  end
end

--[[ <==== INITIAL SAVE AND RESTORE ----- ]]

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

SaveSelectedTracks(init_sel_tracks)

main() -- Execute your main function

RestoreSelectedTracks(init_sel_tracks)

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)


