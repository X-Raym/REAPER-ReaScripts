--[[
 * ReaScript Name: Set selected tracks, items and takes color from mouse context
 * Description: A way to copy paste color value bewteen elements.
 * Instructions: Select tracks and items. Mouse over tracks in TCP/MCP or over items/takes. Run with a keyboard shortcut.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: 
 * Forum Thread URI: 
 * REAPER: 5.0 pre 21
 * Extensions: SWS/S&M 2.6.3 #0
 * Version: 1.1
--]]
 
--[[
 * Changelog:
 * v1.1 (2015-04-13)
	# no console message
 * v1.0 (2015-04-05)
	+ Initial Release
 --]]

-- INIT
color_int = 0

function main()

	reaper.Undo_BeginBlock()

	window, segment, details =  reaper.BR_GetMouseCursorContext("", "", "", 0)
	--reaper.ShowConsoleMsg("")
	--reaper.ShowConsoleMsg(window)
	--reaper.ShowConsoleMsg(segment)
	--reaper.ShowConsoleMsg(details)

	-- IF MOUSE OVER ITEM
	if window == "arrange" and details == "item" then
		mouse_item = reaper.BR_GetMouseCursorContext_Item()
		-- IF THE ITEM CAN HAVE TAKE
		mouse_take = reaper.GetActiveTake(mouse_item)
		if mouse_take ~= nil then
			mouse_take = reaper.BR_GetMouseCursorContext_Take()
			color_int = reaper.GetDisplayedMediaItemColor2(mouse_item, mouse_take)
		else -- elseif it's an empty/Text item
			color_int = reaper.GetDisplayedMediaItemColor(mouse_item)
		end

		-- IF HAS NO COLOR, GET TRACK COLOR
		if color_int == 0 then
			mouse_track = reaper.GetMediaItemTrack(mouse_item)
			color_int = reaper.GetMediaTrackInfo_Value(mouse_track, "I_CUSTOMCOLOR")
			--reaper.ShowConsoleMsg("track")
		end
	end

	-- IF MOUSE OVER TRACK
	if (window == "tcp" or window == "mcp") and segment == "track" then
		mouse_track = reaper.BR_GetMouseCursorContext_Track()
		color_int = reaper.GetMediaTrackInfo_Value(mouse_track, "I_CUSTOMCOLOR")
	end

	-- IF MOUSE INSIDE REGION OR AFTER MARKER
	if segment == "region_lane" or segment == "marker_lane" then
		mouse_pos = reaper.BR_GetMouseCursorContext_Position()
		markeridxOut, regionidxOut = reaper.GetLastMarkerAndCurRegion(0, mouse_pos)
		
		-- COLOR FROM REGION OR MARKER
		if segment == "region_lane" then
			idx = regionidxOut
		else
			idx = markeridxOut
		end

		retval, isrgnOut, posOut, rgnendOut, nameOut, markrgnindexnumberOut, color_int = reaper.EnumProjectMarkers3(0, idx)
	end

	-- COLORIZATION
	if color_int ~= nil then

		countItems = reaper.CountSelectedMediaItems(0)
		-- SELECTED ITEMS LOOP
		if countItems > 0 then
			for i = 0, countItems-1 do
				item = reaper.GetSelectedMediaItem(0, i)
				take = reaper.GetActiveTake(item)
				if take ~= nil then
					reaper.SetMediaItemTakeInfo_Value(take, "I_CUSTOMCOLOR", color_int)
				else
					reaper.SetMediaItemInfo_Value(item, "I_CUSTOMCOLOR", color_int)
				end
			end
		end

		countTracks = reaper.CountSelectedTracks(0)
		-- SELECTED TRACKS LOOP
		if countTracks > 0 then
			for j = 0, countTracks-1 do
				track = reaper.GetSelectedTrack(0, j)
				reaper.SetMediaTrackInfo_Value(track, "I_CUSTOMCOLOR", color_int)
			end
		end

		reaper.Undo_EndBlock("Set selected tracks, items and takes color from mouse context", 0)
	end
end

reaper.PreventUIRefresh(1)
main() -- Execute your main function
reaper.UpdateArrange() -- Update the arrangement (often needed)
reaper.PreventUIRefresh(-1)