--[[
 * ReaScript Name: Add envelope points at time selection edges from X to Y preserving edges on choosen envelope
 * Description: Insert points at time selection edges. You can deactivate the pop up window within the script.∑
 * Instructions: Make a selection area. Execute the script. Works on selected envelope or selected tracks envelope with armed visible envelope.
 * Screenshot: http://i.giphy.com/l0K7o2JPg4cpLr2Jq.gif
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: 
 * Licence: GPL v3
 * Forum Thread: Scripts (Lua): Multiple Tracks and Multiple Envelope Operations 
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1499882
 * REAPER: 5.0
 * Extensions: 2.8.3
 * Version: 1.4.2
--]]
 
--[[
 * Changelog:
 * v1.4.2 (2016-01_19)
 	+ Envelope scale types support (types: Volume, Pan/With, ReaSurround Gain)
 	+ "cursor" keyword for value
 	# No popup if necessary conditions are not here
 * v1.4.1 (2016-01-19)
	# Bug fixes
 * v1.4 (2016-01-18)
	+ Min, Max, Center in value input
	+ Conform input value to destination envelope
 * v1.3 (2016-01-18)
	+ Envelope Name in prompt
 * v1.2 (2016-01-18)
	+ Time offsets
 * v1.1 (2016-01-18)
	+ Optionnal infos in console
	+ Value Y
 * v1.0 (2016-01-17)
	+ Initial release
--]]


-- USER CONFIG AREA -----------------------

messages = true -- true/false : displai infos in console

valueIn_X = 3 -- number/string : destination value OR "max", "min", "center", "cursor"
valueIn_Y = 3

