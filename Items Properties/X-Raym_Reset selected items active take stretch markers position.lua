--[[
 * ReaScript Name: Reset selected items active take stretch markers position
 * Description:
 * Instructions: Select items with take. Run.
 * Screenshot: http://i.giphy.com/3o85xowNTqf8CYQrba.gif
 * Author: X-Raym, MPL
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI:
 * Licence: GPL v3
 * Forum Thread: REQ: Reset stretch markers value
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=165774
 * REAPER: 5.0 pre 15
 * Extensions: None
 * Version: 1.2
--]]
 
--[[
 * Changelog:
 * v.1.2 (2019-06-08)
	# (MPL) fix reset stretch markers from end
	# (MPL) obey startoffset
 * v1.1 (2019-01-02)
	+ Also reset slope
 * v1.0 (2015-08-31)
	+ Initial Release
--]]

function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	-- LOOP THROUGH SELECTED TAKES
	selected_items_count = reaper.CountSelectedMediaItems(0)

	for i = 0, selected_items_count-1  do
		-- GET ITEMS
		item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i

		take = reaper.GetActiveTake(item) -- Get the active take

		if take ~= nil then -- if ==, it will work on "empty"/text items only
		
			strech_count = reaper.GetTakeNumStretchMarkers(take)
			local offs = reaper.GetMediaItemTakeInfo_Value( take, 'D_STARTOFFS' )
			for j = strech_count,0,-1 do
			
				idx, strech_pos, srcpos = reaper.GetTakeStretchMarker(take, j)
			
				reaper.SetTakeStretchMarker(take, idx, srcpos-offs)
				reaper.SetTakeStretchMarkerSlope( take, idx, 0)
				
			end

		end -- ENDIF active take
	
	end -- ENDLOOP through selected items

	reaper.Undo_EndBlock("Reset selected items active take stretch markers position", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)
