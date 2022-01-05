--[[
 * ReaScript Name: Paste clipboard content into selected items notes
 * Author: X-Raym
 * Author URI: https://extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Properties (various)
 * Forum Thread URI: https://forum.cockos.com/showthread.php?t=195520
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2020-04-23)
  + Initial Release
--]]

reaper.PreventUIRefresh(1)

reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

clipboard = reaper.CF_GetClipboard('')

if clipboard ~= "" then
  for i = 0, reaper.CountSelectedMediaItems(0) - 1 do
    item = reaper.GetSelectedMediaItem(0, i)
    reaper.ULT_SetMediaItemNote( item, clipboard )
  end
end

reaper.UpdateArrange()

reaper.Undo_EndBlock("Paste clipboard content into selected items notes", - 1) -- End of the undo block. Leave it at the bottom of your main function.

reaper.PreventUIRefresh(-1)
