--[[
 * ReaScript Name: Copy selected items colors as CSV to clipboard
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0.1
--]]

--[[
 * Changelog:
 * v1.0 (2022-01-12)
  + Initial Release
--]]

-- USER CONFIG AREA ---------------------------------------

sep = ","

-------------------------------- END OF USER CONFIG AREA --

function rgbToHex(r, g, b)
    return string.format("#%0.2X%0.2X%0.2X", r, g, b)
end

count_sel_items = reaper.CountSelectedMediaItems(0)
if count_sel_items == 0 then return false end

reaper.PreventUIRefresh(1)

reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

colors = {}
for i = 0, count_sel_items - 1 do
  item = reaper.GetSelectedMediaItem(0, i)
  take = reaper.GetActiveTake( item )
  if take then
    color = reaper.GetDisplayedMediaItemColor2( item, take )
  else
    color = reaper.GetDisplayedMediaItemColor( item )
  end
  color_hex = rgbToHex( reaper.ColorFromNative(color) )
  table.insert( colors, color_hex )
end

clipboard = table.concat( colors, sep )

reaper.CF_SetClipboard( clipboard )

mouse_x, mouse_y = reaper.GetMousePosition()
reaper.TrackCtl_SetToolTip("Colors copied to clipboard", mouse_x + 17, mouse_y + 17, false)

reaper.Undo_EndBlock("Copy selected items colors as CSV to clipboard", - 1) -- End of the undo block. Leave it at the bottom of your main function.

reaper.PreventUIRefresh(-1)
