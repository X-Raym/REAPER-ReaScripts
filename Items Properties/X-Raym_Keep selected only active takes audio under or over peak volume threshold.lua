--[[
 * ReaScript Name: Keep selected only active audio takes under or over peak volume threshold
 * Description: See title
 * Instructions: Select items. Run.
 * Screenshot: http://i.imgur.com/nKlFUCZ.gifv
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI:
 * Licence: GPL v3
 * Forum Thread: REQ: Copy & Paste Peak/RMS values of items to different items
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=169527
 * REAPER: 5.0
 * Extensions: spk77_Get max peak val and pos from take_function.lua
 * Version: 1.0.1
--]]

--[[
 * Changelog:
 * v1.0.1 (2017-08-04)
	# Fix dependency path
 * v1.0 (2016-03-14)
	+ Initial Release
--]]

-- Sponsor by Mike Jackson

-- USER CONFIG AREA -----------------------------------------------------------

threshold = -10 -- number: Default threshold to select items
direction = "+" -- "+"/"-": Select if over or below the threshold

all_items = false

popup = true -- true/false: display a pop up box

console = false -- true/false: display debug messages in the console

------------------------------------------------------- END OF USER CONFIG AREA


-- INCLUDES -----------------------------------------------------------

local info = debug.getinfo(1,'S');
script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
dofile(script_path .. "../Functions/spk77_Get max peak val and pos from take_function.lua")

-------------------------------------------------------------- INCLUDES


-- UTILITIES -------------------------------------------------------------

-- Display a message in the console for debugging
function Msg(value)
	if console then
		reaper.ShowConsoleMsg(tostring(value) .. "\n")
	end
end


-- Save item selection
function SaveSelectedItems (table)
	for i = 0, reaper.CountSelectedMediaItems(0)-1 do
		table[i+1] = reaper.GetSelectedMediaItem(0, i)
	end
end


--------------------------------------------------------- END OF UTILITIES


-- Main function
function main()

	for i, item in ipairs(init_sel_items) do

		local take = reaper.GetActiveTake(item)

		if take then

			-- get_sample_max_val_and_pos(MediaItem_Take, bool adj_for_take_vol, bool adj_for_item_vol, bool val_is_dB)
			local ret, max_peak_val, peak_sample_pos = get_sample_max_val_and_pos(take, true, true, true)

			if ret then

				Msg(max_peak_val)

				if direction_string == "+" then
					if max_peak_val < threshold then
						reaper.SetMediaItemSelected(item, false)
					end
				else
					if max_peak_val > threshold then
						reaper.SetMediaItemSelected(item, false)
					end
				end

			end

		end

	end

end


-- INIT

if all_items then
	reaper.Main_OnCommand(40182, 0) -- Select all items
end

-- See if there is items selected
count_sel_items = reaper.CountSelectedMediaItems(0)

if count_sel_items > 0 then

	if popup then
		threshold_string = tostring(threshold)
		direction_string = tostring(direction)
		retval, retvals_csv = reaper.GetUserInputs("Set Volume Threshold", 2, "Threshold (dB),Under/Over (-/+)?", threshold_string .. "," .. direction_string)

		if retval then
			threshold_string, direction_string = retvals_csv:match("([^,]+),([^,]+)")

			if threshold_string then
				threshold = tonumber(threshold_string)
			end

		end

	end

	if (retval or not popup) and threshold then

		reaper.PreventUIRefresh(1)

		reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

		init_sel_items =  {}
		SaveSelectedItems(init_sel_items)

		main()

		reaper.Undo_EndBlock("Keep selected only active audio takes under or over peak volume threshold", -1) -- End of the undo block. Leave it at the bottom of your main function.

		reaper.UpdateArrange()

		reaper.PreventUIRefresh(-1)

	end

end
