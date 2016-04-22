--[[
 * ReaScript Name: Move selected items to next item on all visible tracks
 * Description: Move group of selected items to next item end on all visible tracks, according to max end of items in selection.
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
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2015-09-09)
	+ Initial Release
--]]

sel_item = {}
min_pos = 0
next_positions = {}
 
function main()

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
	
	for i = 1, count_sel_items do
	
		sel_item[i] = reaper.GetSelectedMediaItem(0, i - 1)
		
	end
	
	for z = 1, #sel_item do
	
		sel_item_pos = reaper.GetMediaItemInfo_Value(sel_item[z], "D_POSITION")
		sel_item_len = reaper.GetMediaItemInfo_Value(sel_item[z], "D_LENGTH")
		sel_item_end = sel_item_pos + sel_item_len
		
		if z == 1 then max_sel_item_end = sel_item_end end
		
		if sel_item_end > max_sel_item_end then
		
			max_sel_item_end = sel_item_end
		
		end
	
	end

	count_tracks = reaper.CountTracks(0)
	
	for j = 1, count_tracks do
	
		track = reaper.GetTrack(0, j - 1)
		
		track_visible = reaper.IsTrackVisible(track, false) -- false => tcp
	
		if track_visible then
		
			count_items_on_track = reaper.GetTrackNumMediaItems(track)
			
			for k = 1, count_items_on_track do
			
				item = reaper.GetTrackMediaItem(track, k-1)
			
				item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
				
				if item_pos > max_sel_item_end then
				
					table.insert(next_positions, item_pos)
				
				end
			
			end
		
		end
	
	end
	
	table.sort(next_positions)
	
	min_pos = next_positions[1]
	
	offset = min_pos - max_sel_item_end
		
	for w = 1, #sel_item do
	
		sel_item_pos = reaper.GetMediaItemInfo_Value(sel_item[w], "D_POSITION")
				
		reaper.SetMediaItemInfo_Value(sel_item[w], "D_POSITION", sel_item_pos + offset)
	
	end
	
	reaper.Undo_EndBlock("Move selected items to next item on all visible tracks", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

reaper.PreventUIRefresh(1)

count_sel_items = reaper.CountSelectedMediaItems(0)

if count_sel_items > 0 then
	
	main() -- Execute your main function
	
end

reaper.UpdateArrange() -- Update the arrangement (often needed)

reaper.PreventUIRefresh(-1)