offset_X = 1 -- number (seconds) : offset time selection left (create a linear ramp between the two left points
offset_Y = 2 -- number (seconds) : offset time selection right (create a linear ramp between the two right points

prompt = true -- true/false : display a prompt window at script run

dest_env_name = "left  gain / ReaSurround" -- Name of the envelope

------------------- END OF USER CONFIG AREA



-- DEBUG -----------------------------------

-- Display Messages in the Console
function Msg(value)
	if messages == true then
		reaper.ShowConsoleMsg(tostring(value).."\n")
	end
end


--------------------------------END OF DEBUG



-- ENVELOPE FUNCTIONS ----------------------

-- Update points in time selection
function GetDeleteTimeLoopPoints(envelope, env_point_count, start_time, end_time)
	local set_first_start = 0
	local set_first_end = 0
	for i = 0, env_point_count do
		retval, time, valueOut, shape, tension, selectedOut = reaper.GetEnvelopePoint(envelope,i)
		
		if start_time == time and set_first_start == 0 then
			set_first_start = 1
			first_start_idx = i
			first_start_val = valueOut
		end
		if end_time == time and set_first_end == 0 then
			set_first_end = 1
			first_end_idx = i
			first_end_val = valueOut
		end
		if set_first_end == 1 and set_first_start == 1 then
			break
		end
	end

	local set_last_start = 0
	local set_last_end = 0
	for i = 0, env_point_count do
		retval, time, valueOut, shape, tension, selectedOut = reaper.GetEnvelopePoint(envelope,env_point_count-1-i)
		
		if start_time == time and set_last_start == 0 then
			set_last_start = 1
			last_start_idx = env_point_count-1-i
			last_start_val = valueOut
		end
		if end_time == time and set_last_end == 0 then
			set_last_end = 1
			last_end_idx = env_point_count-1-i
			last_end_val = valueOut
		end
		if set_last_start == 1 and set_last_end == 1 then
			break
		end
	end
	
	if first_start_val == nil then
		retval_start_time, first_start_val, dVdS_start_time, ddVdS_start_time, dddVdS_start_time = reaper.Envelope_Evaluate(envelope, start_time, 0, 0)
	end
	if last_end_val == nil then
		retval_end_time, last_end_val, dVdS_end_time, ddVdS_end_time, dddVdS_end_time = reaper.Envelope_Evaluate(envelope, end_time, 0, 0)
	end
	
	if last_start_val == nil then
		last_start_val = first_start_val
	end
	if first_end_val == nil then
		first_end_val = last_end_val
	end
	
	reaper.DeleteEnvelopePointRange(envelope, start_time-0.000000001, end_time+0.000000001)
			
	return first_start_val, last_start_val, first_end_val, last_end_val

end


-- Unselect all envelope points
function UnselectAllEnvelopePoints(envelope, env_points_count)
	
	-- UNSELECT POINTS
	if env_points_count > 0 then
		for k = 0, env_points_count+1 do 
			reaper.SetEnvelopePoint(envelope, k, timeInOptional, valueInOptional, shapeInOptional, tensionInOptional, false, true)
		end
	end

end


-- dB to Val
function ValFromdB(dB_val) return 10^(dB_val/20) end


-- Conform value
function ConformValueToEnvelope(number, envelopeType)
	
	-- Volume
	if envelopeType == 0 then
		number = ValFromdB(number)
	end
	
	-- Pan/Width
	if envelopeType == 2 then
		number = (-number)/100
	end

	-- ReaSurround Gain
	if envelopeType == 11 then
		number = 10^((number-12.0)/20)
	end
	
	return number

end


-- Get envelope scale type
function GetEnvelopeScaleType(envelopeName)

	local dest_env_type = -1

	-- Volume log
	if envelopeName == "Volume" or envelopeName == "Volume (Pre-FX)" or envelopeName == "Send Volume" then
		dest_env_type = 0
	end

	-- Pan/Width
	if envelopeName == "Width" or envelopeName == "Width (Pre-FX)" or envelopeName == "Pan" or envelopeName == "Pan (Pre-FX)" or envelopeName == "Pan (Left)" or envelopeName == "Pan (Right)" or envelopeName == "Pan (Left, Pre-FX)" or envelopeName == "Pan (Right, Pre-FX)" or envelopeName == "Send Pan" then
		dest_env_type = 2
	end

	-- ReaSurround gain
	if string.find(envelopeName, "gain / ReaSurround") ~= nil then
		dest_env_type = 11
	end

	return dest_env_type

end


-- Update the TCP envelope value at edit cursor position
function HedaRedrawHack()
	reaper.PreventUIRefresh(1)

	track=reaper.GetTrack(0,0)

	trackparam=reaper.GetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT")     
	if trackparam==0 then
		reaper.SetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT", 1)
	else
		reaper.SetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT", 0)
	end
	reaper.SetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT", trackparam)

	reaper.PreventUIRefresh(-1)
	
end


-------------------END OF ENVELOPE FUNCTIONS



-- MAIN FUNCTIONS --------------------------

-- Add Points
function AddPoints(env)
	
	-- GET THE ENVELOPE
	br_env = reaper.BR_EnvAlloc(env, false)

	active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, type, faderScaling = reaper.BR_EnvGetProperties(br_env, true, true, true, true, 0, 0, 0, 0, 0, 0, true)

	if visible == true and armed == true then
	
		env_points_count = reaper.CountEnvelopePoints(env)

		-- UNSELECT ENVELOPE POINTS
		UnselectAllEnvelopePoints(env, env_points_count)
		
		-- CLEAN TIME SELECTION
		first_start_val, last_start_val, first_end_val, last_end_val = GetDeleteTimeLoopPoints(env, env_points_count, start_time_offset, end_time_offset)
		

		-- EDIT CURSOR VALUE EVALUATION
		retval_cursor_time, cursor_val, dVdS_cursor_time, ddVdS_cursor_time, dddVdS_cursor_time = reaper.Envelope_Evaluate(env, cursor_pos, 0, 0)
		Msg("Value at Edit Cursor:")
		Msg(cursor_val)
		--

		-- INSERT RIGHT POINT
		reaper.InsertEnvelopePoint(env, start_time_offset, first_start_val, 0, 0, true, true) -- INSERT startLoop point
		
		-- CONFORM VALUE ACCORDING TO ENVELOPE
		valueOut_X = valueIn_X
		valueOut_Y = valueIn_Y
		
		if valueIn_X == "min" then valueOut_X = minValue end
		if valueIn_X == "max" then valueOut_X = maxValue end
		if valueIn_X == "center" then valueOut_X = centerValue end
		if valueIn_X == "cursor" then valueOut_X = cursor_val end
		if valueIn_Y == "min" then valueOut_Y = minValue end
		if valueIn_Y == "max" then valueOut_Y = maxValue end
		if valueIn_Y == "center" then valueOut_Y = centerValue end
		if valueIn_Y == "cursor" then valueOut_Y = cursor_val end

		-- SANITIZE VALUE X & Y
		if valueOut_X < minValue then valueOut_X = minValue end
		if valueOut_X > maxValue then valueOut_X = maxValue end
		if valueOut_Y < minValue then valueOut_Y = minValue end
		if valueOut_Y > maxValue then valueOut_Y = maxValue end

		-- FADER SCALE
		if env_scale == 1 then valueIn_X = reaper.ScaleToEnvelopeMode(1, valueOut_X) end
		if env_scale == 1 then valueIn_Y = reaper.ScaleToEnvelopeMode(1, valueOut_Y) end
		
		-- INSERT X & Y POINTS
		reaper.InsertEnvelopePoint(env, start_time, valueOut_X, 0, 0, true, true)
		reaper.InsertEnvelopePoint(env, end_time, valueOut_Y, 0, 0, true, true)
		
		-- INSERT RIGHT POINT
		reaper.InsertEnvelopePoint(env, end_time_offset, last_end_val, 0, 0, true, true) -- INSERT startLoop point

		-- RELEASE ENVELOPE
		reaper.BR_EnvFree(br_env, 0)
		reaper.Envelope_SortPoints(env)
	
	end

end



function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	-- GET CURSOR POS
	cursor_pos = reaper.GetCursorPosition()

	-- ROUND LOOP TIME SELECTION EDGES
	start_time = math.floor(start_time * 100000000+0.5)/100000000
	end_time = math.floor(end_time * 100000000+0.5)/100000000
	
	-- OFFSETS
	start_time_offset = start_time - offset_X
	end_time_offset = end_time + offset_Y
	
	-- LOOP TRHOUGH SELECTED TRACKS
	if env == nil then

		for i = 0, selected_tracks_count-1  do
			
			-- GET THE TRACK
			track = reaper.GetSelectedTrack(0, i) -- Get selected track i
			track_name_retval, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
			Msg("Track:")
			Msg(track_name)

			-- LOOP THROUGH ENVELOPES
			env_count = reaper.CountTrackEnvelopes(track)
			for j = 0, env_count-1 do

				-- GET THE ENVELOPE
				env = reaper.GetTrackEnvelope(track, j)
				
				retval, envName = reaper.GetEnvelopeName(env, "")
				if messages == true then
					Msg("Envelope #"..j.." :")
					Msg(envName)
				end
				if envName == dest_env_name then
					AddPoints(env)
				end
				
			end -- ENDLOOP through envelopes

		end -- ENDLOOP through selected tracks

	else

		retval, envName = reaper.GetEnvelopeName(env, "")
		if messages == true then 
			Msg("Selected envelope: ")
			Msg(envName)
		end
		if envName == dest_env_name then
			AddPoints(env)
		end
	
	end -- endif sel envelope

	reaper.Undo_EndBlock("Add envelope points at time selection edges from X to Y preserving edges on choosen envelope", -1) -- End of the undo block. Leave it at the bottom of your main function.

end -- end main()


-----------------------END OF MAIN FUNCTIONS



-- INIT ------------------------------------

-- GET SELECTED ENVELOPE
env = reaper.GetSelectedEnvelope(0)

-- COUNT SELECTED TRACKS
selected_tracks_count = reaper.CountSelectedTracks(0)

-- GET TIME SELECTION EDGES
start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)

-- IF TIME SELECTION
if start_time ~= end_time and (env ~= nil or selected_tracks_count > 0) then

	-- PROMPT
	if prompt then
	  valueIn_X = tostring(valueIn_X)
	  valueIn_Y = tostring(valueIn_Y)
	  retval, retvals_csv = reaper.GetUserInputs("Set Envelope Value", 5, "Envelope Name,Value X,Value Y,Time Offset X (s),Time Offset Y (s)", dest_env_name .. "," ..valueIn_X .. "," .. valueIn_Y .. "," .. offset_X .. "," .. offset_Y)
	end

	if retval or prompt == false then -- if user complete the fields
		
		if prompt then
			dest_env_name, valueIn_X, valueIn_Y, offset_X, offset_Y = retvals_csv:match("([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)")
		end
		
		if dest_env_name ~= nil and valueIn_X ~= nil and valueIn_Y ~= nil and offset_X ~= nil and offset_Y ~= nil then
			
			dest_env_type = GetEnvelopeScaleType(dest_env_name)

			if valueIn_X ~= "min" and valueIn_X ~= "max" and valueIn_X ~= "center" and valueIn_X ~= "cursor" then
				valueIn_X = tonumber(valueIn_X)
				valueIn_X = ConformValueToEnvelope(valueIn_X, dest_env_type)
			end
			
			if valueIn_Y ~= "min" and valueIn_Y ~= "max" and valueIn_Y ~= "center" and valueIn_Y ~= "cursor" then
				valueIn_Y = tonumber(valueIn_Y)
				valueIn_Y = ConformValueToEnvelope(valueIn_Y, dest_env_type)
			end
			
			offset_X = tonumber(offset_X)
			offset_Y = tonumber(offset_Y)

			if valueIn_X ~= nil and valueIn_Y ~= nil and offset_X ~= nil and offset_Y ~= nil then

				reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.
				
				if messages then reaper.ClearConsole() end

				main() -- Execute your main function

				reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

				reaper.UpdateArrange() -- Update the arrangement (often needed)

				HedaRedrawHack()

			end
		
		end

	end

end -- ENDIF time selection
