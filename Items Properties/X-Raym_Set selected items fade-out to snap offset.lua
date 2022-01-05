--[[
 * ReaScript Name: Set selected items fade-out to snap offset
 * Instructions: Select items. Run.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Script: Scripts: Item Fades (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1538659
 * REAPER: 5.0 pre 36
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2015-06-26)
  + Initial Release
--]]



function main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  -- LOOP THROUGH SELECTED ITEMS

  selected_items_count = reaper.CountSelectedMediaItems(0)

  -- INITIALIZE loop through selected items
  for i = 0, selected_items_count-1  do
    -- GET ITEMS
    item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i

    -- GET INFOS
    item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    item_snap = reaper.GetMediaItemInfo_Value(item, "D_SNAPOFFSET")

    fadein_len = reaper.GetMediaItemInfo_Value(item, "D_FADEINLEN")

    if fadein_len >= item_snap then reaper.SetMediaItemInfo_Value(item, "D_FADEINLEN", item_snap) end

    -- SET INFOS
    reaper.SetMediaItemInfo_Value(item, "D_FADEOUTLEN", item_len - item_snap) -- Set the value to the parameter
  end -- ENDLOOP through selected items

  reaper.Undo_EndBlock("Set selected items fade-out to snap offset", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

main() -- Execute your main function

reaper.UpdateArrange() -- Update the arrangement (often needed)