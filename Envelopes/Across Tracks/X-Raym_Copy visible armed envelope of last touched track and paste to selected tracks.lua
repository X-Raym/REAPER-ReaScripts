--[[
 * ReaScript Name: Copy visible armed envelope of last touched tracks and paste to selected tracks
 * Description: A way to copy paste envelopes across tracks.
 * Instructions: Make a track selection. Touch a track. Have sure you have source and destination envelope armed and visible. It will copy point from source to destination if envelope name match.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script (LUA): Copy points envelopes in time selection and paste them at edit cursor
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1497832#post1497832
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.2
--]]
 
--[[
 * Changelog:
 * v1.2 (2015-10-05)
	# Propper send support
 * v1.1 (2015-03-18)
	+ Select new points
	+ Redraw envelope value at cursor pos in TCP (thanks to HeDa!)
 * v1.0 (2015-03-17)
	+ Initial release
--]]

-- INIT
time = {}
valueSource = {}
shape = {}
tension = {}
selectedOut = {}

function GetTrackEnvelopeSendName(track, env)
	
	local retval, env_name_temp = reaper.GetEnvelopeName(env, "")
	
	local send_type
	
	if env_name_temp == "Send Volume" then send_type = 0 end
	if env_name_temp == "Send Pan" then send_type = 1 end
	if env_name_temp == "Send Mute" then send_type = 2 end
	
	local num_sends = reaper.GetTrackNumSends(track, 0) -- 0 = sends

	for w = 0, num_sends - 1 do
		
		local env_send = reaper.BR_GetMediaTrackSendInfo_Envelope(track, 0, w, send_type)
		
		if env_send == env then
		
			local track_send = reaper.BR_GetMediaTrackSendInfo_Track(track, 0, w, 1)
			local retval, track_send_name = reaper.GetSetMediaTrackInfo_String(track_send, "P_NAME", "", false)

			env_name_temp = env_name_temp .. ": " .. track_send_name

		end

	end
	
	return env_name_temp

end

function main() -- local (i, j, item, take, track)

	-- GET LOOP
    start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
    -- IF LOOP ?
    if start_time ~= end_time then time_selection = true end

	-- GET AND UNSELECT LAST TRACK
	last_track = reaper.GetLastTouchedTrack()
	if reaper.IsTrackSelected(last_track) == true then
		reaper.SetTrackSelected(last_track, false)
		restore_sel = true
	end -- ENFIF last track is selected

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	-- LOOP THROUGH LAST TOUCHED TRACK ENVELOPES
	env_count = reaper.CountTrackEnvelopes(last_track)
	for j = 0, env_count-1 do

		-- GET THE ENVELOPE
		env = reaper.GetTrackEnvelope(last_track, j)

		-- IF VISIBLE AND ARMED
		retval, strNeedBig = reaper.GetEnvelopeStateChunk(env, "", true)
		x, y = string.find(strNeedBig, "VIS 1")
		w, z = string.find(strNeedBig, "ARM 1")

		if x ~= nil and w ~= nil then
		
			retval, env_name = reaper.GetEnvelopeName(env, "")
		
			-- IF SEND
			if env_name == "Send Pan" or env_name == "Send Mute" or env_name == "Send Volume" then
				env_name = GetTrackEnvelopeSendName(last_track, env)
			end

			-- SAVE LAST TOUCHED TRACK ENVELOPES POINTS
			env_points_count = reaper.CountEnvelopePoints(env)

			if env_points_count > 0 then

				-- LOOP THROUGH POINTS
				for k = 0, env_points_count-1 do 

					retval, time[k], valueSource[k], shape[k], tension[k], selectedOut[k] = reaper.GetEnvelopePoint(env, k)
				
				end -- ENDIF points on the envelope

			end -- ENDIF there was envelope envelope point

			-- LOOP TRHOUGH SELECTED TRACKS
			selected_tracks_count = reaper.CountSelectedTracks(0)
			for i = 0, selected_tracks_count-1  do
				
				-- GET THE TRACK
				track = reaper.GetSelectedTrack(0, i) -- Get selected track i

				env_count = reaper.CountTrackEnvelopes(track)
				for m = 0, env_count-1 do

					-- GET THE ENVELOPE
					env_dest = reaper.GetTrackEnvelope(track, m)
					retval, env_name_dest = reaper.GetEnvelopeName(env_dest, "")					
					
					-- IF SEND	
					if env_name_dest == "Send Pan" or env_name_dest == "Send Mute" or env_name_dest == "Send Volume" then
						env_name_dest = GetTrackEnvelopeSendName(track, env_dest)
					end
					
					-- IF VISIBLE AND ARMED
					retval, strNeedBig_dest = reaper.GetEnvelopeStateChunk(env_dest, "", true)
					a, c = string.find(strNeedBig_dest, "VIS 1")
					b, d = string.find(strNeedBig_dest, "ARM 1")

					if a ~= nil and b ~= nil and env_name_dest == env_name then

						-- GET LAST POINT TIME OF DEST TRACKS AND DELETE ALL
						env_points_count_dest = reaper.CountEnvelopePoints(env_dest)

						retval_last, time_last, valueSource_last, shape_last, tension_last, selectedOut_last = reaper.GetEnvelopePoint(env_dest, env_points_count_dest-1)
						
						if time_selection then
							reaper.DeleteEnvelopePointRange(env_dest, start_time, end_time)
							
							retval, valueOut, dVdSOutOptional, ddVdSOutOptional, dddVdSOutOptional = reaper.Envelope_Evaluate(env, start_time, 0, 0)
							retval2, valueOut2, dVdSOutOptional2, ddVdSOutOptional2, dddVdSOutOptional2 = reaper.Envelope_Evaluate(env, end_time, 0, 0)

							-- ADD POINTS ON LOOP START AND END
							reaper.InsertEnvelopePoint(env_dest, start_time, valueOut, 0, 0, true, true) -- INSERT start_time point
							reaper.InsertEnvelopePoint(env_dest, end_time, valueOut2, 0, 0, true, true) -- INSERT 
						else
							reaper.DeleteEnvelopePointRange(env_dest, 0, time_last+1)
						end

						-- LOOP IN STORED POINTS AND INSERT
						for p = 0, env_points_count-1 do
						
							if time_selection == true then
							
								if time[p] >= start_time and time[p] <= end_time then

									reaper.InsertEnvelopePoint(env_dest, time[p], valueSource[p], shape[p], tension[p], 1, true)

								end
							
							else
							
								reaper.InsertEnvelopePoint(env_dest, time[p], valueSource[p], shape[p], tension[p], true, true)
							
							end

						end -- END LOOP THROUGH SAVED POINTS

					end -- ENDIF envelope passed

					reaper.Envelope_SortPoints(env_dest)

				end -- end_time selected tracks envelope
			
			end -- end_time selected tracks

		end -- ENFIF visible
		
	end -- end_time through envelopes

	-- RESTORE LAST TRACK SELECTION
	if restore_sel == true then
		reaper.SetTrackSelected(last_track, true)
	end

	reaper.Undo_EndBlock("Copy visible armed envelope of last touched tracks and paste to selected tracks", -1) -- End of the undo block. Leave it at the bottom of your main function.

end -- end main()

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

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