--[[
 * ReaScript Name: Swap selected item notes and take name
 * About: Swap selected item notes and take name
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


function swap()

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
      note = reaper.ULT_GetMediaItemNote(item)
      --reaper.ShowConsoleMsg(note)
      note = note:gsub("\n", " ")
      note2 = note:gsub("|", "")
      retval, name = reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", "", 0)
      --reaper.ShowConsoleMsg(note)

      -- MODIFY TAKE
      reaper.ULT_SetMediaItemNote(item, name)
      retval, stringNeedBig = reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", note2, 1)
    end

  end -- ENDLOOP through selected items

  reaper.Undo_EndBlock("Swap selected item notes and take name", 0) -- End of the undo block. Leave it at the bottom of your main function.

end



reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

swap() -- Execute your main function

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)

