--[[
 * ReaScript Name: Leave open only focused FX and minimize the others
 * Description:
 * Instructions: Touch an FX param. Run.
 * Screenshot :
 * Author: X-Raym
 * Author URl: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URl: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URl:
 * Licence: GPL v3
 * Forum Thread: [REQ]: minimize all FX windows but the selected or last (added) one
 * Forum Thread URl: http://forum.cockos.com/showthread.php?t=165547
 * REAPER: 5.0 RC 14b
 * Extensions: None
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
  
  retval, focused_fx_track, focused_item_fx, focused_fx = reaper.GetFocusedFX()
  
  Msg(focused_fx_track)
  Msg(focused_fx)
  
  if retval then
  
    for i = 0, reaper.CountTracks(0) - 1 do  
      
      track = reaper.GetTrack(0, i)
      
      for j = 0, reaper.TrackFX_GetCount(track) - 1 do
      
        fx_open = reaper.TrackFX_GetOpen(track, j)
        
        if j ~= focused_fx - 1 and i ~= focused_fx_track - 1 then
          reaper.TrackFX_SetOpen(track, j, false)
		  Msg("CLOSE")
        end
        
      end
      
    end
    
  end
    
  reaper.Undo_EndBlock("Leave open only focused FX and minimize the others",-1)

end

Main()
