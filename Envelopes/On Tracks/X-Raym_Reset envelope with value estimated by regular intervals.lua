--[[
 * ReaScript Name: Reset envelope with value estimated by regular intervals
 * Description: A way to reset multiple envelopes according to some average value in time selection or according to the entire project.
 * Instructions: Select tracks with visible and armed envelopes. Set a time selection (optional). Run. Note that if there is an envelope selected, it will work only for it.
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
 * v1.0 (2015-07-20)
	+ Initial release
 --]]
 
-- ------ USER CONFIG AREA =====>

-- here you can customize the script
-- Envelope Output Properties
active_out = true -- true or false 
visible_out = true -- true or false. If active_out is false, then set visible to false too.
armed_out = true -- true or false

-- <===== USER CONFIG AREA ------

-- This script was requested and is sponsored by daxliniere !! Thanks :D
 
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

-- Count the number of times a value occurs in a table 
function table_count(tt, item)
  local count
  count = 0
  for ii,xx in pairs(tt) do
    if item == xx then count = count + 1 end
  end
  return count
end

-- Remove duplicates from a table array
function table_unique(tt)
  local newtable
  newtable = {}
  for ii,xx in ipairs(tt) do
    if(table_count(newtable, xx) == 0) then
      newtable[#newtable+1] = xx
    end
  end
  return newtable
end

function Msg(val)
	reaper.ShowConsoleMsg(tostring(val).."\n")
end

function Action(env)
	
	-- GET THE ENVELOPE
	br_env = reaper.BR_EnvAlloc(env, false)

	active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, type, faderScaling = reaper.BR_EnvGetProperties(br_env, true, true, true, true, 0, 0, 0, 0, 0, 0, true)

	-- IF ENVELOPE IS A CANDIDATE
	if visible == true and armed == true then
		
		-- OUTPUT VALUE ANALYSIS
		retval_eval, value_eval, dVdSOut_eval, ddVdSOut_eval, dddVdSOut_eval = reaper.Envelope_Evaluate(env, edit_pos, 0, 0)
		
		-- GET LAST POINT TIME OF DEST TRACKS AND DELETE ALL
		env_points_count = reaper.CountEnvelopePoints(env)
		if env_points_count > 1 then
			
			retval_last, time_last, valueSource_last, shape_last, tension_last, selectedOut_last = reaper.GetEnvelopePoint(env, env_points_count-1)
			
			if time_selection == true then
				iterations  = math.ceil((end_time - start_time) / interval) + 1
			else
				iterations = math.ceil(time_last / interval) + 1
			end
			
			value_eval = {} -- init table
			
			for m = 1, iterations do
				
				retval_eval, value_eval[m], dVdSOut_eval, ddVdSOut_eval, dddVdSOut_eval = reaper.Envelope_Evaluate(env, (m-1) * interval + start_time, 0, 0)
				
			end
			
			--value_copy = table.shallow_copy(value_eval)
			value_unique = table_unique(value_eval)
			
			max_occurences = 0
			for z = 1, #value_unique do
				occurences = table_count(value_eval, value_unique[z])
				if occurences > max_occurences then
					max_occurences = occurences
					max_value = value_unique[z]
				end
			end
			
			if max_occurences == 1 then
				--table.sort(value_unique)
				max_value = value_unique[1]
			end
			
			for p = 0, env_points_count-2 do
				
				reaper.BR_EnvDeletePoint(br_env, (env_points_count-1-p))
			
			end
		
		else
			retval, point_time, point_value, point_shape, point_tension, point_selected = reaper.GetEnvelopePoint(env, 0) -- can be move below
			max_value = point_value
		end
		
		reaper.BR_EnvSetPoint(br_env, 0, 0, max_value, 0, false, 0)
		--reaper.BR_EnvSetProperties(BR_Envelope envelope, boolean active, boolean visible, boolean armed, boolean inLane, integer laneHeight, integer defaultShape, boolean faderScaling)
		-- reaper.BR_EnvSetProperties(br_env, false, false, true, true, laneHeight, defaultShape, faderScaling)
		reaper.BR_EnvSetProperties(br_env, active_out, visible_out, armed_out, inLane, laneHeight, defaultShape, faderScaling)
	
	end
	
	reaper.BR_EnvFree(br_env, 1)
	reaper.Envelope_SortPoints(env)

end

function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
	
	edit_pos = reaper.GetCursorPosition()
	
	-- GET TIME SELECTION
	start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)

	-- IF TIME SELECTION
	if start_time ~= end_time then
		time_selection = true
		timesig_num, timesig_denom, bpm = reaper.TimeMap_GetTimeSigAtTime(0, start_time)
	else
		timesig_num, timesig_denom, bpm = reaper.TimeMap_GetTimeSigAtTime(0, edit_pos)
	end
	
	interval = bpm/1024
	
	-- LOOP TRHOUGH SELECTED TRACKS
	env = reaper.GetSelectedEnvelope(0)

	if env == nil then

		selected_tracks_count = reaper.CountSelectedTracks(0)
		
		-- if selected_tracks_count > 0 and UserInput() then
		if selected_tracks_count > 0 then
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
			
		end

	else
	
		Action(env)
		
	end -- endif sel envelope

	reaper.Undo_EndBlock("Reset envelope with value estimated by regular intervals", -1) -- End of the undo block. Leave it at the bottom of your main function.

end -- end main()

--msg_start() -- Display characters in the console to show you the begining of the script execution.

reaper.PreventUIRefresh(1)-- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)

--msg_end() -- Display characters in the console to show you the end of the script execution.