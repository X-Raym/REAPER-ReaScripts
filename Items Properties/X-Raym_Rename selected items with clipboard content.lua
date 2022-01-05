--[[
 * ReaScript Name: Rename selected items with clipboard content
 * Author: X-Raym
 * Author URI: https://extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Properties (various)
 * Forum Thread URI: https://forum.cockos.com/showthread.php?t=195520
 * REAPER: 5.0
 * Version: 1.0.1
--]]

--[[
 * Changelog:
 * v1.0.1 (2017-09-21)
  # Title
 * v1.0 (2017-09-21)
  + Initial Release
--]]

reaper.PreventUIRefresh(1)

reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

clipboard = reaper.CF_GetClipboard('')

if clipboard ~= "" then
  for i = 0, reaper.CountSelectedMediaItems(0) - 1 do
    local take = reaper.GetActiveTake( reaper.GetSelectedMediaItem(0, i) )
    if take then
      reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", clipboard, true)
    end
  end
end

reaper.Undo_EndBlock("Rename selected takes from regions", - 1) -- End of the undo block. Leave it at the bottom of your main function.

reaper.PreventUIRefresh(-1)