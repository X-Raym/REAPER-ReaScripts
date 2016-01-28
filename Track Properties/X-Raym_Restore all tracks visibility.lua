--[[
 * ReaScript Name: Restore all tracks visibility
 * Description: A script to save tracks visibility. Use the save version of this script before. You can mod this script to restore only MCP or TCP.
 * Instructions: Run.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Scripts: Track Selection (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1569551
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2016-01-28)
	+ Initial Release
--]]

-- USER CONFIG AREA ----------------

tcp = true -- true/false
mcp = true -- true/false

------------------------------------

-- Console Message
function Msg(g)
  reaper.ShowConsoleMsg(tostring(g).."\n")
end


function main()

	
	-- Loop in Save
	i = 0
	repeat
	
		local retval, value = reaper.GetProjExtState(0, "Track_Visibility", i)
	
		local track = reaper.GetTrack(0, i)
		
		if track and retval > 0 then
		
			tcp_visibility, mcp_visibility = value:match("([^,]+),([^,]+)")
			
			if tcp then
				reaper.SetMediaTrackInfo_Value(track, "B_SHOWINTCP", tcp_visibility)
			end
			if mcp then
				reaper.SetMediaTrackInfo_Value(track, "B_SHOWINMIXER", mcp_visibility)
			end
			
		end
	
		i = i + 1
		
	until retval == 0 or track == nil
	
end

count_tracks = reaper.CountTracks(0)

if count_tracks > 0 then
	reaper.PreventUIRefresh(1)
	reaper.Undo_BeginBlock()
	main()
	reaper.Undo_EndBlock("Restore All Tracks Visibility", -1)
	reaper.TrackList_AdjustWindows(false)
	reaper.UpdateArrange()
	reaper.PreventUIRefresh(-1)
end
