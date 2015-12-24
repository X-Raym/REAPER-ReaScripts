--[[
 * ReaScript Name: Find and go to next items on selected tracks with input text as notes
 * Description: A way to find a certain text in the project.
 * Instructions: Run. Enter text.
 * Screenshot: http://i.giphy.com/3oEdv3QtgRpelKaaNa.gif
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Scripts: View and Zoom (Various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=160800
 * REAPER: 5.0
 * Extensions: SWS/S&M 2.8.1
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2015-10-07)
  + Initial Release
 --]]

-- TO DO: MAke it Work with - chracter in search
-- make it save last search

function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	reaper.SelectAllMediaItems(0, false) -- Unselect all items

	edit_pos = reaper.GetCursorPosition()

	items = {}
	items_total = 0

	-- LOOP THROUGH TRACKS
	for i = 0, sel_tracks_count - 1 do

		track = reaper.GetSelectedTrack(0, i)

		count_items_tracks = reaper.GetTrackNumMediaItems(track)

		for j = 0, count_items_tracks - 1 do

			item = reaper.GetTrackMediaItem(track, j)

			items_total = items_total + 1

			items[items_total] = {}

			items[items_total].item = item
			items[items_total].pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")

		end

	end

	table.sort(items, function( a,b )
		if (a.pos < b.pos) then
				-- primary sort on position -> a before b
			return true
			elseif (a.pos > b.pos) then
				-- primary sort on position -> b before a
			return false
		else
			-- primary sort tied, resolve w secondary sort on rank
			return a.pos < b.pos
		end
	end)


	-- INITIALIZE loop through items
	for i = 1, #items do
		-- GET ITEMS
		item = items[i].item -- Get selected item i

		item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")

		if item_pos > edit_pos then
				-- GET NOTES
			notes = reaper.ULT_GetMediaItemNote(item)

			if notes ~= nil and notes ~= "" then

				x, y = string.find(notes, search)

				if x then

					reaper.SetEditCurPos(item_pos, true, true)

					reaper.SetMediaItemSelected(item, true)

					break

				end

			end

		end

	end -- ENDLOOP through selected items

	reaper.Undo_EndBlock("Find and go to next items on selected tracks with input text as notes", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

-- START
sel_tracks_count = reaper.CountSelectedTracks(0)

if sel_tracks_count > 0 then

	retval, search = reaper.GetUserInputs("Find and Go", 1, "Search (% for escape char)", "")

	if retval then -- if user complete the fields

		if search ~= nil and search ~= "" then

			reaper.PreventUIRefresh(1)

			main() -- Execute your main function

			reaper.PreventUIRefresh(-1)

			reaper.UpdateArrange() -- Update the arrangement (often needed)

		end

	end

end
