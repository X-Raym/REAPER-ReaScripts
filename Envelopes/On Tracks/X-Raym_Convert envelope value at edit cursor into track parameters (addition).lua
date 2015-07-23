--[[
 * ReaScript Name: Convert envelope value at edit cursor into track parameters (addition)
 * Description: A way to convert envelope into track parameters.
 * Instructions: Select tracks with visible and armed envelopes. Execute the script. Note that if there is an envelope selected, it will work only for it.
 * Author: X-Raym
 * Author URl: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URl: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URl:
 * Licence: GPL v3
 * Forum Thread: Scripts (Lua): Multiple Tracks and Multiple Envelope Operations
 * Forum Thread URl: http://forum.cockos.com/showthread.php?t=157483
 * REAPER: 5.0 RC5
 * Extensions: SWS 2.7.3 #0
 --]]
 
--[[
 * Changelog:
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
		
		init_value = reaper.GetMediaTrackInfo_Value(track, "D_VOL")
		
		-- OUTPUT VALUE ANALYSIS
		retval_eval, value_eval, dVdSOut_eval, ddVdSOut_eval, dddVdSOut_eval = reaper.Envelope_Evaluate(env, edit_pos, 0, 0)
		
		retval, env_name = reaper.GetEnvelopeName(env, "")
			--msg_stl("Envelope name", env_name, 1)
			--reaper.ShowConsoleMsg(env_name)
			
		if env_name == "Volume" or env_name == "Send Volume" then

			value_eval_db = 20*(math.log(value_eval, 10)) -- thanks to spk77!
			init_value_db = 20*(math.log(init_value, 10)) -- thanks to spk77!
			
			calc_db = value_eval_db + init_value_db

			if calc_db <= -146 then
				calc = 0
			end
			if calc_db >= 6 then
				calc = 2
			end
			if calc_db < 6 and calc_db > -146 then
				calc = math.exp(calc_db*0.115129254)
			end
			reaper.SetMediaTrackInfo_Value(track, "D_VOL", calc)
		
		end -- ENDIF Volume
		
		if env_name == "Pan" env_name == "Send Pan" then
			reaper.SetMediaTrackInfo_Value(track, "D_PAN", value_eval + init_value)
		end -- ENDIF Volume
		
		if env_name == "Mute" or env_name == "Send Mute" then
			reaper.SetMediaTrackInfo_Value(track, "B_MUTE", value_eval + init_value)
		end -- ENDIF Mute

		if env_name == "Width" then
			reaper.SetMediaTrackInfo_Value(track, "D_WIDTH", value_eval + init_value)
		end -- ENDIF Pan or Width
		
		if env_name == "Pan (Left)" then
			reaper.SetMediaTrackInfo_Value(track, "D_DUALPANL", value_eval + init_value)
		end
		
		if env_name == "Pan (Right)" then
			reaper.SetMediaTrackInfo_Value(track, "D_DUALPANR", value_eval + init_value)
		end
		
		-- reaper.BR_EnvSetPoint(br_env, 0, 0, value_eval, 0, false, 0)
		--reaper.BR_EnvSetProperties(BR_Envelope envelope, boolean active, boolean visible, boolean armed, boolean inLane, integer laneHeight, integer defaultShape, boolean faderScaling)
		-- reaper.BR_EnvSetProperties(br_env, false, false, true, true, laneHeight, defaultShape, faderScaling)
		-- reaper.BR_EnvSetProperties(br_env, active_out, visible_out, armed_out, inLane, laneHeight, defaultShape, faderScaling)
	
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

	reaper.Undo_EndBlock("Convert envelope value at edit cursor into track parameters (addition)", -1) -- End of the undo block. Leave it at the bottom of your main function.

end -- end main()

--msg_start() -- Display characters in the console to show you the begining of the script execution.

-- reaper.PreventUIRefresh(1)-- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

-- reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)

--msg_end() -- Display characters in the console to show you the end of the script execution.