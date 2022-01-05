--[[
 * ReaScript Name: Convert selected takes names to item notes
 * About: Convert selected takes names to item notes
 * Instructions: Select an item. Use it.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts (LUA): Text Items Formatting Actions (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=156757
 * REAPER: 5.0 pre 15
 * Extensions: SWS/S&M 2.7.3 #0
 * Version: 1.1
--]]

--[[
 * Changelog:
 * v1.1 (2015-07-29)
  # Better Set notes
 * v1.0 (2015-03-24)
  + Initial Release
--]]


function convert()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.


  -- LOOP THROUGH SELECTED ITEMS
  selected_items_count = reaper.CountSelectedMediaItems(0)

  -- INITIALIZE loop through selected items
  for i = 0, selected_items_count-1  do
    -- GET ITEMS
    item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i
    take = reaper.GetActiveTake(item)

    if take ~= nil then
      -- GET NOTES
      retval, name = reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", "", 0)
      --reaper.ShowConsoleMsg(note)

      reaper.ULT_SetMediaItemNote(item, name)
    end

  end -- ENDLOOP through selected items

  reaper.Undo_EndBlock("Convert selected takes names to item notes", 0) -- End of the undo block. Leave it at the bottom of your main function.

end



reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

convert() -- Execute your main function

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)

