--[[
 * ReaScript Name: Add points before and after selected points
 * Description: A way to copy insert point on several tracks envelopes at one time.
 * Instructions: Select a track. Execute the script.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Scripts (Lua): Multiple Tracks and Multiple Envelope
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1499882
 * REAPER: 5.0
 * Extensions: SWS 2.8.1
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2015-09-16)
	+ Initial release
 --]]
 
-- ----- USER CONFIG AREA =====>

prev_value = 1 -- default value in seconds (positive number)
next_value = 1 -- default value in seconds (positive number)
prompt = true -- display a pop up (true/false)

--------------- USER CONFIG AREA

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

function AddPoints(env)
		-- GET THE ENVELOPE
	br_env = reaper.BR_EnvAlloc(env, false)

	active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, type, faderScaling = reaper.BR_EnvGetProperties(br_env, true, true, true, true, 0, 0, 0, 0, 0, 0, true)

	if visible == true and armed == true then

		env_points_count = reaper.CountEnvelopePoints(env)

		if env_points_count > 0 then
			
			new_points={}
			sel = 0
			
			for k = 0, env_points_count - 1 do
				
				-- GET POINT INFOS
				retval, pos, valueOut, shape, tension, selected = reaper.GetEnvelopePoint(env, k)
				
				if selected then
				
					sel = sel + 1
				
					prev_pos = pos - prev_value
					
					--GET POINT VALUE
					if prev_pos ~= 0 and prev_value ~= 0 then
						retval, valueOut, dVdSOutOptional, ddVdSOutOptional, dddVdSOutOptional = reaper.Envelope_Evaluate(env, prev_pos, 0, 0)
						
						new_points[sel]={}
						new_points[sel].time = prev_pos
						new_points[sel].value = valueOut
					end
					
					if next_value ~= 0 then
						
						next_pos = pos + next_value
					
						retval2, valueOut2, dVdSOutOptional2, ddVdSOutOptional2, dddVdSOutOptional2 = reaper.Envelope_Evaluate(env, next_pos, 0, 0)
						
						sel = sel + 1
						
						new_points[sel]={}
						new_points[sel].time = next_pos
						new_points[sel].value = valueOut2
					end
				
					reaper.SetEnvelopePoint(env, k, timeInOptional, valueInOptional, shapeInOptional, tensionInOptional, false, true)
				
				end
			
			end
			
			for v = 1, #new_points do
									-- ADD POINTS ON LOOP START AND END
					reaper.InsertEnvelopePoint(env, new_points[v].time, new_points[v].value, 0, 0, true, true) -- INSERT startLoop point
			end
		end

		reaper.BR_EnvFree(br_env, 0)
		reaper.Envelope_SortPoints(env)

	end
end

function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	-- GET CURSOR POS
	offset = reaper.GetCursorPosition()
		
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

reaper.Undo_EndBlock("Add points before and after selected points", -1) -- End of the undo block. Leave it at the bottom of your main function.

end -- end main()



reaper.PreventUIRefresh(1)-- Prevent UI refreshing. Uncomment it only if the script works.

if prompt == false then
	main() -- Execute your main function
else
	
	answer1 = tostring(prev_value)
	answer2 = tostring(next_value)
	
    retval, retvals_csv = reaper.GetUserInputs("Set points times", 2, "Next Point Time (s),Pre Point Time (s)", answer1..",".. answer2)  
    
    if retval == true then
      
		-- PARSE THE STRING
		prev_value, next_value = retvals_csv:match("([^,]+),([^,]+)")
		
		prev_value = tonumber(prev_value)
		next_value = tonumber(next_value)
		
		if prev_value ~= nil and next_value ~= nil then
		
			if prev_value < 0 then prev_value = - prev_value end
			if next_value < 0 then next_value = - next_value end
		
			main()
		
		end
	
	end

end

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)

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
