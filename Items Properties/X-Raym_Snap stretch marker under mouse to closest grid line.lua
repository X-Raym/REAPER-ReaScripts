--[[
 * ReaScript Name: Snap stretch marker under mouse to closest grid line
 * Description:
 * Instructions: Put this on a keyboard shortcut. Run.
 * Notes : Only work if take rate is 1. SWS issue.
 * Screenshot: http://i.giphy.com/l41m5L3XNjRhjDyww.gif
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: http://i.giphy.com/l41m5L3XNjRhjDyww.gif
 * Licence: GPL v3
 * Forum Thread: REQ: Snap stretch marker closest to mouse cursor to grid
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=166702
 * REAPER: 5.0
 * Extensions: SWS 2.9.1
 * Version: 1.1
--]]

--[[
 * Changelog:
 * v1.1 (2017-03-26)
	+ Works with group editing
 * v1.0.1 (2016-01-11)
	+ Initial Release
 * v1.0 (2015-09-23)
	+ Initial Release
--]]

function GetStretchMarkerAtPosition( take, pos )
	local retval = false
	for i = 0,  reaper.GetTakeNumStretchMarkers( take ) - 1 do
		local idx, posOut, srcpos = reaper.GetTakeStretchMarker( take, i )
		if posOut == pos then
			retval = idx
			break
		end
	end
	return retval, srcpos
end

function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
	
	window, segment, details = reaper.BR_GetMouseCursorContext()
	
	if details == "item_stretch_marker" then
		
		take, mouse_pos = reaper.BR_TakeAtMouseCursor()
		
		if take ~= nil then
				
			idx = reaper.BR_GetMouseCursorContext_StretchMarker()
			
			if idx ~= nil then
			
				reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
	
				idx, strech_pos, srcpos = reaper.GetTakeStretchMarker(take, idx)
				
				item = reaper.GetMediaItemTake_Item(take)
				item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
				
				rate = reaper.GetMediaItemTakeInfo_Value(take, "D_PLAYRATE")
				
				strech_pos = strech_pos / rate
				
				srcpos = (reaper.BR_GetClosestGridDivision(strech_pos+item_pos) - item_pos)*rate
				
				reaper.SetTakeStretchMarker(take, idx, srcpos)

				group_state = reaper.GetToggleCommandState(1156, 0)
				
				if group_state == 1 then
				
					-- Get Item Take
					item = reaper.GetMediaItemTake_Item( take )
					
					-- Get Group
					group = reaper.GetMediaItemInfo_Value( item, "I_GROUPID" )

					if group > 0 then
						
						-- Loop others item in in items group
						for j = 0, reaper.CountMediaItems( 0 ) - 1 do
							item_next = reaper.GetMediaItem( 0, j )

							group_next = reaper.GetMediaItemInfo_Value( item_next, "I_GROUPID" )

							if group_next == group then
								take_next = reaper.GetActiveTake( item_next )
								idx, srcpos = GetStretchMarkerAtPosition( take_next, strech_pos )
								if idx then
									reaper.SetTakeStretchMarker(take_next, idx, srcpos)
								end
							end
						end
					
					end
				
				end
			
			end
			
		end
				
	end
	
	reaper.Undo_EndBlock("Snap stretch marker under mouse to closest grid line", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

reaper.UpdateArrange() -- Update the arrangement (often needed)

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.
