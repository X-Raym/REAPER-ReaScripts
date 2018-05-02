--[[
 * ReaScript Name: Unhide - set visible tracks with items
 * Instructions: https://i.imgur.com/qWRVINF.gifv
 * Author: X-Raym
 * Author URI: https://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Scripts: Track Selection (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1569551
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2018-05-02)
	+ Initial Release
--]]

tcp = true
mcp = true

console = false

function Msg(variable)
	if console == true then
		reaper.ShowConsoleMsg(tostring(variable).."\n")
	end
end

function Main()

	-- Loop in Tracks
	for i = 0, count_tracks - 1 do

		local track = reaper.GetTrack(0, i)

		local num_items = reaper.CountTrackMediaItems( track )

		if num_items > 0 then
			local tcp_visibility = reaper.GetMediaTrackInfo_Value(track, "B_SHOWINTCP")
			local mcp_visibility = reaper.GetMediaTrackInfo_Value(track, "B_SHOWINMIXER")
			console = true

			if tcp_visibility == 0 and tcp then reaper.SetMediaTrackInfo_Value(track, "B_SHOWINTCP", 1) end
			if mcp_visibility == 0 and mcp then reaper.SetMediaTrackInfo_Value(track, "B_SHOWINMIXER", 1) end
		end

	end

end

count_tracks = reaper.CountTracks(0)

if count_tracks > 0 then
	reaper.PreventUIRefresh(1)
	reaper.Undo_BeginBlock()
	Main()
	reaper.TrackList_AdjustWindows(false)
	reaper.UpdateArrange()
	reaper.Undo_EndBlock('Unhide - set visible tracks with items', -1)
	reaper.PreventUIRefresh(-1)
end
