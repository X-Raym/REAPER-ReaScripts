--[[
 * ReaScript Name: Stop media explorer
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
 * v1.0 (2020-07-05)
  + Initial Release
--]]

dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")

if not (ultraschall and ultraschall.CopyMediaItemToDestinationTrack and ultraschall.AddItemSpectralEdit) then
  reaper.ShowConsoleMsg("Please Install Ultraschall API via Reapack\nhttps://raw.githubusercontent.com/Ultraschall/ultraschall-lua-api-for-reaper/master/ultraschall_api_index.xml")
  return false
end

ultraschall.MediaExplorer_OnCommand(1010) --Preview: Pause
