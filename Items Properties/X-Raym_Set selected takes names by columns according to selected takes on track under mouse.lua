--[[
 * ReaScript Name: Set selected takes names by columns according to selected takes on track under mouse
 * Description: A wa to rename selected tems by column, according to a reference track.
 * Instructions: Select items on several tracks. Mouse over a track with selected items. Run.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Properties (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1574814
 * REAPER: 5.0
 * Extensions: SWS 2.8.7
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2016-04-18)
	+ Initial Release
--]]

-- USER CONFIG AREA -------------------------------------

console = false -- true/false: activate/deactivate console messages

--------------------------------- END OF USER CONFIG AREA


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
function GetSelectedItems_OnTrackSelIdx(track_sel_id, idx)

	if idx < count_sel_items_on_track[ track_sel_id ] then
		offset = 0
		for m = 0, track_sel_id do
			----Msg("m = "..m)
			previous_track_sel = count_sel_items_on_track[ m-1 ]
			if previous_track_sel == nil then previous_track_sel = 0 end
			offset =  offset + previous_track_sel
		end
		--Msg("offset = "..offset)
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

		Msg("Val = " .. i .. "=>"..reaper.ULT_GetMediaItemNote(table[i]))

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

	-- Take Names
	take_names = {}
	for i = 0, mouse_track_sel_items_count - 1 do
		item = reaper.GetTrackMediaItem(mouse_track, i)
		if reaper.IsMediaItemSelected(item) then
			take = reaper.GetActiveTake(item)
			if take then
				take_names[i] = reaper.GetTakeName(take)
			end
		end
	end

	-- LOOP COLUMN OF ITEMS ON TRACK
	for j = 0, max_sel_item_on_track - 1 do

		Msg("\n*****\nCOLUMN = "..j)

		-- LOOP TRHOUGH SELECTED TRACKS
		for k = 0, selected_tracks_count - 1  do

			Msg("----\nTRACK SEL = "..k)

			-- LOOP THROUGH ITEM IDX
			item = GetSelectedItems_OnTrackSelIdx(k, j)
			if item then

				take = reaper.GetActiveTake(item)
				if take then

					if take_names[j] then
						retval, string = reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", take_names[j], true)
					end

				end

			end

		end -- ENDLOOP through selected tracks

	end

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
function RestoreSelectedItems (table)
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
function SaveSelectedTracks (table)
	for i = 0, reaper.CountSelectedTracks(0)-1 do
		table[i+1] = reaper.GetSelectedTrack(0, i)
	end
end

-- RESTORE INITIAL TRACKS SELECTION
function RestoreSelectedTracks (table)
	UnselectAllTracks()
	for _, track in ipairs(table) do
		reaper.SetTrackSelected(track, true)
	end
end


-- INIT
if console then
	reaper.ClearConsole()
end

count_sel_tems = reaper.CountSelectedMediaItems(0)
mouse_track, __, __ = reaper.BR_TrackAtMouseCursor()

if count_sel_tems > 1 and mouse_track then

	mouse_track_sel_items_count = CountSelectedItems_OnTrack(mouse_track)
	if mouse_track_sel_items_count > 0 then

		reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

		reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

		SaveSelectedItems(init_sel_items)
		SaveSelectedTracks(init_sel_tracks)

		main() -- Execute your main function

		RestoreSelectedItems(init_sel_items)
		RestoreSelectedTracks(init_sel_tracks)

		reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

		reaper.UpdateArrange() -- Update the arrangement (often needed)

		reaper.Undo_EndBlock("Set selected takes names by columns according to selected takes on track under mouse", -1) -- End of the undo block. Leave it at the bottom of your main function.

	end

end
