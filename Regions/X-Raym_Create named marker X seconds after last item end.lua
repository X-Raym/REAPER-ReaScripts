--[[
 * ReaScript Name: Create named marker X seconds after last item end
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2019-11-07)
  + Initial Release
--]]

name = ""
offset = 10

function main()

  count_sel_items = reaper.CountSelectedMediaItems(0)
  
  if count_sel_items > 0 then
  
    -- GET ITEMS
    item = reaper.GetSelectedMediaItem(0, count_sel_items-1) -- Get selected item i
    
    item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    
    take = reaper.GetActiveTake(item)
    if take == nil then
      item_color = reaper.GetDisplayedMediaItemColor(item)
    else
      item_color = reaper.GetDisplayedMediaItemColor2(item, take)
    end
    
    snap = item_pos + item_len + offset
    reaper.AddProjectMarker2(0, false, snap, 0, name, -1, item_color)
    
  end -- ENDLOOP through selected items

end

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

main() -- Execute your main function

reaper.Undo_EndBlock("Create named marker X seconds after last item end", -1) -- End of the undo block. Leave it at the bottom of your main function.

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)
