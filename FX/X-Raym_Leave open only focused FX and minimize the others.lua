--[[
 * ReaScript Name: Leave open only focused FX and minimize the others
 * Description:
 * Instructions: Touch an FX param. Run.
 * Screenshot :
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI:
 * Licence: GPL v3
 * Forum Thread: [REQ]: minimize all FX windows but the selected or last (added) one
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=165547
 * REAPER: 5.0 RC 14b
 * Extensions: None
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2015-08-26)
	+ Initial Release
 --]]

function Msg(text)
  reaper.ShowConsoleMsg(tostring(text).."\n")
end

function Main()
  
  reaper.Undo_BeginBlock()
  
  retval, focused_fx_track, focused_item_fx, focused_fx_id = reaper.GetFocusedFX()
  
  focused_fx_track_id = focused_fx_track - 1
  
  Msg("focused_fx_track_id = "..focused_fx_track_id)
  Msg("focused_fx_id = "..focused_fx_id)
  
  if retval then
  
    for i = 0, reaper.CountTracks(0) - 1 do  
      
      track = reaper.GetTrack(0, i)
      
      for j = 0, reaper.TrackFX_GetCount(track) - 1 do
      
        --fx_open = reaper.TrackFX_GetOpen(track, j)
        
         if j == focused_fx_id and i == focused_fx_track_id then
		
		 Msg(j.." ~= "..(focused_fx_id) .." and "..i.." ~= ".. focused_fx_track_id)
          
		  reaper.TrackFX_SetOpen(track, j, true)

        else
		
			reaper.TrackFX_SetOpen(track, j, false)
			
		end
        
      end
      
    end
    
  end
    
  reaper.Undo_EndBlock("Leave open only focused FX and minimize the others",-1)

end

Main()
