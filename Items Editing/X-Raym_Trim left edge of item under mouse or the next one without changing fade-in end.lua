--[[
 * ReaScript Name: Trim left edge of item under mouse to edit cursor without changing fade-in end
 * Description: A way to expand selected mdia item length based on edit cursor and item under mouse.
 * Instructions: Place edit cursor before an item. Place the mouse hover an item. Execute the script with a shortcut. Not that this script is also able to move left item edges if edit cursor is inside item under mouse.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Scripts (EEL): Move L/R edge of item under mouse to edit cursor (with ripple edit)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=157698
 * REAPER: 5 pre 17
 * Extensions: SWS/S&M 2.6.3 #0
 * Version: 1.0
]]
 
--[[
 * Changelog:
 * v1.0 (2015-08-11)
	+ Initial Release
]]

function Msg(variable)
	reaper.ShowConsoleMsg(tostring(variable).."\n")
end

function SaveItemRipple()
	item_get_pos = reaper.GetMediaItemInfo_Value(item_get,"D_POSITION")

	if mouse_item_pos > item_get_pos then
		item[item_ar_len] = item_get
		item_ar_len = item_ar_len + 1
	end
end

--MAIN
function main()

	reaper.Undo_BeginBlock()

	mouse_item, mouse_pos = reaper.BR_ItemAtMouseCursor()

	if mouse_item == nil then -- Mouse in in arrange view

		mouse_track, track_context, mouse_pos = reaper.BR_TrackAtMouseCursor()
		
		if track_context == 2 then
		
			count_items_on_tracks = reaper.CountTrackMediaItems(mouse_track)
			
			for i = 0, count_items_on_tracks - 1 do
				
				mouse_item = reaper.GetTrackMediaItem(mouse_track, i)
				mouse_item_pos = reaper.GetMediaItemInfo_Value(mouse_item, "D_POSITION")
				
				if mouse_item_pos >= mouse_pos then
					break
				else
					mouse_item = nil
				end
			
			end
		
		end
		
	end
		
	if mouse_item ~= nil then
	
		reaper.SetMediaItemSelected(mouse_item, true)
	
		mouse_item_pos = reaper.GetMediaItemInfo_Value(mouse_item,"D_POSITION")
		edit_pos = reaper.GetCursorPosition()

		mouse_item_len = reaper.GetMediaItemInfo_Value(mouse_item,"D_LENGTH")
		mouse_item_end = reaper.GetMediaItemInfo_Value(mouse_item,"D_POSITION")
		mouse_item_snap = reaper.GetMediaItemInfo_Value(mouse_item,"D_SNAPOFFSET")

		mouse_item_end = mouse_item_pos + mouse_item_len
		offset = mouse_item_pos - edit_pos
		--offset = mouse_item_pos - mouse_pos
		
		track = reaper.GetMediaItem_Track(mouse_item)

		mouse_item_pos = reaper.GetMediaItemInfo_Value(mouse_item,"D_POSITION")

		if mouse_item_end > edit_pos then

			item = {}
			item_ar_len = 0

			--all = GetToggleCommandState(40311)
			--one = GetToggleCommandState(40310)
			ripple = reaper.SNM_GetIntConfigVar(projripedit, -666)

			if ripple == 2 then
			--all == 1 then
				count_media_items = reaper.CountMediaItems(0)

				for i = 0, count_media_items - 1 do 

					item_get = reaper.GetMediaItem(0, i)
						
					SaveItemRipple()

				end
			end
			
			if ripple == 1 then
			--one == 1 then
				count_item_on_track = reaper.CountTrackMediaItems(track)

				for i = 0, count_item_on_track - 1 do 

					item_get = reaper.GetTrackMediaItem(track, i)	
					
					SaveItemRipple()

				end
			
			end
			
			mouse_fade_get = reaper.GetMediaItemInfo_Value(mouse_item, "D_FADEINLEN")
			mouse_fade_absolute = mouse_item_pos + mouse_fade_get
			new_fadeout = (mouse_fade_absolute) - (mouse_item_pos - offset)
			
			reaper.SetMediaItemInfo_Value(mouse_item, "D_FADEINLEN", new_fadeout)
			
			mouse_take = reaper.GetActiveTake(mouse_item)

			mouse_take_off = reaper.GetMediaItemTakeInfo_Value(mouse_take, "D_STARTOFFS")

			reaper.SetMediaItemInfo_Value(mouse_item, "D_POSITION", mouse_item_pos - offset)
			reaper.SetMediaItemInfo_Value(mouse_item, "D_LENGTH", mouse_item_len + offset)
			reaper.SetMediaItemInfo_Value(mouse_item, "D_SNAPOFFSET", mouse_item_snap + offset)

			mouse_item_snap = reaper.GetMediaItemInfo_Value(mouse_item,"D_SNAPOFFSET")
			
			if mouse_item_snap < 0 then
				reaper.SetMediaItemInfo_Value(mouse_item, "D_SNAPOFFSET", 0)
			end

			reaper.SetMediaItemTakeInfo_Value(mouse_take, "D_STARTOFFS", mouse_take_off - offset)

			if ripple > 0 then
			--all == 1 || one == 1 then
				for j = 0, #item do 

					item_pos = reaper.GetMediaItemInfo_Value(item[j],"D_POSITION")
					calc = item_pos - offset
					if calc < 0 then calc = 0 end
					reaper.SetMediaItemInfo_Value(item[j], "D_POSITION", calc)

				end
			end
		
		end
		
		reaper.Undo_EndBlock("Trim left edge of item under mouse to edit cursor without changing fade-in end", -1)

		end

	end



reaper.PreventUIRefresh(1)

main()

reaper.UpdateArrange()

reaper.PreventUIRefresh(-1)