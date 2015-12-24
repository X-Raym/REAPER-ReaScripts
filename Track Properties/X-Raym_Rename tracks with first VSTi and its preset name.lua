--[[
 * ReaScript Name: Rename tracks with first VSTi and its preset name
 * Description: A way to quickly rename and recolor tracks in a REAPER project from its instrument.
 * Instructions: Select tracks. Run.
 * Screenshot: http://i.giphy.com/l41lMgnQVFZp2qfjW.gif
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI:
 * Licence: GPL v3
 * Forum Thread: Video & Sound Editors Will Really Like This
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1539710
 * Extensions: None
 * Version: 1.1.1
--]]
 
--[[
 * Changelog:
 * v1.1.1 (2015-07-25)
	# Space in name
 * v1.1 (2015-07-25)
	+ Delete author and version in name
	# bug fix
 * v1.0 (2015-07-22)
	+ Initial Release
 --]]
 
-- ------ USER CONFIG AREA =====>

separator = "-"

-- <===== USER CONFIG AREA ------

function main()
	
	for i = 0, tracks_count - 1 do
		
		track = reaper.GetSelectedTrack(0, i)
		
		vsti_id = reaper.TrackFX_GetInstrument(track)
		
		if vsti_id >= 0 then
		
			retval, fx_name = reaper.TrackFX_GetFXName(track, vsti_id, "")
			
			fx_name = fx_name:gsub("VSTi: ", "")
			
			fx_name = fx_name:gsub(" %(.-%)", "")
			
			retval, presetname = reaper.TrackFX_GetPreset(track, vsti_id, "")
			
			if retval == 0 then
			
				track_name_retval, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", fx_name, true)
				
			else
			
				track_name_retval, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", fx_name .. " " .. separator .. " " .. presetname, true)
			
			end
		
		end
	
	end

end

-- INIT
tracks_count = reaper.CountSelectedTracks(0)

if tracks_count > 0 then
  
  reaper.PreventUIRefresh(1)
   
  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
 
  main()
   
  reaper.Undo_EndBlock("Rename tracks with first VSTi and its preset name", -1) -- End of the undo block. Leave it at the bottom of your main function.
   
  reaper.PreventUIRefresh(-1)
  
end
