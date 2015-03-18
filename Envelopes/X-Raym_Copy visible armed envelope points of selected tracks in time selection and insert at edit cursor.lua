--[[
 * ReaScript Name: Copy visible armed envelope points of selected tracks in time selection and insert at edit cursor
 * Description: A way to copy paste multiple points envelope from the same track. Preserve original time selected envelope area, and value at destination area edges. In only works with visible armed tracks.
 * Instructions: Make a selection area. Place the edit cursor somewhere. Execute the script.
 * Author: X-Raym
 * Author URl: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URl: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URl: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script (LUA): Copy points envelopes in time selection and paste them at edit cursor
 * Forum Thread URl: http://forum.cockos.com/showthread.php?p=1497832#post1497832
 * Version: 1.0
 * Version Date: 2015-03-18
 * REAPER: 5.0 pre 18b
 * Extensions: None
 --]]
 
--[[
 * Changelog:
 * v1.0 (2015-03-18)
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

function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	-- GET CURSOR POS
	offset = reaper.GetCursorPosition()

	startLoop, endLoop = reaper.GetSet_LoopTimeRange2(0, false, true, 0, 0, false)
	lengthLoop = endLoop - startLoop

		-- LOOP TRHOUGH SELECTED TRACKS
		selected_tracks_count = reaper.CountSelectedTracks(0)
		for i = 0, selected_tracks_count-1  do
			
			-- GET THE TRACK
			track = reaper.GetSelectedTrack(0, i) -- Get selected track i

			-- LOOP THROUGH ENVELOPES
			env_count = reaper.CountTrackEnvelopes(track)
			for j = 0, env_count-1 do

				-- GET THE ENVELOPE
				env = reaper.GetTrackEnvelope(track, j)

				-- IF VISIBLE
				retval, strNeedBig = reaper.GetEnvelopeStateChunk(env, "", true)
				x, y = string.find(strNeedBig, "VIS 1")
				w, z = string.find(strNeedBig, "ARM 1")

				if x ~= nil and w ~= nil then
			
					env_points_count = reaper.CountEnvelopePoints(env)

					if env_points_count > 0 then
						
						max = offset+lengthLoop
						min = offset
						
						-- CLEAN THE DESTINATION AREA but don't touch the loop
						if max >= startLoop and max <= endLoop then
							max = startLoop
						end
						if min >= startLoop and min <= endLoop then
							min = endLoop
						end
						
						retval, valueOut, dVdSOutOptional, ddVdSOutOptional, dddVdSOutOptional = reaper.Envelope_Evaluate(env, startLoop, 0, 0)
						retval2, valueOut2, dVdSOutOptional2, ddVdSOutOptional2, dddVdSOutOptional2 = reaper.Envelope_Evaluate(env, endLoop, 0, 0)
						retval3, valueOut3, dVdSOutOptional3, ddVdSOutOptional3, dddVdSOutOptional3 = reaper.Envelope_Evaluate(env, offset, 0, 0)
						retval4, valueOut4, dVdSOutOptional4, ddVdSOutOptional4, dddVdSOutOptional4 = reaper.Envelope_Evaluate(env, max, 0, 0)
						retval5, valueOut5, dVdSOutOptional5, ddVdSOutOptional5, dddVdSOutOptional5 = reaper.Envelope_Evaluate(env, min, 0, 0)

						reaper.DeleteEnvelopePointRange(env, min, max)

						-- ADD POINTS ON LOOP START AND END AND CURSOR
						reaper.InsertEnvelopePoint(env, min, valueOut5, 0, 0, true, true) -- then insert point
						reaper.InsertEnvelopePoint(env, startLoop, valueOut, 0, 0, true, true) -- INSERT startLoop point
						reaper.InsertEnvelopePoint(env, endLoop, valueOut2, 0, 0, true, true) -- INSERT startLoop point
						if offset < startLoop or offset > endLoop then -- if cursor is outside the loop
							reaper.InsertEnvelopePoint(env, offset, valueOut3, 0, 0, true, true) -- then insert point
						end

						env_points_count = reaper.CountEnvelopePoints(env)
						
						-- LOOP THROUGH POINTS
						for k = 0, env_points_count-1 do 

							retval, time, valueOut, shape, tension, selectedOut = reaper.GetEnvelopePoint(env, k)

							-- UNSELECT ALL POINTS
							reaper.SetEnvelopePoint(env, k, timeInOptional, valueInOptional, shapeInOptional, tensionInOptional, false, true)
							if time == min or time == max then
								reaper.SetEnvelopePoint(env, k, timeInOptional, valueInOptional, shapeInOptional, tensionInOptional, true, true)
							end

							--IF the point is in selection area and if there is an envelope point
							if time >= startLoop and time <= endLoop then
								
								point_time = time - startLoop + offset

								-- IF POINT IS OUTSIDE THE LOOP
								if point_time <= startLoop or point_time >= endLoop then
									reaper.InsertEnvelopePoint(env, point_time, valueOut, shape, tension, true, true)
								end -- ENDIF point time would be paste in time selection

							end -- ENDIF in selected area
						
						end -- ENDIF points on the envelope
				
						reaper.InsertEnvelopePoint(env, max, valueOut4, 0, 0, true, true) -- then insert point
						reaper.Envelope_SortPoints(env)

					end -- ENDLOOP throught points
				
				end -- ENFIF visible
				
			end -- ENDLOOP through envelopes

		end -- ENDLOOP through selected tracks

		reaper.Undo_EndBlock("Copy visible armed envelope points of selected tracks in time selection and paste at edit cursor", 0) -- End of the undo block. Leave it at the bottom of your main function.

end -- end main()

--msg_start() -- Display characters in the console to show you the begining of the script execution.

--[[ reaper.PreventUIRefresh(1) ]]-- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

--[[ reaper.PreventUIRefresh(-1) ]] -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)

--msg_end() -- Display characters in the console to show you the end of the script execution.

-- make inserted points selected