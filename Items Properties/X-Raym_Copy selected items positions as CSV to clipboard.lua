--[[
 * ReaScript Name: Copy selected items positions as CSV to clipboard
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2022-04-11)
  + Initial Release
--]]

-- USER CONFIG AREA ---------------------------------------

sep = "\t"

timecode_format = 5 -- https://www.extremraym.com/cloud/reascript-doc/#format_timestr_pos

-------------------------------- END OF USER CONFIG AREA --

function Main()

  t = {}
  for i = 0, count_sel_items - 1 do
    local item = reaper.GetSelectedMediaItem(0, i)
    local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    item_pos = reaper.format_timestr_pos( item_pos, "", timecode_format )
    table.insert( t, item_pos )
  end

  clipboard = table.concat( t, sep )

  reaper.CF_SetClipboard( clipboard )

  mouse_x, mouse_y = reaper.GetMousePosition()
  reaper.TrackCtl_SetToolTip("Item positions copied to clipboard", mouse_x + 17, mouse_y + 17, false)

end

function Init()
  count_sel_items = reaper.CountSelectedMediaItems(0)
  if count_sel_items == 0 then return false end

  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  Main()

  reaper.Undo_EndBlock("Copy selected items positions as CSV to clipboard", - 1) -- End of the undo block. Leave it at the bottom of your main function.

  reaper.PreventUIRefresh(-1)
end

if not preset_file_init then
  Init()
end
