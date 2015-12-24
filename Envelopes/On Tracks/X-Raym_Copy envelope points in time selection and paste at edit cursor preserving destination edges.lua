--[[
 * ReaScript Name: Copy envelope points in time selection and paste at edit cursor preserving destination edges
 * Description: A way to copy paste multiple points envelope from the same track. Preserve original time selected envelope area. In only works with visible armed tracks.
 * Instructions: Make a selection area. Place the edit cursor somewhere. Execute the script.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script (LUA): Copy points envelopes in time selection and paste them at edit cursor
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1497832#post1497832
 * REAPER: 5.0 pre 18b
 * Extensions: SWS 2.6.3 #0
 * Version: 1.2.1
--]]
 
--[[
 * Changelog:
 * v1.2.1 (2015-05-07)
	# Time selection bug fix
 * v1.2 (2015-03-21)
	+ Selected envelope overides armed and visible envelope on selected track
 * v1.1 (2015-03-18)
	+ Select new points, unselect the other
	+ Redraw envelope value at cursor pos in TCP (thanks to HeDa!)
 * v1.0 (2015-03-17)
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

msg_clean()]]
-- <==== DEBUGGING -----

-- ----- CONFIG ====>

preserve_edges = true -- True will insert points à time selection edges before the action.

-- <==== CONFIG -----

function SetAtTimeSelection(env, k, point_time, value, shape, tension)
	
	if time_selection == true then

		if point_time > start_time and point_time < end_time then
			reaper.SetEnvelopePoint(env, k, point_time, valueIn, shape, tension, true, true)
		end
	
	else
		reaper.SetEnvelopePoint(env, k, point_time, valueIn, shape, tension, false, true)
	end
	
end

function Action(env)
	
	retval3, valueOut3, dVdSOutOptional3, ddVdSOutOptional3, dddVdSOutOptional3 = reaper.Envelope_Evaluate(env, start_time, 0, 0)
	retval4, valueOut4, dVdSOutOptional4, ddVdSOutOptional4, dddVdSOutOptional4 = reaper.Envelope_Evaluate(env, end_time, 0, 0)

	-- GET THE ENVELOPE
	retval, envelopeName = reaper.GetEnvelopeName(env, "envelopeName")
	br_env = reaper.BR_EnvAlloc(env, false)

	active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, type, faderScaling = reaper.BR_EnvGetProperties(br_env, true, true, true, true, 0, 0, 0, 0, 0, 0, true)

	-- IF ENVELOPE IS A CANDIDATE
	if visible == true and armed == true then

		-- LOOP THROUGH POINTS
		env_points_count = reaper.CountEnvelopePoints(env)

		if env_points_count > 0 then
			
			-- BEGIN ACTION
			-- CLEAN THE DESTINATION AREA
			lengthLoop = end_time - start_time

			max = offset+lengthLoop
			if max >= start_time and max <= end_time then
				max = start_time
			end

			min = offset
			if min >= start_time and min <= end_time then
				min = end_time
			end

			if preserve_edges == true then
				retval6, valueOut6, dVdSOutOptional6, ddVdSOutOptional6, dddVdSOutOptional6 = reaper.Envelope_Evaluate(env, max, 0, 0)
				retval5, valueOut5, dVdSOutOptional5, ddVdSOutOptional5, dddVdSOutOptional5 = reaper.Envelope_Evaluate(env, min, 0, 0)
			end

			reaper.DeleteEnvelopePointRange(env, min, max)

			-- LOOP THROUGH POINTS
			for k = 0, env_points_count+1 do

				-- UNSELECT ALL POINTS
				reaper.SetEnvelopePoint(env, k, timeInOptional, valueInOptional, shapeInOptional, tensionInOptional, false, true)
				if time == min or time == max then
					reaper.SetEnvelopePoint(env, k, timeInOptional, valueInOptional, shapeInOptional, tensionInOptional, true, true)
				end

				-- GET POINT INFOS
				retval, time, valueOut, shape, tension, selectedOut = reaper.GetEnvelopePoint(env, k)

				--IF the point is in selection area and if there is an envelope point
				if time >= start_time and time <= end_time then
					
					point_time = time - start_time + offset

					if point_time <= start_time or point_time >= end_time then
						reaper.InsertEnvelopePoint(env, point_time, valueOut, shape, tension, 1, true)
					end -- ENDIF point time would be paste in time selection

				end -- ENDIF in selected area

			end
		end

		if preserve_edges == true then
			reaper.InsertEnvelopePoint(env, min, valueOut5, 0, 0, true, true) -- INSERT start_time point
		end
			reaper.InsertEnvelopePoint(env, min, valueOut3, 0, 0, true, true) -- INSERT start_time point
			reaper.InsertEnvelopePoint(env, max, valueOut4, 0, 0, true, true) -- INSERT start_time point
		if preserve_edges == true then
			reaper.InsertEnvelopePoint(env, max, valueOut6, 0, 0, true, true) -- INSERT start_time point
		end
		
		reaper.BR_EnvFree(br_env, 0)
		reaper.Envelope_SortPoints(env)
	
	end

end

function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	-- GET CURSOR POS
	offset = reaper.GetCursorPosition()

	start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)

	if start_time ~= end_time then
		time_selection = true
	end
		
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

				Action(env)

			end -- end_time through envelopes

		end -- end_time through selected tracks

	else

		Action(env)
	
	end -- endif sel envelope

	reaper.Undo_EndBlock("Copy envelope points in time selection and paste at edit cursor preserving destination edges", 0) -- End of the undo block. Leave it at the bottom of your main function.

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