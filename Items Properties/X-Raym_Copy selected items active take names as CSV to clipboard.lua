--[[
 * ReaScript Name: Copy selected items active take names as CSV to clipboard
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
 * v1.0 (2024-09-04)
  + Initial Release
--]]

-- USER CONFIG AREA ---------------------------------------

sep = "\n"

-------------------------------- END OF USER CONFIG AREA --

if not reaper.CF_GetSWSVersion then
  reaper.MB("Missing dependency: SWS extension.\nPlease download it from http://www.sws-extension.org/", "Error", 0)
  return false
end

function Main()

  t = {}
  for i = 0, count_sel_items - 1 do
    local item = reaper.GetSelectedMediaItem(0, i)
    local take = reaper.GetActiveTake( item )
    local name = ""
    if take then
      name = reaper.GetTakeName( take )
    end
    table.insert( t, name )
  end

  clipboard = table.concat( t, sep )

  reaper.CF_SetClipboard( clipboard )

  mouse_x, mouse_y = reaper.GetMousePosition()
  reaper.TrackCtl_SetToolTip("Item names copied to clipboard", mouse_x + 17, mouse_y + 17, false)

end

function Init()
  count_sel_items = reaper.CountSelectedMediaItems(0)
  if count_sel_items == 0 then return false end

  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  Main()

  reaper.Undo_EndBlock("Copy selected items active take names as CSV to clipboard", - 1) -- End of the undo block. Leave it at the bottom of your main function.

  reaper.PreventUIRefresh(-1)
end

if not preset_file_init then
  Init()
end
