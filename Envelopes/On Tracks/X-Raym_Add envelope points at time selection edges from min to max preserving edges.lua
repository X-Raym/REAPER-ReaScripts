--[[
 * ReaScript Name: Add envelope points at time selection edges from min to max preserving edges
 * Description: Insert points at time selection edges.
 * Instructions: Make a selection area. Execute the script. Works on selected envelope or selected tracks envelope with armed visible envelope.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Scripts (Lua): Multiple Tracks and Multiple Envelope Operations
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1499882
 * REAPER: 5.0 pre 18b
 * Extensions: 2.6.3 #0
 * Version: 1.2.4
--]]

--[[
 * Changelog:
 * v1.2.4 (2018-04-10)
 	# FaderScaling support
 * v1.2.3 (2015-08-22)
	# Bug fix
 * v1.2.2 (2015-07-10)
	# Bug fix
 * v1.2.1 (2015-05-07)
	# Time selection bug fix
 * v1.2 (2015-04-26)
	+ Better edges preservation
 * v1.1 (2015-03-23)
	+ Clean inside area
 * v1.0 (2015-03-21)
	+ Initial release
--]]

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

function AddPoints(env)
		-- GET THE ENVELOPE
	br_env = reaper.BR_EnvAlloc(env, false)

	active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, type, faderScaling = reaper.BR_EnvGetProperties(br_env, true, true, true, true, 0, 0, 0, 0, 0, 0, true)

	if visible == true and armed == true then

		if faderScaling == true then
			minValue = reaper.ScaleToEnvelopeMode(1, minValue)
			maxValue = reaper.ScaleToEnvelopeMode(1, maxValue)
			centerValue = reaper.ScaleToEnvelopeMode(1, centerValue)
		end

		env_points_count = reaper.CountEnvelopePoints(env)

		if env_points_count > 0 then
			for k = 0, env_points_count+1 do
				reaper.SetEnvelopePoint(env, k, timeInOptional, valueInOptional, shapeInOptional, tensionInOptional, false, true)
			end
		end

		first_start_val, last_start_val, first_end_val, last_end_val = GetDeleteTimeLoopPoints(env, env_points_count, start_time, end_time)


		reaper.InsertEnvelopePoint(env, start_time, first_start_val, 0, 0, true, true) -- INSERT startLoop point

		reaper.InsertEnvelopePoint(env, start_time, minValue, 0, 0, true, true)
		reaper.InsertEnvelopePoint(env, end_time, maxValue, 0, 0, true, true)

		reaper.InsertEnvelopePoint(env, end_time, last_end_val, 0, 0, true, true) -- INSERT startLoop point


		reaper.BR_EnvFree(br_env, 0)
		reaper.Envelope_SortPoints(env)
	end
end

function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	-- GET CURSOR POS
	offset = reaper.GetCursorPosition()

	-- GET TIME SELECTION EDGES
	start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)

	-- IF TIME SELECTION
	if start_time ~= end_time then

		-- ROUND LOOP TIME SELECTION EDGES
		start_time = math.floor(start_time * 100000000+0.5)/100000000
		end_time = math.floor(end_time * 100000000+0.5)/100000000

		-- LOOP TRHOUGH SELECTED TRACKS
		env = reaper.GetSelectedEnvelope(0)

		if env == nil then

			selected_tracks_count = reaper.CountSelectedTracks(0)
			for i = 0, selected_tracks_count-1  do

				-- GET THE TRACK
				track = reaper.GetSelectedTrack(0, i) -- Get selected track i

				-- LOOP THROUGH ENVELOPES
				env_count = reaper.CountTrackEnvelopes(track)
				for j = 0, env_count-1 do

					-- GET THE ENVELOPE
					env = reaper.GetTrackEnvelope(track, j)

					AddPoints(env)

				end -- ENDLOOP through envelopes

			end -- ENDLOOP through selected tracks

		else

			AddPoints(env)

		end -- endif sel envelope

	reaper.Undo_EndBlock("Add envelope points at time selection edges from min to max preserving edges", 0) -- End of the undo block. Leave it at the bottom of your main function.

	end-- ENDIF time selection

end -- end main()

--msg_start() -- Display characters in the console to show you the begining of the script execution.

--[[ reaper.PreventUIRefresh(1) ]]-- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

--[[ reaper.PreventUIRefresh(-1) ]] -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)

--msg_end() -- Display characters in the console to show you the end of the script execution.

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

HedaRedrawHack()
