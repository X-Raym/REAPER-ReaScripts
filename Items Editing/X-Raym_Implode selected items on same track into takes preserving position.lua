--[[
 * ReaScript Name: Implode selected items on same track into takes preserving position
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Screenshot: https://i.imgur.com/NCQM0YA.gifv
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Editing (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1538604
 * REAPER: 5.0
 * Version: 1.0.1
--]]

--[[
 * Changelog:
 * v1.0.1 (2020-04-10)
  + Auto fade
 * v1.0 (2020-04-09)
  + Initial Release
--]]

-- Note: Maybe not using the Loop section action would be intersting.

function main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  -- LOOP THROUGH SELECTED ITEMS
  selected_items_count = reaper.CountSelectedMediaItems(0)

  tracks = {}
  -- INITIALIZE loop through selected items
  -- Select tracks with selected items
  for i = 0, selected_items_count - 1  do
    -- GET ITEMS
    item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i

    -- GET ITEM PARENT TRACK AND SELECT IT
    track = reaper.GetMediaItem_Track(item)

    track_GUID = reaper.GetTrackGUID( track )

    tracks[track_GUID] = track

  end -- ENDLOOP through selected items

  reaper.Main_OnCommand(40547, 0) -- Item properties: Loop section of audio item source

  -- LOOP TRHOUGH SELECTED TRACKS
  for k,track in pairs( tracks )  do

    count_items_on_track = reaper.CountTrackMediaItems(track)

    -- REINITILIAZE THE TABLE
    item_to_delete = {}
    sel_items_on_tracks_end = 0

    min_pos = nil
    max_end = nil

    for j = 0, count_items_on_track - 1  do

      item = reaper.GetTrackMediaItem(track, j)

      item_pos  = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
      item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
      item_end = item_pos + item_len

      if not min_pos then min_pos = item_pos else min_pos = math.min( min_pos, item_pos ) end
      if not max_end then max_end = item_end else max_end = math.max( max_end, item_end ) end

    end


    -- LOOP THROUGH ITEMS ON TRACKS AND STORE SELECTED ITEMS (for later moving) AND OFFSET
    for j = 0, count_items_on_track - 1  do

      item = reaper.GetTrackMediaItem(track, j)

      if reaper.IsMediaItemSelected(item) then

        -- CHECK IF IT ITEM END IS AFTER PREVIOUS ITEM ENDS
        item_on_tracks_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
        item_on_tracks_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
        item_on_tracks_end = item_on_tracks_pos + item_on_tracks_len

        take = reaper.GetActiveTake( item )

        reaper.BR_SetItemEdges(item, min_pos, max_end)

      end

    end

  end -- ENDLOOP through selected tracks

  reaper.Main_OnCommand(40543,0 ) -- Take: Implode items on same track into takes

  reaper.Undo_EndBlock("Expand first selected item per track to end of last selected ones and delete inbetween ones", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

--[[ <==== INITIAL SAVE AND RESTORE ----- ]]

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

auto_fade = reaper.GetToggleCommandState( 40041 )

reaper.Main_OnCommand( 41119, 0 ) -- Options: Disable auto-crossfades

grouping = reaper.GetToggleCommandState( 1156 ) -- Options: Toggle item grouping override
if grouping == 1 then
  reaper.Main_OnCommand( 1156, 0 ) -- Options: Toggle item grouping override
end

main() -- Execute your main function

if grouping == 1 then
  reaper.Main_OnCommand( 1156, 0 ) -- Options: Toggle item grouping override
end

if auto_fade == 1 then
  reaper.Main_OnCommand( 41118, 0 ) -- Options: Enable auto-crossfades
end

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)
