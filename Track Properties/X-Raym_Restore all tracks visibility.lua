--[[
 * ReaScript Name: Restore all tracks visibility
 * Description: A script to save tracks visibility. Use the save version of this script before. You can mod this script to restore only MCP or TCP. Note that newly created tracks are ignored by the restoration (they will not be hidden).
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
 * Version: 2.0
--]]
 
--[[
 * Changelog:
 * v2.0 (2019-04-26)
	# Use track GUID to avoid lots of bugs with track reordering, addition, etc...
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
	
		local retval, key, value = reaper.EnumProjExtState(0, "Track_Visibility", i)
	
		local track = reaper.BR_GetMediaTrackByGUID(0, key)
		
		if track and retval then
		
			tcp_visibility, mcp_visibility = value:match("([^,]+),([^,]+)")
			
			if tcp then
				reaper.SetMediaTrackInfo_Value(track, "B_SHOWINTCP", tcp_visibility)
			end
			if mcp then
				reaper.SetMediaTrackInfo_Value(track, "B_SHOWINMIXER", mcp_visibility)
			end
			
		end
	
		i = i + 1
		
	until not retval
	
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
