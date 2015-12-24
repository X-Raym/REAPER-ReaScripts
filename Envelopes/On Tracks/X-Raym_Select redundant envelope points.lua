--[[
 * ReaScript Name: Select redundant envelope points
 * Description: A way to select points with similar value, in order to delete them or to randomize them for example.
 * Instructions: Select tracks with visible and armed envelopes. Execute the script. Note that if there is an envelope selected, it will work only for it.
 * Notes : Slope detection doesn't work on volume.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI:
 * Licence: GPL v3
 * Forum Thread: Scripts (Lua): Multiple Tracks and Multiple Envelope Operations
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=157483
 * REAPER: 5.0 RC5
 * Extensions: SWS 2.7.3 #0
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2015-08-21)
	+ Initial Release
 * v0.9 (2015-07-22)
	+ Slope
	+ Value Point at same time
 * v0.8 (2015-07-16)
	+ Initial Beta
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


function Msg(val)
	reaper.ShowConsoleMsg(tostring(val).."\n")
end

function Action(env)
	
	-- GET THE ENVELOPE
	retval, envelopeName = reaper.GetEnvelopeName(env, "envelopeName")
	br_env = reaper.BR_EnvAlloc(env, false)

	active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, type, faderScaling = reaper.BR_EnvGetProperties(br_env, true, true, true, true, 0, 0, 0, 0, 0, 0, true)

	-- IF ENVELOPE IS A CANDIDATE
	if visible == true and armed == true then

		-- LOOP THROUGH POINTS
		env_points_count = reaper.CountEnvelopePoints(env)

		if env_points_count > 1 then
			for k = 0, env_points_count-1 do -- loop from second point to before last)
				
				retval, point_time, value, shape, tension, selected = reaper.GetEnvelopePoint(env, k)
				
				if k == 0 then -- If first point of the envelope
					pre_value = value
					pre_point_time = 0
				else
					pre_retval, pre_point_time, pre_value, pre_shape, pre_tension, pre_selected = reaper.GetEnvelopePoint(env, k-1)
				end
				
				if k == env_points_count-1 then -- If last point of the envelope
					next_value = value
					next_point_time = point_time
				else
					next_retval, next_point_time, next_value, next_shape, next_tension, next_selected = reaper.GetEnvelopePoint(env, k + 1)
				end
				
				-- IF VOLUME ?
				--------------
				
				coef_pre = (value-pre_value)/(point_time-pre_point_time)
				
				coef_next = (next_value-value)/(next_point_time-point_time)
				
				if time_selection == true then
					if point_time >= start_time and point_time <= end_time then
						--if (value == pre_value and value == next_value) or (value == predicted_value) then
						if (value == pre_value and value == next_value) or (point_time == pre_point_time and point_time == next_point_time and k ~= env_points_count-1) or (tostring(coef_pre) == tostring(coef_next)) then
							reaper.SetEnvelopePoint(env, k, point_time, value, shape, tension, true, true)

						else
							reaper.SetEnvelopePoint(env, k, point_time, value, shape, tension, false, true)
							
						end
					
					else
						reaper.SetEnvelopePoint(env, k, point_time, value, shape, tension, false, true)
						
					end
				
				else
					--if (value == pre_value and value == next_value) or (value == predicted_value) then
					if (value == pre_value and value == next_value) or (point_time == pre_point_time and point_time == next_point_time and k ~= env_points_count-1) or (tostring(coef_pre) == tostring(coef_next)) then
						reaper.SetEnvelopePoint(env, k, point_time, value, shape, tension, true, true)
					else
						reaper.SetEnvelopePoint(env, k, point_time, value, shape, tension, false, true)
					end
				
				end
				
			end
		end
	
	end
	
	reaper.BR_EnvFree(br_env, 0)
	reaper.Envelope_SortPoints(env)

end

function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

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

			end -- ENDLOOP through envelopes

		end -- ENDLOOP through selected tracks

	else

		Action(env)
	
	end -- endif sel envelope

	reaper.Undo_EndBlock("Select redundant envelope points", -1) -- End of the undo block. Leave it at the bottom of your main function.

end -- end main()

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

reaper.PreventUIRefresh(-1)  -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)