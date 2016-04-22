--[[
 * ReaScript Name: Sort selected items order by item notes alphabetically keeping snap offset positions per tracks
 * Description: Reorder items on your track based on item notes.
 * Instructions: Select items. Run.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script: Script name
 * Forum Thread URI: http://forum.cockos.com/***.html
 * REAPER: 5.0 pre 15
 * Extensions: SWS/S&M 2.7.1 (optional)
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2015-06-09)
	+ Initial Release
--]]
 
 -- THANKS to heda for the multi-dimensional array syntax !

--[[ ----- DEBUGGING ====>
local info = debug.getinfo(1,'S');

local full_script_path = info.source

local script_path = full_script_path:sub(2,-5) -- remove "@" and "file extension" from file name

if reaper.GetOS() == "Win64" or reaper.GetOS() == "Win32" then
  package.path = package.path .. ";" .. script_path:match("(.*".."\\"..")") .. "..\\Functions\\?.lua"
else
  package.path = package.path .. ";" .. script_path:match("(.*".."/"..")") .. "../Functions/?.lua"
end

require("X-Raym_Functions - console debug messages")


debug = 1 -- 0 => No console. 1 => Display console messages for debugging.
clean = 1 -- 0 => No console cleaning before every script execution. 1 => Console cleaning before every script execution.

msg_clean()
]]-- <==== DEBUGGING -----

-- INIT
parent_tracks = {}
t = {}


-- INIT
count_sel_items_on_track = {}

-------------------------------------------------------------
function CountSelectedItems_OnTrack(track)
	
	count_items_on_track = reaper.CountTrackMediaItems(track)
	
	selected_item_on_track = 0
	
	for i = 0, count_items_on_track - 1  do

		item = reaper.GetTrackMediaItem(track, i)

		if reaper.IsMediaItemSelected(item) == true then
			selected_item_on_track = selected_item_on_track + 1
		end	

	end
	
	return selected_item_on_track

end

-------------------------------------------------------------
function GetSelectedItems_OnTrack(track_sel_id, idx)
	
	--track = reaper.GetSelectedTrack(0, track_sel_id)
	--msg("Track_sel_id = "..track_sel_id)
	--msg("idx = "..idx)
	--msg("sel_items_on_track = "..count_sel_items_on_track[ track_sel_id ])
	
	if idx < count_sel_items_on_track[ track_sel_id ] then
		offset = 0
		for m = 0, track_sel_id do
			----msg("m = "..m)
			previous_track_sel = count_sel_items_on_track[ m-1 ]
			if previous_track_sel == nil then previous_track_sel = 0 end
			offset =  offset + previous_track_sel
		end
		--msg("offset = "..offset)
		get_sel_item = init_sel_items[ offset + idx + 1]
	else
		get_sel_item = nil
	end
	
	return get_sel_item

end

-------------------------------------------------------------
function SelectTracksOfSelectedItems()

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

-------------------------------------------------------------
function MaxValTable(table)
	
	max_val = 0
	
	for i = 0, #table do
	
		val = table[i]
		if val > max_val then 
			max_val = val 
		end
	
	end
	
	return max_val

end
-------------------------------------------------------------
function debug(table)
	
	for i = 1, #table do

		msg("Val = " .. i .. "=>"..reaper.ULT_GetMediaItemNote(table[i]))
	
	end
	
	return max_val

end
-------
function msg(variable)		
		reaper.ShowConsoleMsg(tostring(variable).."\n")
end

-------------------------------------------------------------

-- SHUFFLE TABLE FUNCTION
-- from Tutorial: How to Shuffle Table Items by Rob Miracle
-- https://coronalabs.com/blog/2014/09/30/tutorial-how-to-shuffle-table-items/
math.randomseed( os.time() )

local function ShuffleTable( t )
	local rand = math.random 
	
	local iterations = #t
	local w
	
	for z = iterations, 2, -1 do
		w = rand(z)
		t[z], t[w] = t[w], t[z]
	end
end


