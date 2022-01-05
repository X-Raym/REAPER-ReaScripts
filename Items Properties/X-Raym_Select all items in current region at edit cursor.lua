--[[
 * ReaScript Name: Select all items in current region at edit cursor
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
 * v1.0 (2020-10-27)
  + Initial release
--]]

-- USER CONFIG AREA -----------------------------------------------------------

console = false -- true/false: display debug messages in the console

------------------------------------------------------- END OF USER CONFIG AREA

-- UTILITIES -------------------------------------------------------------

local reaper = reaper

-- INIT

markeridx, regionidx = reaper.GetLastMarkerAndCurRegion( 0,  reaper.GetCursorPosition() )
if regionidx >= 0 then

  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  reaper.Main_OnCommand(40289, 0) -- Item: Unselect all items

  init_start_pos, init_end_pos = reaper.GetSet_LoopTimeRange2( 0, true, false, 0 , 0, false )

  retval, isrgn, pos, rgnend, name, markrgnindexnumber, color = reaper.EnumProjectMarkers3( 0, regionidx )
  start_pos, end_pos = reaper.GetSet_LoopTimeRange2( 0, true, false,pos , rgnend, false )

  reaper.Main_OnCommand(40717, 0) -- Item: Select all items in current time selection

  start_pos, end_pos = reaper.GetSet_LoopTimeRange2( 0, true, false, init_start_pos , init_end_pos, false )

  reaper.Undo_EndBlock("Select all items in current region at edit cursor", -1) -- End of the undo block. Leave it at the bottom of your main function.

  reaper.UpdateArrange()

  reaper.PreventUIRefresh(-1)

end
