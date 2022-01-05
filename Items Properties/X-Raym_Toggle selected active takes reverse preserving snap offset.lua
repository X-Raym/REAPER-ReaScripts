--[[
 * ReaScript Name: Toggle selected active takes reverse preserving snap offset
 * About: Toggle reverse of seleted items, preserving relative (from item start) snap offset position.
 * Instructions: Select items with take. Run.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Script (Lua): Shuffle Items
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1524014
 * REAPER: 5.0 pre 15
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2015-05-20)
  + Initial Release
--]]


function main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  -- LOOP THROUGH SELECTED TAKES
  selected_items_count = reaper.CountSelectedMediaItems(0)

  for i = 0, selected_items_count-1  do
    -- GET ITEMS
    item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i

    take = reaper.GetActiveTake(item) -- Get the active take

    if take ~= nil then -- if ==, it will work on "empty"/text items only

      -- GET INFOS
      new_snap =  reaper.GetMediaItemInfo_Value(item, "D_LENGTH") - reaper.GetMediaItemInfo_Value(item, "D_SNAPOFFSET")

      -- REVERSE
      reaper.Main_OnCommand(41051, 0)

      -- SET INFOS
      reaper.SetMediaItemInfo_Value(item, "D_SNAPOFFSET", new_snap) -- Set the value to the parameter

    end -- ENDIF active take

  end -- ENDLOOP through selected items

  reaper.Undo_EndBlock("Toggle selected active takes reverse preserving snap offset", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)
