--[[
 * ReaScript Name: Rename selected takes from regions
 * Description: See title
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
 * v1.0 (2017-09-21)
  + Initial Release
--]]


clipboard = reaper.CF_GetClipboard('')

if clipboard ~= "" then
  for i = 0, reaper.CountSelectedMediaItems(0) - 1 do
    local take = reaper.GetActiveTake( reaper.GetSelectedMediaItem(0, i) )
    if take then
      reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", clipboard, true)
    end
  end
end
