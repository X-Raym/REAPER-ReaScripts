--[[
 * ReaScript Name: Move selected items to end of previous items on all visible tracks
 * Description: Move group of selected items to previous item end on all visible tracks, according to min position of items in selection.
 * Instructions: Select items. Run.
 * Screenshot: http://i.giphy.com/xTiTnGR5CJ4m7RyvHW.gif
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Editing (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=163363
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.1
--]]
 
--[[
 * Changelog:
 * v1.1 (2015-09-10)
	+ Limit with marker name "LIMIT"
 * v1.0 (2015-09-09)
	+ Initial Release
--]]

-- ----- USER CONFIG AREA ====>

limit = true

-- <==== USER CONFIG AREA -----

-- INIT
sel_item = {}
max_end = 0

function GetLimitTime()
	i=0
	repeat
		iRetval, bIsrgnOut, iPosOut, iRgnendOut, sNameOut, iMarkrgnindexnumberOut, iColorOur = reaper.EnumProjectMarkers3(0,i)
		if iRetval >= 1 then
			if sNameOut == "LIMIT" then
				limit_time = iPosOut
			end
			i = i+1
		end
	until iRetval == 0
	
	if limit_time == nil then limit = false end
	
	return limit_time
end

function main()

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
	
	for i = 1, count_sel_items do
	
		sel_item[i] = reaper.GetSelectedMediaItem(0, i-1)
	
	end
	
	for z = 1, #sel_item do
	
		sel_item_pos = reaper.GetMediaItemInfo_Value(sel_item[z], "D_POSITION")
		
		if z == 1 then min_sel_item_pos = sel_item_pos end
		
		if sel_item_pos < min_sel_item_pos then
		
			min_sel_item_pos = sel_item_pos
		
		end
	
	end
	
	limit_time = GetLimitTime()
	
	count_tracks = reaper.CountTracks(0)
	
	for j = 1, count_tracks do
	
		track = reaper.GetTrack(0, j - 1)
		
		track_visible = reaper.IsTrackVisible(track, false) -- false => tcp
	
		if track_visible then
		
			count_items_on_track = reaper.GetTrackNumMediaItems(track)
			
			for k = 1, count_items_on_track do
			
				item = reaper.GetTrackMediaItem(track, k-1)
			
				item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
				item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
				item_end = item_pos + item_len
				
				if item_end > max_end and item_end < min_sel_item_pos then
					if limit == true then
						if item_end < limit_time then
							max_end = item_end
						end
					else
						max_end = item_end
					end
				
				end
			
			end
		
		end
	
	end
	
	offset = min_sel_item_pos - max_end
		
	for w = 1, #sel_item do
	
		sel_item_pos = reaper.GetMediaItemInfo_Value(sel_item[w], "D_POSITION")
				
		reaper.SetMediaItemInfo_Value(sel_item[w], "D_POSITION", sel_item_pos - offset)
	
	end
	
	reaper.Undo_EndBlock("Move selected items to end of previous items on all visible tracks", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

count_sel_items = reaper.CountSelectedMediaItems(0)

if count_sel_items > 0 then

	reaper.PreventUIRefresh(1)

	main() -- Execute your main function

	reaper.UpdateArrange() -- Update the arrangement (often needed)

	reaper.PreventUIRefresh(-1)
	
end