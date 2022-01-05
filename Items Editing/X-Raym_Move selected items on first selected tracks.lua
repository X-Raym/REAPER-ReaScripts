--[[
 * ReaScript Name: Move selected items on first selected tracks
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Screenshot: https://i.imgur.com/NCQM0YA.gifv
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Editing (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1538604
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2020-06-21)
  + Initial Release
--]]



-- USER CONFIG AREA -----------------------------------------------------------

console = true -- true/false: display debug messages in the console

------------------------------------------------------- END OF USER CONFIG AREA


-- UTILITIES -------------------------------------------------------------

-- Save item selection
function SaveSelectedItems (table)
  for i = 0, reaper.CountSelectedMediaItems(0)-1 do
    table[i+1] = reaper.GetSelectedMediaItem(0, i)
  end
end

--------------------------------------------------------- END OF UTILITIES


-- Main function
function main()

  for i, item in ipairs(init_sel_items) do
    reaper.MoveMediaItemToTrack( item, first_sel_track )
  end

end


-- INIT

-- See if there is items selected
count_sel_items = reaper.CountSelectedMediaItems(0)
first_sel_track = reaper.GetSelectedTrack(0,0)

if count_sel_items > 0 and count_sel_items then

  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  init_sel_items =  {}
  SaveSelectedItems(init_sel_items)

  main()

  reaper.Undo_EndBlock("Move selected items on first selected tracks", -1) -- End of the undo block. Leave it at the bottom of your main function.

  reaper.UpdateArrange()

  reaper.PreventUIRefresh(-1)

end

