--[[
 * ReaScript Name: Merge consecutive and short text items on selected tracks by pair with color
 * Description: Merge consecutive and short text items on selected tracks by pair with color. Useful for subtitlting.
 * Instructions: Select a track. Execute the script. It will work on text items only.
 * Author: X-Raym
 * Author URl: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URl: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URl: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Scripts (LUA): Create Text Items Actions (various)
 * Forum Thread URl: http://forum.cockos.com/showthread.php?t=156763
 * Version: 1.0
 * Version Date: 2015-03-12
 * REAPER: 5.0 pre 15
 * Extensions: SWS/S&M 2.6.2
 --]]
 
--[[
 * Changelog:
 * v1.0 (2015-03-12)
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

debug = 1 -- 0 => No console. 1 => Display console messages for debugging.
clean = 1 -- 0 => No console cleaning before every script execution. 1 => Console cleaning before every script execution.

msg_clean()
]]-- <==== DEBUGGING -----

function rtrim(s)
	local n = #s
	while n > 0 and s:find("^|", n) do n = n - 1 end
	return s:sub(1, n)
end

function string.ends(String,End)
	return End=='' or string.sub(String,-string.len(End))==End
end

function HeDaSetNote(item,newnote)  -- HeDa - SetNote v1.0
	-- X-Raym: prevent multiple lines note break and trim any trailing last empty line
	newnote = newnote:gsub("\n", "\n|")
	last_char = string.sub(newnote, -1)
	if last_char == "|" then
		newnote = rtrim(newnote)
	end
	
	--ref: Lua: boolean retval, string str reaper.GetSetItemState(MediaItem item, string str)
	retval, s = reaper.GetSetItemState(item, "")	-- get the current item's chunk
	--dbug("\nChunk=" .. s .. "\n")
	has_notes = s:find("<NOTES")  -- has notes?
	if has_notes then
		-- there are notes already
		chunk, note, chunk2 = s:match("(.*<NOTES\n)(.*)(\n>\nIMGRESOURCEFLAGS.*)")
		newchunk = chunk .. newnote .. chunk2
		--dbug(newchunk .. "\n")
		
	else
		--there are still no notes
		chunk,chunk2 = s:match("(.*IID%s%d+)(.*)")
		newchunk = chunk .. "\n<NOTES\n" .. newnote .. "\n>\nIMGRESOURCEFLAGS 0" .. chunk2
		--dbug(newchunk .. "\n")
	end
	reaper.GetSetItemState(item, newchunk)	-- set the new chunk with the note
end

function reset()
	B_item_text = ""
	B_item_start = 0
	B_item_end = 0
	B_item_color = 0
	merge_items = 0
	first_item_start = 0
	first = true
	item_mark_as_delete_lenght = 0
	group_id = 1
	A_group = 0
	B_group = 0
	item_end = 0
	j = 0
	in_group = false
end
--INIT
item_mark_as_delete = {}

function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	selected_tracks_count = reaper.CountSelectedTracks(0)

	if selected_tracks_count > 0 then

		for l = 0, selected_tracks_count-1  do
			
			reset()

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
					A_item_end = A_item_start + A_item_length + consecutive
					--msg_tvoldi("A_item_end =", A_item_end, "%f", 0, debug, 1)
					A_item_text = reaper.ULT_GetMediaItemNote(A_item)

					A_item_color = reaper.GetDisplayedMediaItemColor(A_item)

					if first == true then --If first item in the loop
						first = false -- le prochain item sera pas first
					end
					
					if first == false and A_item_start < B_item_end and  A_item_length <= short and A_item_color == B_item_color and in_group == false then -- Compare the name, the start-end, and the color of the current item and the previous one

						item_mark_as_delete_lenght = item_mark_as_delete_lenght + 1
						j = j + 1
						item_mark_as_delete[j] = A_item

						text_output = "|" .. B_item_text .. "\n" .. A_item_text
						HeDaSetNote(first_item, text_output)

						in_group = true
						
						if B_item_end > A_item_end then -- If the item is included inside the previous one
								A_item_end = B_item_end -- then consider that the end of the actual item is the end of previous one
						end

						if i == media_item_on_track-1 then -- If actual item is the last of the loop
							first_item_length = A_item_end - first_item_start
							--msg_tvoldi("item_length", A_item_end, "%f", 1, debug, 1)
							reaper.SetMediaItemInfo_Value(first_item, "D_LENGTH", first_item_length-consecutive)
						end

					else -- DIFFERENT GROUP
							
						if i > 0 and first == false then -- Si ce n'était pa sle premier item

							first_item_length = B_item_end - first_item_start
							--msg_tvoldi("B_item_end = ", B_item_end, "%f", 0, debug, 1)
							--msg_tvoldi("first_item_start = ", first_item_start, "%f", 0, debug, 1)

							--msg_tvoldi("first_item_length", A_item_end, "%f", 1, debug, 1)
							
							--msg_tvoldi("first_item_length", item_end, "%f", 1, debug, 1)
							
							if i == media_item_on_track-1 then -- If actual item is the last of the loop
							
								first_item_length = B_item_end - first_item_start
								--msg_tvoldi("first_item_length", A_item_end, "%f", 1, debug, 1)
							
							end

							reaper.SetMediaItemInfo_Value(first_item, "D_LENGTH", first_item_length-consecutive)
							group_id = group_id + 1
							
						end

						first = true
						first_item = A_item
						first_item_start = A_item_start
						in_group = false
						--msg_tvoldi("first_item_start = ", first_item_start, "%f", 0, debug, 1)

					end

					--msg_tvoldi("group_id = ", group_id, "%d", 0, debug, 1)
					
					-- "Previous item" infos for A/B comparaison
					B_item = A_item
					B_item_start = A_item_start
					B_item_length = A_item_length
					B_item_end = A_item_end
					B_item_text = A_item_text
					B_group = group_id
					B_item_color = A_item_color

					end -- END IF a text item

				end -- ENDLOOP through selected items

				--msg_tvoldi("item_mark_as_delete_lenght", item_mark_as_delete_lenght, "%d", 0, debug, 1)

				for j = 1, item_mark_as_delete_lenght do -- Loop throught item marked as "to be deleted"
					reaper.DeleteTrackMediaItem(track, item_mark_as_delete[j]) --track is always A
				end

				reaper.Undo_EndBlock("Merge consecutive and short text items on selected tracks by pair with color", 0) -- End of the undo block. Leave it at the bottom of your main function.
			
			else -- no selected item
				reaper.ShowMessageBox("No item on track " .. track_idx,"Warning",0)
			end -- if select item
		end -- end loop track
	else -- no selected track
		reaper.ShowMessageBox("Select a track before running the script","Please",0)
	end -- ENDIF a track is selected

end -- of main

defaultvals_csv = "0,0"
--msg_start() -- Display characters in the console to show you the begining of the script execution.
retval, retvals_csv = reaper.GetUserInputs("Merge Pair Options", 2, "Short?,Consecutive?", defaultvals_csv) 
			
if retval then -- if user complete the fields
	
	short, consecutive = retvals_csv:match("([^,]+),([^,]+)")

	if short ~= nil and consecutive ~= nil then
		short = math.abs(tonumber(short))
		consecutive = math.abs(tonumber(consecutive))
		
		reaper.PreventUIRefresh(1)

		main() -- Execute your main function

		reaper.PreventUIRefresh(-1)

		reaper.UpdateArrange() -- Update the arrangement (often needed)
	end

--msg_end() -- Display characters in the console to show you the end of the script execution.
end