function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	--reaper.Main_OnCommand(40297, 0) -- Unselect all tracks
	UnselectAllTracks()

	SelectTracksOfSelectedItems()

	selected_tracks_count = reaper.CountSelectedTracks(0)

		-- LOOP TRHOUGH SELECTED TRACKS
	for i = 0, selected_tracks_count - 1  do
		
		-- GET THE TRACK
		track = reaper.GetSelectedTrack(0, i) -- Get selected track i

		-- LOOP THROUGH ITEM IDX
		count_sel_items_on_track[i] = CountSelectedItems_OnTrack(track)
		
	end -- ENDLOOP through selected tracks
	
	
	-- MAXIMUM OF ITEM SELECTED ON A TRACK
	max_sel_item_on_track = MaxValTable(count_sel_items_on_track)
	
	-- STORE SELECTED ITEMS ABSOLUTE SNAP OF FIRST TRACK IN THEIR ACTUAL ORDER
	first_sel = {}
	first_track = reaper.GetSelectedTrack(0, 0)
	first_track_sel_count = CountSelectedItems_OnTrack(first_track)
	for i = 1, first_track_sel_count do
		
		item = GetSelectedItems_OnTrack(0, i-1)

		first_sel[i] = {}
		first_sel[i].item = item
		first_sel[i].snap = reaper.GetMediaItemInfo_Value(item, "D_SNAPOFFSET") + reaper.GetMediaItemInfo_Value(item, "D_POSITION")
	
	end
	
	-- LOOP TRHOUGH SELECTED TRACKS
	selected_tracks_count = reaper.CountSelectedTracks(0)

	for i = 0, 0 do
		-- GET THE TRACK
		track = reaper.GetSelectedTrack(0, i) -- Get selected track i

		count_items_on_track = reaper.CountTrackMediaItems(track)

		-- REINITILIAZE THE TABLE
		sel_items = {}
		pos = {}
		index = 1 

		-- LOOP THROUGH ITEMS ON TRACKS AND STORE SELECTED ITEMS (for later moving) AND OFFSET
		for j = 0, count_items_on_track - 1  do

			item = reaper.GetTrackMediaItem(track, j)

			if reaper.IsMediaItemSelected(item) == true then

				sel_items[index] = {}
				
				
				pos[index] = reaper.GetMediaItemInfo_Value(item, "D_SNAPOFFSET") + reaper.GetMediaItemInfo_Value(item, "D_POSITION")
				sel_items[index].item = item
				sel_items[index].note = reaper.ULT_GetMediaItemNote(item)
				sel_items[index].pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
				
				index = index + 1
				
			end	

		end

		-- SORT TABLE
		-- thanks to https://forums.coronalabs.com/topic/37595-nested-sorting-on-multi-dimensional-array/
		table.sort(pos)
		table.sort(sel_items, function( a,b )
			if (a.note < b.note) then
				-- primary sort on position -> a before b
				return true
			elseif (a.note > b.note) then
				-- primary sort on position -> b before a
				return false
			else
				-- primary sort tied, resolve w secondary sort on rank
				return a.pos < b.pos
			end
		end)
	
		-- LOOP THROUGH SELECTED ITEMS ON TRACKS
		for k = 1, index - 1 do
						
			--item_note = sel_items[k].note
			--reaper.ShowConsoleMsg(item_note)
			item = sel_items[k].item
			item_snap = reaper.GetMediaItemInfo_Value(item, "D_SNAPOFFSET")

			reaper.SetMediaItemInfo_Value(item, "D_POSITION", pos[k] - item_snap)
			
		end
		
	end -- ENDLOOP through selected tracks
	
	-- CALC OFFSET
	snap_offset = {}
	for i = 1, first_track_sel_count do
		
		item = first_sel[i].item
		
		item_snap = reaper.GetMediaItemInfo_Value(item, "D_SNAPOFFSET") + reaper.GetMediaItemInfo_Value(item, "D_POSITION")
		
		snap_offset[i-1] = item_snap - first_sel[i].snap
		
		--msg("Item "..i.." has moved from "..item_snap.." with an offset of ".. snap_offset[i-1])
	
	end
	
	-- LOOP COLUMN OF ITEMS ON TRACK
	for j = 0, first_track_sel_count - 1 do
	
		-- LOOP TRHOUGH SELECTED TRACKS
		for k = 1, selected_tracks_count - 1  do -- we start from track 2
			
			--msg("----\nTRACK SEL = "..k)
			
			-- LOOP THROUGH ITEM IDX
			item = GetSelectedItems_OnTrack(k, j)
			 if item ~= nil then -- it happens if there is more sel items on first track
				item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
			
				reaper.SetMediaItemInfo_Value(item, "D_POSITION", item_pos + snap_offset[j] )
			end
		end -- ENDLOOP through selected tracks
		
	end

	reaper.Undo_EndBlock("Sort selected items order by item notes alphabetically keeping snap offset positions per tracks", -1) -- End of the undo block. Leave it at the bottom of your main function.

end


-- The following functions may be passed as global if needed
--[[ ----- INITIAL SAVE AND RESTORE ====> ]]

-- ITEMS
-- SAVE INITIAL SELECTED ITEMS
init_sel_items = {}
local function SaveSelectedItems (table)
	for i = 0, reaper.CountSelectedMediaItems(0)-1 do
		table[i+1] = reaper.GetSelectedMediaItem(0, i)
	end
end

-- RESTORE INITIAL SELECTED ITEMS
local function RestoreSelectedItems (table)
	reaper.Main_OnCommand(40289, 0) -- Unselect all items
	for _, item in ipairs(table) do
		reaper.SetMediaItemSelected(item, true)
	end
end

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




--msg_start() -- Display characters in the console to show you the begining of the script execution.

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

--SaveView()
--SaveCursorPos()
--SaveLoopTimesel()
SaveSelectedItems(init_sel_items)
SaveSelectedTracks(init_sel_tracks)

main() -- Execute your main function

--RestoreCursorPos()
--RestoreLoopTimesel()
RestoreSelectedItems(init_sel_items)
RestoreSelectedTracks(init_sel_tracks)
--RestoreView()

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)

--msg_end() -- Display characters in the console to show you the end of the script execution.
