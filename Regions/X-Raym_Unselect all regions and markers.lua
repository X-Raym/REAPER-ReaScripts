--[[
 * ReaScript Name: Unselect all markers and regions
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 7.62
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2026-10-27)
  + Initial Release
--]]

if not reaper.GetRegionOrMarkerInfo_Value then
  reaper.MB("REAPER v7.62 minimum required.\nPlease update!", "Error", 1)
end

function Main()
  local count = reaper.GetNumRegionsOrMarkers( 0 )
  for i = 0, count - 1 do
    local regionOrMarker = reaper.GetRegionOrMarker( 0, i, "" )
    if reaper.GetRegionOrMarkerInfo_Value( 0, regionOrMarker, "B_UISEL" ) == 1 then
      reaper.SetRegionOrMarkerInfo_Value( 0, regionOrMarker, "B_UISEL", 0 )
    end
  end
end

reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock()
Main()
reaper.Undo_EndBlock("Unselect all markers and regions", -1)
reaper.UpdateTimeline()
reaper.PreventUIRefresh(-1)
