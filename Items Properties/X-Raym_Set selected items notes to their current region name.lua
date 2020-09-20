--[[
 * ReaScript Name: Set selected items notes to their current region name
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
 * v1.0 (2020-09-20)
  + Initial Release
--]]

reaper.PreventUIRefresh(1)

reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

for i = 0, reaper.CountSelectedMediaItems(0) - 1 do
  item = reaper.GetSelectedMediaItem(0, i)
  pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
  markeridx, regionidx = reaper.GetLastMarkerAndCurRegion( proj, pos )
  if regionidx > - 1 then
    local retval, isrgn, pos, rgnend, name, markrgnindexnumber, color = reaper.EnumProjectMarkers3( 0, regionidx )
    reaper.ULT_SetMediaItemNote( item, name )
  end
end

reaper.UpdateArrange()

reaper.Undo_EndBlock("Set selected items notes to their current region name", - 1) -- End of the undo block. Leave it at the bottom of your main function.

reaper.PreventUIRefresh(-1)
