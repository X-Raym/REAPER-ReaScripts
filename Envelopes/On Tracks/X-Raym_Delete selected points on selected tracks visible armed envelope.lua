--[[
 * ReaScript Name: Delete selected points on selected tracks visible armed envelope
 * Description:Delete selected points on selected tracks visible armed envelope
 * Instructions: Select points across envelopes and tracks. Execute the script. Selected points on visible armed track will be deleted.
 * Author: X-Raym
 * Author URl: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URl: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URl: 
 * Licence: GPL v3
 * Forum Thread: ReaScript: Set/Offset selected envelope points values
 * Forum Thread URl: http://forum.cockos.com/showthread.php?p=1487882#post1487882
 * REAPER: 5.0 pre 9
 * Extensions: SWS 2.6.3 #0
]]
 
--[[
 * Changelog:
 * v1.0 (2015-03-21)
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

-- ----- CONFIG ====>

preserve_edges = false -- True will insert points à time selection edges before the action.

-- <==== CONFIG -----

-- INIT
time = {}
valueSource = {}
shape = {}
tension = {}
selectedOut = {}

function main() -- local (i, j, item, take, track)

	-- GET LOOP
	start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, true, 0, 0, false)
	-- IF LOOP ?
	if start_time ~= end_time then
		time_selection = true
	end

	-- LOOP TRHOUGH SELECTED TRACKS
	selected_tracks_count = reaper.CountSelectedTracks(0)
	for j = 0, selected_tracks_count-1  do
		
		-- GET THE TRACK
		track = reaper.GetSelectedTrack(0, j) -- Get selected track i

		env_count = reaper.CountTrackEnvelopes(track)
		
		for m = 0, env_count-1 do

			-- GET THE ENVELOPE
			env = reaper.GetTrackEnvelope(track, m)
			--retval, env_name_dest = reaper.GetEnvelopeName(env, "")

			-- IF VISIBLE AND ARMED
			br_env = reaper.BR_EnvAlloc(env, false)
			active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, type, faderScaling = reaper.BR_EnvGetProperties(br_env, true, true, true, true, 0, 0, 0, 0, 0, 0, true)
			
			if visible == true and armed == true then

				if time_selection == true and preserve_edges == true then -- IF we want to preserve edges of time selection
					retval3, valueOut3, dVdSOutOptional3, ddVdSOutOptional3, dddVdSOutOptional3 = reaper.Envelope_Evaluate(env, start_time, 0, 0)
					retval4, valueOut4, dVdSOutOptional4, ddVdSOutOptional4, dddVdSOutOptional4 = reaper.Envelope_Evaluate(env, end_time, 0, 0)
				end -- preserve edges of time selection
				
				-- GET LAST POINT TIME OF DEST TRACKS AND DELETE ALL
				env_points_count = reaper.CountEnvelopePoints(env)

				-- LOOP POINTS AND INSERT
				for p = 0, env_points_count-1 do
					
					retval, time, valueSource, shape, tension, selectedOut = reaper.GetEnvelopePoint(env, env_points_count-1-p)
					--position, value, shape, selected, bezier = reaper.BR_EnvGetPoint(br_env, p, 0, 0, 0, true, 0)
					
					-- TAKE SELECTED
					if selectedOut == true then
						--reaper.ShowConsoleMsg(tostring(env_points_count-1-p))
						reaper.BR_EnvDeletePoint(br_env, (env_points_count-1-p))
					end
				end -- END LOOP THROUGH SAVED POINTS

				-- PRESERVE EDGES INSERTION
				if time_selection == true and preserve_edges == true then
					
					reaper.DeleteEnvelopePointRange(env, start_time-0.000000001, start_time+0.000000001)
					reaper.DeleteEnvelopePointRange(env, end_time-0.000000001, end_time+0.000000001)
					
					reaper.InsertEnvelopePoint(env, start_time, valueOut3, 0, 0, true, true) -- INSERT startLoop point
					reaper.InsertEnvelopePoint(env, end_time, valueOut4, 0, 0, true, true) -- INSERT startLoop point
				
				end

				reaper.BR_EnvFree(br_env, 1)
				reaper.Envelope_SortPoints(env)

			end -- ENDIF envelope passed

		end -- ENDLOOP selected tracks envelope
	
	end -- ENDLOOP selected tracks

end -- end main()

--msg_start() -- Display characters in the console to show you the begining of the script execution.

reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
main() -- Execute your main function
reaper.Undo_EndBlock("Delete selected points on selected tracks visible armed envelope", 0) -- End of the undo block. Leave it at the bottom of your main function.

reaper.UpdateArrange() -- Update the arrangement (often needed)

--msg_end() -- Display characters in the console to show you the end of the script execution.