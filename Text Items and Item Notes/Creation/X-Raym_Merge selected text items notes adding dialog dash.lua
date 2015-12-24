--[[
 * ReaScript Name: Merge selected text items notes adding dialog dash
 * Description: Use this action on text items. It will merge them in one item only, from first item position to last one end, preserving all notes one under the other, and adding dialog dash in front of each notes. This works for each tracks.
 * Instructions: Select items. Execute.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script: Scripts (LUA): Create Text Items Actions (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=156763
 * REAPER: 5.0 pre 32
 * Extensions: SWS/S&M 2.7.1
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2015-07-08)
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

function SelectTracksOfSelectedItems()
	UnselectAllTracks()

	-- LOOP THROUGH SELECTED ITEMS
	selected_items_count = reaper.CountSelectedMediaItems(0)
	
	-- INITIALIZE loop through selected items
	-- Select tracks with selected items
	for i = 0, selected_items_count - 1  do
		-- GET ITEMS
		item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i

		-- GET ITEM PARENT TRACK AND SELECT IT
		track = reaper.GetMediaItem_Track(item)
		reaper.SetTrackSelected(track, true)
		
	end -- ENDLOOP through selected items
	
end


function main()

	reaper.Undo_BeginBlock()

	SelectTracksOfSelectedItems()
	
	-- LOOP TRHOUGH SELECTED TRACKS
	for i = 0, reaper.CountSelectedTracks(0) - 1  do
		-- GET THE TRACK
		track = reaper.GetSelectedTrack(0, i) -- Get selected track i

		count_items_on_track = reaper.CountTrackMediaItems(track)

		-- REINITILIAZE THE TABLE
		item_to_delete = {}
		sel_items_on_tracks_end = 0
		first = false
		text_item_new = ""

		-- LOOP THROUGH ITEMS ON TRACKS AND STORE SELECTED ITEMS (for later moving) AND OFFSET
		for j = 0, count_items_on_track - 1  do

			item = reaper.GetTrackMediaItem(track, j)

			if reaper.IsMediaItemSelected(item) == true then

				if first == false then

					first_sel_item = item
					first = true

				end
				
				-- CHECK IF IT ITEM END IS AFTER PREVIOUS ITEM ENDS
				item_on_tracks_end = reaper.GetMediaItemInfo_Value(item, "D_POSITION") + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")

				if item_on_tracks_end > sel_items_on_tracks_end then

					sel_items_on_tracks_end = item_on_tracks_end

				end
				
				text_item = reaper.ULT_GetMediaItemNote(item)
				
				if j == 0 then
					text_item_new = "— " .. text_item
				else
					text_item_new = text_item_new .. "\n— ".. text_item
				end
				
				table.insert(item_to_delete, item)
				
			end	

		end

		for k = 2, #item_to_delete do

			reaper.DeleteTrackMediaItem(track, item_to_delete[k])

		end
		
		first_sel_item_pos = reaper.GetMediaItemInfo_Value(first_sel_item, "D_POSITION")

		reaper.BR_SetItemEdges(first_sel_item, first_sel_item_pos, sel_items_on_tracks_end)
		reaper.ULT_SetMediaItemNote(first_sel_item, text_item_new)
	
	end -- ENDLOOP through selected tracks

	reaper.Undo_EndBlock("Merge selected text items notes adding dialog dash", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

--[[ ----- INITIAL SAVE AND RESTORE ====> ]]

-- TRACKS
-- UNSELECT ALL TRACKS
function UnselectAllTracks()
	first_track = reaper.GetTrack(0, 0)
	reaper.SetOnlyTrackSelected(first_track)
	reaper.SetTrackSelected(first_track, false)
end

-- SAVE INITIAL TRACKS SELECTION
init_sel_tracks = {}
local function SaveSelectedTracks (table)
	for i = 0, reaper.CountSelectedTracks(0)-1 do
		table[i+1] = reaper.GetSelectedTrack(0, i)
	end
end

-- RESTORE INITIAL TRACKS SELECTION
local function RestoreSelectedTracks (table)
	UnselectAllTracks()
	for _, track in ipairs(table) do
		reaper.SetTrackSelected(track, true)
	end
end

--[[ <==== INITIAL SAVE AND RESTORE ----- ]]


-- ---------- INIT ==============> 
selected_items_count = reaper.CountSelectedMediaItems(0)

if selected_items_count > 0 then

	reaper.PreventUIRefresh(1)
	SaveSelectedTracks(init_sel_tracks)

	main() -- Execute your main function
	
	RestoreSelectedTracks(init_sel_tracks)
	reaper.PreventUIRefresh(-1)
	reaper.UpdateArrange() -- Update the arrangement (often needed)

end
