--[[
 * ReaScript Name: Import tracks from file
 * Description: Import tracks from a TXT or CSV file. One track name per line.
 * Instructions: Select an item. Use it.
 * Screenshot: http://i.giphy.com/3oEduTrQlzj80oPpWE.gif
 * Author: X-Raym
 * Author URl: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URl: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URl: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Import track titles from file (eg: CSV)
 * Forum Thread URl: http://forum.cockos.com/showthread.php?p=1564559&posted=1#post1564559
 * REAPER: 5.0 pre 36
 * Extensions: SWS/S&M 2.7.1 #0
]]
 
 
--[[
 * Changelog:
 * v1.0 (2015-08-27)
	+ Initial Release
]]


function Msg(variable)
	reaper.ShowConsoleMsg(tostring(variable).."\n")
end

----------------------------------------------------------------------

function read_lines(filepath)
	
	reaper.Undo_BeginBlock() -- Begin undo group
	
	count_tracks = reaper.CountTracks(0)
	
	local f = io.input(filepath)
	repeat
		
		s = f:read ("*l") -- read one line
		
		i = 0
		
		if s then  -- if not end of file (EOF)
			
			last_track_id = count_tracks + i
			reaper.InsertTrackAtIndex(last_track_id, true)
			last_track = reaper.GetTrack(0, last_track_id)
			
			retval, track_name = reaper.GetSetMediaTrackInfo_String(last_track, "P_NAME", s, true)

		end
	
	until not s  -- until end of file

	f:close()

	reaper.Undo_EndBlock("Display script infos in the console", -1) -- End undo group
	
end



-- START -----------------------------------------------------
retval, filetxt = reaper.GetUserFileNameForRead("", "Import tracks from file", "")

if retval then 
	
	reaper.PreventUIRefresh(1)
	read_lines(filetxt)
	reaper.TrackList_AdjustWindows(false)
	reaper.UpdateTimeline()
	reaper.UpdateArrange()
	reaper.PreventUIRefresh(-1)
	
end
