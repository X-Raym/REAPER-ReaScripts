--[[
 * ReaScript Name: Set selected items active take sources online
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Forum Thread: Online / Offline takes
 * Forum Thread URI: https://forum.cockos.com/showthread.php?p=2154446#post2154446
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2019-07-06)
  + Initial release
--]]

-- USER CONFIG AREA -----------------------------------------------------------

console = false -- true/false: display debug messages in the console

------------------------------------------------------- END OF USER CONFIG AREA

-- UTILITIES -------------------------------------------------------------

local reaper = reaper

-- Display a message in the console for debugging
function Msg(value)
  if console then
    reaper.ShowConsoleMsg(tostring(value) .. "\n")
  end
end

--------------------------------------------------------- END OF UTILITIES

-- Main function
function Main()

  for i = 0, count_selected_items - 1 do

    local item = reaper.GetSelectedMediaItem( 0, i )
    local active_take = reaper.GetActiveTake( item )
    if active_take then
      local src = reaper.GetMediaItemTake_Source( active_take )
      reaper.CF_SetMediaSourceOnline( src, true )
    end

  end

end

-- INIT

-- See if there is items selected
count_selected_items = reaper.CountSelectedMediaItems(0)

if count_selected_items > 0 then

  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  Main()

  reaper.Undo_EndBlock("Set selected items active take sources online", -1) -- End of the undo block. Leave it at the bottom of your main function.

  reaper.UpdateArrange()

  reaper.PreventUIRefresh(-1)

end
