--[[
 * ReaScript Name: Move selected items up to the top visible track
 * Instructions: Select items. Run.
 * Screenshot: https://i.imgur.com/UNdnR4C.gifv
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Editing (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=163363
 * REAPER: 5.0
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2018-09-30)
  + Initial Release
--]]

sel_item = {}
 
function main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
  
  for i = 0, count_tracks - 1 do
    track = reaper.GetTrack( 0, i )
    visible = reaper.IsTrackVisible(track, false)
    if visible then break end
  end
  
  if not visible then return end
  
  -- SAVE SELECTION
  for i = 1, count_sel_items do
  
    sel_item[i] = reaper.GetSelectedMediaItem(0, i - 1)
    
  end
  
  
  -- MOVE SELECTION     
  for w = 1, #sel_item do
  
    reaper.MoveMediaItemToTrack( sel_item[w], track )
  
  end
  
  reaper.Undo_EndBlock("Move selected items position right according to their snap offset", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

count_sel_items = reaper.CountSelectedMediaItems(0)
count_tracks = reaper.CountTracks(0)

if count_sel_items > 0 and count_tracks > 0 then

  reaper.PreventUIRefresh(1)
  
  main() -- Execute your main function
  
  reaper.UpdateArrange() -- Update the arrangement (often needed)

  reaper.PreventUIRefresh(-1)
  
end
