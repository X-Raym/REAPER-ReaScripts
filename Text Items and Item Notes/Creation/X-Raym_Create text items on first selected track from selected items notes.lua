--[[
 * ReaScript Name: Create text items on first selected track from selected items notes
 * About: Create text items on first selected track from selected items notes
 * Instructions:  Select items. Select a destination track. Execute the script. Text items will be colored depending on original take color, or track color from item if no take color is set. The text note will came from the original take name.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Script: Scripts (LUA): Create Text Items Actions (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=156763
 * REAPER: 5.0
 * Extensions: SWS/S&M 2.8.3
 * Version: 1.4
--]]

--[[
 * Changelog:
 * v1.4 (2016-01-22)
  # Better item creation
 * v1.3 (2015-07-29)
  # Better Set notes
 * v1.2 (2015-05-08)
  # Better view restoration
 * v1.1.1 (2015-03-11)
  # Better item selection restoration
  # First selected track as last touched
 * v1.1. (2015-03-06)
  + Multiple lines support
  + Dialog box if no track selected
 * v1.0 (2015-02-28)
  + Initial Release
--]]


-- CREATE TEXT ITEMS
-- text and color are optional
function CreateTextItem(track, position, length, text, color)

  local item = reaper.AddMediaItemToTrack(track)

  reaper.SetMediaItemInfo_Value(item, "D_POSITION", position)
  reaper.SetMediaItemInfo_Value(item, "D_LENGTH", length)

  if text ~= nil then
    reaper.ULT_SetMediaItemNote(item, text)
  end

  if color ~= nil then
    reaper.SetMediaItemInfo_Value(item, "I_CUSTOMCOLOR", color)
  end

  return item

end


-- TABLE INIT
local setSelectedMediaItem = {}

-- MAIN
function main()

  selected_tracks_count = reaper.CountSelectedTracks(0)

  if selected_tracks_count > 0 then

    -- DEFINE TRACK DESTINATION
    selected_track = reaper.GetSelectedTrack(0,0)

    -- COUNT SELECTED ITEMS
    selected_items_count = reaper.CountSelectedMediaItems(0)

    if selected_items_count > 0 then

      reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

      -- SAVE TAKES SELECTION
      for j = 0, selected_items_count-1  do
        setSelectedMediaItem[j] = reaper.GetSelectedMediaItem(0, j)
      end

      -- LOOP THROUGH TAKE SELECTION
      for i = 0, selected_items_count-1  do
        -- GET ITEMS AND TAKES AND PARENT TRACK
        item = setSelectedMediaItem[i] -- Get selected item i

        -- GET INFOS
        item_color = reaper.GetDisplayedMediaItemColor(item)

        text = reaper.ULT_GetMediaItemNote(item)

        -- TIMES
        item_start = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
        item_duration = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")

        -- ACTION
        CreateTextItem(selected_track, item_start, item_duration, text)

      end -- ENDLOOP through selected items
      reaper.Main_OnCommand(40421, 0)
      reaper.Undo_EndBlock("Create text items on first selected track from selected items notes", -1) -- End of the undo block. Leave it at the bottom of your main function.
    else -- no selected item
      reaper.ShowMessageBox("Select at least one item","Please",0)
    end -- if select item
  else -- no selected track
    reaper.ShowMessageBox("Select a destination track before running the script","Please",0)
  end -- if selected track
end


reaper.PreventUIRefresh(1)

reaper.Main_OnCommand(40914, 0) -- Select first track as last touched
main() -- Execute your main function

reaper.UpdateArrange() -- Update the arrangement (often needed)

reaper.PreventUIRefresh(-1)