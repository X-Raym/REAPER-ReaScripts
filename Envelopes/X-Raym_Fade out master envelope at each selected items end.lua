--[[
 * ReaScript Name: Fade out master envelope at each selected items end
 * Description: Create points at selected items position, end and end minus offset. Original value are keept except for the last one which goes -inf.
 * Instructions: Display master volume envelope. Write positive or negative value in the user input field.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: 
 * Licence: GPL v3
 * Forum Thread: Script (Lua): Scripts for Layering
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=159961
 * REAPER: 5.0 pre 36
 * Extensions: None
 * Version: 1.1
]]
 
--[[
 * Changelog:
 * v1.1 (2015-06-24)
	# Optimization
 * v1.0 (2015-06-09)
	+ Initial Release
]]

--[[ ----- DEBUGGING ===>
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

--msg_clean()
]]-- <=== DEBUGGING -----

function main(fade_len)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
	
	-- LOOP THROUGH SELECTED ITEMS
	count_sel_items = reaper.CountSelectedMediaItems(0)
	for i = 0, count_sel_items - 1 do
		
		-- GET ITEM
		item = reaper.GetSelectedMediaItem(0, i)
		
		-- GET ITEM INFOS
		item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
		item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
		item_end = item_pos + item_len
		
		-- CALC OFFSET
		offset = item_end - fade_len
		if offset < item_pos then offset = item_pos end
		
		-- GET ENV VAL AT START AND END
		retval_start, val_start, dVdS_start, ddVdS_start, dddVdS_start = reaper.Envelope_Evaluate(env, item_pos, 0, 0)
		retval_offset, val_offset, dVdS_offset, ddVdS_offset, dddVdS_offset = reaper.Envelope_Evaluate(env, offset, 0, 0)
		retval_end, val_end, dVdS_end, ddVdS_end, dddVdS_end = reaper.Envelope_Evaluate(env, item_end, 0, 0)
		
		-- CLEAN DESTINATION AREA
		reaper.DeleteEnvelopePointRange(env, item_pos-0.000000001, item_end+0.000000001)
		
		-- ADD POINTS
		reaper.InsertEnvelopePoint(env, item_pos, val_start, 0, 0, true, true)
		reaper.InsertEnvelopePoint(env, offset, val_start, 0, 0, true, true)
		reaper.InsertEnvelopePoint(env, item_end, 0, 0, 0, true, true)
		reaper.InsertEnvelopePoint(env, item_end, val_end, 0, 0, true, true)
		
		reaper.Envelope_SortPoints(env)
		
	end -- endloop sel items
	
	reaper.Undo_EndBlock("Fade out master envelope at each selected items end", -1) -- End of the undo block. Leave it at the bottom of your main function.
end -- END OF FUNCTION

--msg_start() -- Display characters in the console to show you the begining of the script execution.

-- GET MASTER INFOS
track_master = reaper.GetMasterTrack(0)
env = reaper.GetTrackEnvelopeByName(track_master, "Volume")

if env ~= nil then

	retval, user_input_str = reaper.GetUserInputs("Set fade length", 1, "Value ?", "") -- We suppose that the user know the scale he want
	if retval == true then
		fade_len = tonumber(user_input_str)
		if fade_len ~= nil and fade_len ~= 0 then
		
			fade_len = math.abs(fade_len)
			main(fade_len) -- Execute your main function

			reaper.UpdateArrange() -- Update the arrangement (often needed)
		end
	end

end

--msg_end() -- Display characters in the console to show you the end of the script execution.