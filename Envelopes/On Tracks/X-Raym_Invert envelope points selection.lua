--[[
 * ReaScript Name: Invert envelope points selection
 * Description: See title.
 * Instructions: Select tracks with visible and armed envelopes. Execute the script. Note that if there is an envelope selected, it will work only for it.
 * Screenshot: https://i.imgur.com/96tJFtD.gifv
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * Forum Thread: Scripts (Lua): Multiple Tracks and Multiple Envelope Operations
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=157483
 * REAPER: 5.0
 * Extensions: SWS 2.7.1 #0
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2017-12-17)
	+ Initial release
--]]

-- For hopi

function SetAtTimeSelection(env, k, point_time, value, shape, tension, sel)
	
	if time_selection then

		if point_time >= start_time and point_time <= end_time then
			reaper.SetEnvelopePoint(env, k, point_time, value, shape, tension, not sel, true)
		else
			reaper.SetEnvelopePoint(env, k, point_time, value, shape, tension, sel, true)
		end
	
	else
		reaper.SetEnvelopePoint(env, k, point_time, value, shape, tension, not sel, true)
	end
	
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

		if env_points_count > 0 then
			for k = 0, env_points_count-1 do 
				retval, point_time, value, shapeOut, tension, selected = reaper.GetEnvelopePoint(env, k)
				
				SetAtTimeSelection(env, k, point_time, value, shape, tension, selected)

			end
		end
		
		reaper.BR_EnvFree(br_env, 0)
		reaper.Envelope_SortPoints(env)
	
	end

end

function Main()

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

	reaper.Undo_EndBlock("Invert envelope point selection", 0) -- End of the undo block. Leave it at the bottom of your main function.

end -- end main()

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

Main() -- Execute your main function

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)
