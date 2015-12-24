--[[
 * ReaScript Name: Trim selected tracks parameters values with envelopes values at edit cursor
 * Description: A way to convert envelope into track parameters. Use this script for tracks in Trim/Read mode.
 * Instructions: Select tracks with visible and armed envelopes. Execute the script. Note that if there is an envelope selected, it will work only for it.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI:
 * Licence: GPL v3
 * Forum Thread: Scripts (Lua): Multiple Tracks and Multiple Envelope Operations
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=157483
 * REAPER: 5.0
 * Extensions: SWS 2.8.0 #0
 * Version: 1.2
--]]
 
--[[
 * Changelog:
 * v1.2 (2015-09-09)
	+ Fader scaling support
 * v1.1.1 (2015-09-07)
	# Renamed
 * v1.1 (2015-09-01)
	# Width fix
 * v1.0 (2015-07-22)
	+ Initial release
 --]]
 
-- ----- DEBUGGING ====>
--[[
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

--[[
function UserInput()
	retval, user_input_str = reaper.GetUserInputs("Envelope Analysis", 1, "Interval ? (s)", interval) -- We suppose that the user know the scale he want
    if retval then
		interval = tonumber(user_input_str)
	end
	return retval
end
]]

function ConstrainInMinMax(val, minimum, maximum)
	if val < minimum then val = minimum end
	if val > maximum then val = maximum end
	return val
end

function AddDB(value_eval, init_value, max_value)
	value_eval_db = 20*(math.log(value_eval, 10)) -- thanks to spk77!
	init_value_db = 20*(math.log(init_value, 10)) -- thanks to spk77!
	maxValue_db = 20*(math.log(maxValue, 10)) + 6

	calc_db = value_eval_db + init_value_db
	
	-- this functions has its own constrain as max db in tracks (+12) is suppriori than max db in envelope (+6)
	if calc_db <= -146 then
		calc = 0
	end
	if calc_db > maxValue_db then
		calc = math.exp(maxValue_db*0.115129254)
	end
	if calc_db < maxValue_db and calc_db > -146 then
		calc = math.exp(calc_db*0.115129254)
	end
	return calc

end

function AddEnvValueToSend(track, env, param_name, value, minimum, maximum)
	
	num_sends = reaper.GetTrackNumSends(track, 0) -- 0 = sends

	for w = 0, num_sends - 1 do
		
		if param_name == "D_VOL" then send_type = 0 end
		if param_name == "D_PAN" then send_type = 1 end
		if param_name == "B_MUTE" then send_type = 2 end
		
		env_send = reaper.BR_GetMediaTrackSendInfo_Envelope(track, 0, w, send_type)
		
		if env_send == env then
		
			if param_name == "D_VOL" then
				init_value = reaper.BR_GetSetTrackSendInfo(track, 0, w, param_name, false, 0)
				new_value = AddDB(value, init_value, max_value)
			end

			if param_name == "D_PAN" then
				init_value = reaper.BR_GetSetTrackSendInfo(track, 0, w, param_name, false, 0)
				new_value = ConstrainInMinMax(init_value - value, minimum, maximum)-- Pan are set to their opposite (-) because on envelope, Pan Left = 1 and Pan Right = -1
			end
			
			if param_name == "B_MUTE" then
				-- reaper.BR_GetSetTrackSendInfo(track, 0, w, param_name, false, 0)
				new_value = value
			end
			
			reaper.BR_GetSetTrackSendInfo(track, 0, w, param_name, true, new_value)

		end

	end

end

function Msg(val)
	reaper.ShowConsoleMsg(tostring(val).."\n")
end

function Action(env, track)
	
	-- GET THE ENVELOPE
	br_env = reaper.BR_EnvAlloc(env, false)

	active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, env_type, faderScaling = reaper.BR_EnvGetProperties(br_env, true, true, true, true, 0, 0, 0, 0, 0, 0, true)

	-- IF ENVELOPE IS A CANDIDATE
	if visible == true and armed == true then
		
		if track == nil then
			track = reaper.BR_EnvGetParentTrack(br_env)
		end
		
		-- OUTPUT VALUE ANALYSIS
		retval_eval, value_eval, dVdSOut_eval, ddVdSOut_eval, dddVdSOut_eval = reaper.Envelope_Evaluate(env, edit_pos, 0, 0)
		
		retval, env_name = reaper.GetEnvelopeName(env, "")
			
		if env_name == "Volume"  then
			init_vol = reaper.GetMediaTrackInfo_Value(track, "D_VOL")
			if faderScaling == true then value_eval = reaper.ScaleFromEnvelopeMode(1, value_eval) end
			new_value = AddDB(value_eval, init_vol, maxValue)
			reaper.SetMediaTrackInfo_Value(track, "D_VOL", new_value)
		end
		
		if env_name == "Pan" then
			init_pan = reaper.GetMediaTrackInfo_Value(track, "D_PAN")
			new_value = ConstrainInMinMax(init_pan - value_eval, minValue, maxValue) -- Pan are set to their opposite (-) because on envelope, Pan Left = 1 and Pan Right = -1
			reaper.SetMediaTrackInfo_Value(track, "D_PAN", new_value)
		end
		
		if env_name == "Pan (Left)" then
			init_dualL = reaper.GetMediaTrackInfo_Value(track, "D_DUALPANL")
			new_value = ConstrainInMinMax(init_dualL - value_eval, minValue, maxValue)
			reaper.SetMediaTrackInfo_Value(track, "D_DUALPANL", new_value)
		end
		
		if env_name == "Pan (Right)" then
			init_dualR = reaper.GetMediaTrackInfo_Value(track, "D_DUALPANR")
			new_value = ConstrainInMinMax(init_dualR - value_eval, minValue, maxValue)
			reaper.SetMediaTrackInfo_Value(track, "D_DUALPANR", new_value)
		end

		if env_name == "Width" then
			init_width = reaper.GetMediaTrackInfo_Value(track, "D_WIDTH")
			new_value = ConstrainInMinMax(init_width * value_eval, minValue, maxValue)
			reaper.SetMediaTrackInfo_Value(track, "D_WIDTH", new_value)
		end
		
		if env_name == "Mute" then
			-- init_mute = reaper.GetMediaTrackInfo_Value(track, "B_MUTE")
			-- reaper.SetMediaTrackInfo_Value(track, "B_MUTE", value_eval + init_mute)
			reaper.SetMediaTrackInfo_Value(track, "B_MUTE", value_eval)
		end
		
		if env_name == "Send Volume" then
			param_name = "D_VOL"
			AddEnvValueToSend(track, env, param_name, value_eval)
		end
		
		if env_name == "Send Pan" then
			param_name = "D_PAN"
			AddEnvValueToSend(track, env, param_name, value_eval, minValue, maxValue)
		end
		
		if env_name == "Send Mute" then
			param_name = "B_MUTE"
			AddEnvValueToSend(track, env, param_name, value_eval, minValue, maxValue)
		end
	
	end
	
	reaper.BR_EnvFree(br_env, 0)
	reaper.Envelope_SortPoints(env)

end

function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
	
	edit_pos = reaper.GetCursorPosition()
	
	-- LOOP TRHOUGH SELECTED TRACKS
	env = reaper.GetSelectedEnvelope(0)

	if env == nil then

		selected_tracks_count = reaper.CountSelectedTracks(0)
		
		-- if selected_tracks_count > 0 and UserInput() then
		if selected_tracks_count > 0 then
			for i = 0, selected_tracks_count-1  do
				
				-- GET THE TRACK
				local track = reaper.GetSelectedTrack(0, i) -- Get selected track i

				-- LOOP THROUGH ENVELOPES
				env_count = reaper.CountTrackEnvelopes(track)
				for j = 0, env_count-1 do

					-- GET THE ENVELOPE
					env = reaper.GetTrackEnvelope(track, j)

					Action(env, track)

				end -- ENDLOOP through envelopes

			end -- ENDLOOP through selected tracks
			
		end

	else

		-- if UserInput() then
			Action(env)
		-- end
	
	end -- endif sel envelope

	reaper.Undo_EndBlock("Trim selected tracks parameters values with envelopes values at edit cursor", -1) -- End of the undo block. Leave it at the bottom of your main function.

end -- end main()

reaper.PreventUIRefresh(1)-- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)
