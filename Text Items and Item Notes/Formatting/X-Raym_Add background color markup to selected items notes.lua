--[[
 * ReaScript Name: Add background markup to selected items notes
 * About: Add background markup to selected items notes, based on actual item color
 * Instructions: Select an item. Use it.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts (LUA): Text Items Formatting Actions (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=156757
 * REAPER: 5.0 pre 32
 * Extensions: SWS/S&M 2.7.1
 * Version: 1.1
--]]

--[[
 * Changelog:
 * v1.1 (2015-07-08)
  # New core
 * v1.0 (2015-03-06)
  + Abble to update background tags if already set
  + Abble to delete background tag if item has not color
  + Initial Release
--]]



function background_notes()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  -- LOOP THROUGH SELECTED ITEMS
  selected_items_count = reaper.CountSelectedMediaItems(0)

  -- INITIALIZE loop through selected items
  for i = 0, selected_items_count-1  do
    -- GET ITEMS
    item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i

    -- GET NOTES
    note = reaper.ULT_GetMediaItemNote(item)
    --reaper.ShowConsoleMsg(note)

    -- MODIFY NOTES

    color_int = reaper.GetDisplayedMediaItemColor(item)
    if color_int > 0 then
      R = color_int & 255
      G = (color_int >> 8) & 255
      B = (color_int >> 16) & 255
      color_hex = "\"#" .. string.format("%02X", R) .. string.format("%02X", G) .. string.format("%02X", B) .. "\""

      x, y = string.find(note, "background=")

      if x == nil then

        note = note  .. "\n<background=" .. color_hex .. "/>"

      else

        note = note:gsub('%b""', color_hex) -- delete all formating

      end

      -- SET NOTES
      reaper.ULT_SetMediaItemNote(item, note)

    else

      note = note:gsub("<background=\"#.+\"/>", "")

      reaper.ULT_SetMediaItemNote(item, note)

    end

  end -- ENDLOOP through selected items

  reaper.Undo_EndBlock("Add background markup to selected items notes", 0) -- End of the undo block. Leave it at the bottom of your main function.

end



reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

background_notes() -- Execute your main function

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)

