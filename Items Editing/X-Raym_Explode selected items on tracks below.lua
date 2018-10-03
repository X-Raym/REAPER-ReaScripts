--[[
 * ReaScript Name: Explode selected items on tracks below
 * Screenshot: https://i.imgur.com/1ffAPBd.gifv
 * About: Leave first item to its track, then take second item and put to next track, etc.. Other explode items to tracks actions create new tracks. Not this one, unless there is not enough tracks.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Editing (various)
 * Forum Thread URI: https://forum.cockos.com/showthread.php?t=163363
 * REAPER: 5.0
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2018-10-03)
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


-- Display a message in the console for debugging
function Msg(value)
  if console then
    reaper.ShowConsoleMsg(tostring(value) .. "\n")
  end
end

--------------------------------------------------------- END OF UTILITIES


-- Main function
function main()

  for i, item in ipairs(init_sel_items) do
   if i > 1 then
    track = reaper.GetTrack( 0, idx + i - 1 - 1 )
    if not track then
      reaper.InsertTrackAtIndex( idx + i - 1 - 1, true )
      track = reaper.GetTrack( 0, idx + i - 1 - 1 )
    end
    reaper.MoveMediaItemToTrack( item, track )
   else
    track = reaper.GetMediaItemTrack( item )
    idx = reaper.GetMediaTrackInfo_Value( track, "IP_TRACKNUMBER")
   end
  end

end


-- INIT

-- See if there is items selected
count_sel_items = reaper.CountSelectedMediaItems(0)

if count_sel_items > 0 then

  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
  
  init_sel_items =  {}
  SaveSelectedItems(init_sel_items)

  main()

  reaper.Undo_EndBlock("Explode selected items on tracks below", -1) -- End of the undo block. Leave it at the bottom of your main function.

  reaper.UpdateArrange()

  reaper.PreventUIRefresh(-1)
  
end
