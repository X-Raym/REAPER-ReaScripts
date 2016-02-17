--[[
 * ReaScript Name: Set selected audio takes gain by columns according to takes max peak
 * Description: Select audio takes on multile tracks. Run.
 * Instructions: Here is how to use it. (optional)
 * Screenshot: http://i.giphy.com/3o8doXnw0QskX4o1EI.gif
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: REQ: Copy & Paste Peak/RMS values of items to different items
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=169527
 * REAPER: 5.0
 * Extensions: spk77_Get take RMS.lua
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2015-12-30)
	+ Initial Release
--]]
 
-- USER CONFIG AREA -------------------------------------

console = true -- true/false: activate/deactivate console messages

--------------------------------- END OF USER CONFIG AREA


-- ----- DEBUGGING ====>
local info = debug.getinfo(1,'S');

local full_script_path = info.source

local script_path = full_script_path:sub(2,-5) -- remove "@" and "file extension" from file name

if reaper.GetOS() == "Win64" or reaper.GetOS() == "Win32" then
  package.path = package.path .. ";" .. script_path:match("(.*".."\\"..")") .. "..\\Functions\\?.lua"
else
  package.path = package.path .. ";" .. script_path:match("(.*".."/"..")") .. "../Functions/?.lua"
end

require("spk77_Get max peak val and pos from take_function")
-- <==== DEBUGGING -----

-- INIT
count_sel_items_on_track = {}

-------------------------------------------------------------
function HasItemActiveAudioTake(item)
	local answer = false
	local audio_take = nil
	
	if item ~= nil then
		local active_take = reaper.GetActiveTake(item)
		if active_take ~= nil then
			if reaper.TakeIsMIDI(active_take) == false then
				answer = true
				audio_take = active_take
			end
		end
	end	
	
	return answer, audio_take

end

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
function Msg(variable)
	if console == true then
		reaper.ShowConsoleMsg(tostring(variable).."\n")
	end
end

-------------------------------------------------------------
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
	
	--debug(init_sel_items)
	
	peak_values = {}
	item_take_vol = {}
	-- LOOP COLUMN OF ITEMS ON TRACK
	for j = 0, max_sel_item_on_track - 1 do
	
	msg("\n*****\nCOLUMN = "..j)
	
		-- LOOP TRHOUGH SELECTED TRACKS
		for k = 1, selected_tracks_count - 1  do
			
			msg("----\nTRACK SEL = "..k)
			
			-- LOOP THROUGH ITEM IDX
			item = GetSelectedItems_OnTrack(k, j)

			
			if item ~= nil then
				
				retval, take = HasItemActiveAudioTake(item)
			
				if retval then

					source_item = GetSelectedItems_OnTrack(0, j)
					
					retval, source_take = HasItemActiveAudioTake(source_item)
					
					if retval then
					
						--[[ REFERENCE
						retval, maximum peak value, maximum peak pos = get_sample_max_val_and_pos(MediaItem_Take, bool adj_for_take_vol, bool adj_for_item_vol, bool val_is_dB)
						--]]
						
						retval, peak_values, peak_pos = get_sample_max_val_and_pos( source_take, true, true, true )
						Msg("Source Peak: " .. peak_values)
						
						retval2, peak_values_dest, peak_pos_dest = get_sample_max_val_and_pos( take, true, true, true )						
						Msg("Dest Peak: " .. peak_values_dest)
						
						db_diff = peak_values - peak_values_dest
						Msg("dB diff: " ..db_diff)
						
						item_vol = reaper.GetMediaItemInfo_Value(item, "D_VOL")
						OldVolDB = 20*(math.log(item_vol, 10))
						calc = OldVolDB + db_diff
						valueIn = math.exp(calc*0.115129254)
						reaper.SetMediaItemInfo_Value(item, "D_VOL", valueIn)
						
					end
					
				end
				
			end
		
		end -- ENDLOOP through selected tracks
		

	end
	

	reaper.Undo_EndBlock("Set selected audio takes gain by columns according to takes max peak", -1) -- End of the undo block. Leave it at the bottom of your main function.

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


-- INIT
count_sel_tems = reaper.CountSelectedMediaItems(0)
if count_sel_tems > 2 then
	reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

	SaveSelectedItems(init_sel_items)
	SaveSelectedTracks(init_sel_tracks)
	
	if console == true then
		reaper.ClearConsole()
	end
	main() -- Execute your main function

	RestoreSelectedItems(init_sel_items)
	RestoreSelectedTracks(init_sel_tracks)

	reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

	reaper.UpdateArrange() -- Update the arrangement (often needed)
end