--[[
 * ReaScript Name: Add envelope points at time selection edges from max to min
 * Description: Insert points at time selection edges.
 * Instructions: Make a selection area. Execute the script. Works on selected envelope or selected tracks envelope with armed visible envelope.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script (LUA): Copy points envelopes in time selection and paste them at edit cursor
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1497832#post1497832
 * Version: 1.1.1
 * Version Date: 2015-03-23
 * REAPER: 5.0 pre 18b
 * Extensions: 2.6.3 #0
--]]

--[[
* Changelog:
* v1.1.1 (2018-04-10)
	# FaderScaling support
 * v1.0 (2015-03-21)
	+ Initial release
--]]

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

		--retval, valueOut, dVdSOutOptional, ddVdSOutOptional, dddVdSOutOptional = reaper.Envelope_Evaluate(env, start_time, 0, 0)
		--retval2, valueOut2, dVdSOutOptional2, ddVdSOutOptional2, dddVdSOutOptional2 = reaper.Envelope_Evaluate(env, end_time, 0, 0)

		reaper.DeleteEnvelopePointRange(env, start_time-0.000000001, end_time+0.000000001)

		-- ADD POINTS ON LOOP START AND END
		--reaper.InsertEnvelopePoint(env, start_time, valueOut, 0, 0, 1, 0)
		reaper.InsertEnvelopePoint(env, start_time, maxValue, 0, 0, true, true)
		reaper.InsertEnvelopePoint(env, end_time, minValue, 0, 0, true, true)
		--reaper.InsertEnvelopePoint(env, end_time, valueOut2, 0, 0, 1, 0)

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

	reaper.Undo_EndBlock("Add envelope points at time selection edges from max to min", 0) -- End of the undo block. Leave it at the bottom of your main function.

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
