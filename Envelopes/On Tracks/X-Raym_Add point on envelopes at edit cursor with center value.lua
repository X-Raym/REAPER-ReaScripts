--[[
 * ReaScript Name: Add point on envelopes at edit cursor with center value
 * Description: A way to copy insert point on several tracks envelopes at one time.
 * Instructions: Place the edit cursor somewhere. Select a track. Execute the script.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script (LUA): Copy points envelopes in time selection and paste them at edit cursor
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1497832#post1497832
 * Version: 1.0
 * Version Date: 2015-03-21
 * REAPER: 5.0 pre 18b
 * Extensions: SWS 2.6.3 #0
--]]
 
--[[
 * Changelog:
 * v1.0 (2019-01-05)
	+ Initial release
--]]

function AddPoints(env)
		-- GET THE ENVELOPE
	br_env = reaper.BR_EnvAlloc(env, false)

	active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, type, faderScaling = reaper.BR_EnvGetProperties(br_env, true, true, true, true, 0, 0, 0, 0, 0, 0, true)

	if visible == true and armed == true then

		env_points_count = reaper.CountEnvelopePoints(env)

		if env_points_count > 0 then
			for k = 0, env_points_count+1 do 
				reaper.SetEnvelopePoint(env, k, timeInOptional, valueInOptional, shapeInOptional, tensionInOptional, false, true)
			end
		end
		
		-- IF THERE IS PREVIOUS POINT
		cursor_point = reaper.GetEnvelopePointByTime(env, offset)

		if cursor_point ~= -1 then

			--GET POINT VALUE
			retval, valueOut, dVdSOutOptional, ddVdSOutOptional, dddVdSOutOptional = reaper.Envelope_Evaluate(env, offset, 0, 0)
			
			-- ADD POINTS ON LOOP START AND END
			reaper.InsertEnvelopePoint(env, offset, centerValue, 0, 0, true, true) -- INSERT startLoop point

			reaper.BR_EnvFree(br_env, 0)
			reaper.Envelope_SortPoints(env)

		end -- ENDIF there is a previous point
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

reaper.Undo_EndBlock("Add point on envelopes at edit cursor with center value", 0) -- End of the undo block. Leave it at the bottom of your main function.

end -- end main()

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

reaper.TrackList_AdjustWindows(false)

reaper.UpdateArrange() -- Update the arrangement (often needed)

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.