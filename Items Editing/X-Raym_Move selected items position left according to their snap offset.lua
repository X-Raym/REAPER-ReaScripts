--[[
 * ReaScript Name: Move selected items position left according to their snap offset
 * Instructions: Select items. Run.
 * Screenshot: http://i.giphy.com/xTka01QdCUzcfyqtna.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Editing (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=163363
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2015-12-14)
  + Initial Release
--]]

sel_item = {}

function main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  -- SAVE SELECTION
  for i = 1, count_sel_items do

    sel_item[i] = reaper.GetSelectedMediaItem(0, i - 1)

  end


  -- MOVE SELECTION
  for w = 1, #sel_item do

    sel_item_pos = reaper.GetMediaItemInfo_Value(sel_item[w], "D_POSITION")
    sel_item_snap = reaper.GetMediaItemInfo_Value(sel_item[w], "D_SNAPOFFSET")

    reaper.SetMediaItemInfo_Value(sel_item[w], "D_POSITION", sel_item_pos - sel_item_snap)

  end

  reaper.Undo_EndBlock("Move selected items position left according to their snap offset", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

count_sel_items = reaper.CountSelectedMediaItems(0)

if count_sel_items > 0 then

  reaper.PreventUIRefresh(1)

  main() -- Execute your main function

  reaper.UpdateArrange() -- Update the arrangement (often needed)

  reaper.PreventUIRefresh(-1)

end
