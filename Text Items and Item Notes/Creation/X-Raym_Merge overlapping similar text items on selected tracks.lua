--[[
 * ReaScript Name: Merge overlapping similar text items on selected tracks
 * Description: Merge overlapping similar text items on first selected tracks
 * Instructions: Select a track. Execute the script. It will work on text items only.
 * Author: X-Raym
 * Author URl: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URl: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URl: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script: Script name
 * Forum Thread URl: http://forum.cockos.com/***.html
 * Version: 1.1
 * Version Date: 2015-03-06
 * REAPER: 5.0 pre 15
 * Extensions: SWS/S&M 2.6.2
 --]]
 
--[[
 * Changelog:
 * v1.1 (2015-03-06)
	+ Multi tracks selection support
 * v1.0 (2015-02-27)
	+ Initial Release
 --]]

--[[ ----- DEBUGGING ====>
function get_script_path()
  if reaper.GetOS() == "Win32" or reaper.GetOS() == "Win64" then
    return debug.getinfo(1,'S').source:match("(.*".."\\"..")"):sub(2) -- remove "@"
  end
    return debug.getinfo(1,'S').source:match("(.*".."/"..")"):sub(2)
end

package.path = package.path .. ";" .. get_script_path() .. "?.lua"
require("X-Raym_Functions - console debug messages")

debug = 0 -- 0 => No console. 1 => Display console messages for debugging.
clean = 0 -- 0 => No console cleaning before every script execution. 1 => Console cleaning before every script execution.

msg_clean()
]]-- <==== DEBUGGING -----

--INIT
item_mark_as_delete = {}

function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	B_item_text = ""
	B_item_start = 0
	B_item_end = 0
	B_item_color = 0
	merge_items = 0
	item_start = 0
	B_track = 0
	first = true
	item_mark_as_delete_lenght = 0
	group_id = 1
	A_group = 0
	B_group = 0
	item_end = 0
	j = 0

	selected_tracks_count = reaper.CountSelectedTracks(0)

	if selected_tracks_count > 0 then

		for l = 0, selected_tracks_count-1  do
		-- GET THE TRACK
			track = reaper.GetSelectedTrack(0, l)
			track_idx = reaper.GetNumTracks()
			
			media_item_on_track = reaper.CountTrackMediaItems(track)

			if media_item_on_track > 0 then
			
				-- INITIALIZE loop through items on track
				for i = 0, media_item_on_track-1  do

				-- GET ITEMS
				A_item = reaper.GetTrackMediaItem(track, i) -- Get selected item i
				
				A_take = reaper.GetActiveTake(A_item)
				--msg_tvoldi("i", A_take, "%f", 1, debug, 1)

				if A_take == nil then -- If the item is a"text" item

					-- GET INFOS of current item
					A_item_start = reaper.GetMediaItemInfo_Value(A_item, "D_POSITION")
					--msg_tvoldi("A_item_start = ", A_item_start, "%f", 0, debug, 1)
					A_item_length = reaper.GetMediaItemInfo_Value(A_item, "D_LENGTH")
					--msg_tvoldi("A_item_length = ", A_item_length, "%f", 0, debug, 1)
					A_item_end = A_item_start + A_item_length
					--msg_tvoldi("A_item_end =", A_item_end, "%f", 0, debug, 1)
					A_item_text = reaper.ULT_GetMediaItemNote(A_item)
					A_item_color = reaper.GetDisplayedMediaItemColor(A_item)
					A_track = reaper.GetMediaItem_Track(A_item)

					if i == 0 then --If first item in the loop
						first_item = A_item
						item_start = A_item_start
						first = false -- le prochain item sera pas first
					end
					
					if A_track == B_track and A_item_text == B_item_text and A_item_start < B_item_end and A_item_color == B_item_color then -- Compare the name, the start-end, and the color of the current item and the previous one
						if first == true then -- If it is the first item of a group
							--msg_s("First")
							first_item = B_item

							item_start = B_item_start
							--msg_tvoldi("item_start = ", item_start, "%f", 1, debug, 1)
							item_mark_as_delete_lenght = item_mark_as_delete_lenght + 1
							j = j + 1
							item_mark_as_delete[j] = A_item
							first = false -- le prochain item sera pas first
						else -- SAME GROUP but not first

							item_mark_as_delete_lenght = item_mark_as_delete_lenght + 1
							j = j + 1
							item_mark_as_delete[j] = A_item
							
						end -- END of check if first or no
						
						if B_item_end > A_item_end then -- If the item is included inside the previous one
								A_item_end = B_item_end -- then consider that the end of the actual item is the end of previous one
						end

						group_id = group_id -- keep the same group (not required but it helps)

					else -- DIFFERENT GROUP
						
						if i > 0 then -- IF not the first item in the loop
							
							item_length = B_item_end - item_start
							--msg_tvoldi("item_length", A_item_end, "%f", 1, debug, 1)
							item_end = item_start + item_length
							--msg_tvoldi("item_length", item_end, "%f", 1, debug, 1)
							reaper.SetMediaItemInfo_Value(first_item, "D_LENGTH", item_length)
							group_id = group_id + 1
							
							first = true
						end

					end

					--msg_tvoldi("group_id = ", group_id, "%d", 0, debug, 1)
					
					-- "Previous item" infos for A/B comparaison
					B_item = A_item
					B_item_start = A_item_start
					B_item_length = A_item_length
					B_item_end = A_item_end
					B_item_text = A_item_text
					B_item_color = A_item_color
					B_track = A_track
					B_group = group_id
					item_end = B_item_end

					if i == media_item_on_track-1 then -- If actual item is the last of the loop
							item_length = B_item_end - item_start
							--msg_tvoldi("item_length", A_item_end, "%f", 1, debug, 1)
							item_end = item_start + item_length
							--msg_tvoldi("item_length", item_end, "%f", 1, debug, 1)
							reaper.SetMediaItemInfo_Value(first_item, "D_LENGTH", item_length)
							group_id = group_id + 1
					end

					end -- END IF a text item

				end -- ENDLOOP through selected items

				--msg_tvoldi("item_mark_as_delete_lenght", item_mark_as_delete_lenght, "%d", 0, debug, 1)

				for j = 1, item_mark_as_delete_lenght do -- Loop throught item marked as "to be deleted"
					reaper.DeleteTrackMediaItem(track, item_mark_as_delete[j]) --track is always A
				end

				reaper.Undo_EndBlock("Merge overlapping similar text items on first selected track", 0) -- End of the undo block. Leave it at the bottom of your main function.
			
			else -- no selected item
				reaper.ShowMessageBox("No item on track " .. track_idx,"Warning",0)
			end -- if select item
		end -- end loop track
	else -- no selected track
		reaper.ShowMessageBox("Select a track before running the script","Please",0)
	end -- ENDIF a track is selected

end -- of main

--msg_start() -- Display characters in the console to show you the begining of the script execution.

main() -- Execute your main function

reaper.UpdateArrange() -- Update the arrangement (often needed)

--msg_end() -- Display characters in the console to show you the end of the script execution.

-- idea make it work for each selected track