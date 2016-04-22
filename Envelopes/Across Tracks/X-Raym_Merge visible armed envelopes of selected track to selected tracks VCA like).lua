--[[
 * ReaScript Name: Merge visible armed envelopes of selected track to selected tracks VCA like)
 * Description: A way to copy paste envelopes across tracks.
 * Instructions: Make a track selection. Touch a track. Have sure you have source and destination envelope armed and visible. It will copy point from source to destination if envelope name match.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Scripts (Lua): Across Tracks Envelopes Operations
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1499998#post1499998
 * REAPER: 5.0
 * Extensions: SWS 2.8.0
 * Version: 1.1
--]]
 
--[[
 * Changelog:
 * v1.1 (2015-09-09)
	+ Fader scaling support
 * v1.0 (2015-07-14)
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

-- INIT
--[[
envLast_time = {}
envLast_valueSource = {}
envLast_shape = {}
envLast_tension = {}
envLast_selectedOut = {}
]]

function main() -- local (i, j, item, take, track)

	-- GET AND UNSELECT LAST TRACK
	last_track = reaper.GetLastTouchedTrack()
	if last_track == nil then last_track = reaper.GetSelectedTrack(0, 0) end
	if reaper.IsTrackSelected(last_track) == true then
		reaper.SetTrackSelected(last_track, false)
		restore_sel = true
	end -- ENFIF last track is selected

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	-- LOOP THROUGH LAST TOUCHED TRACK ENVELOPES
	env_count = reaper.CountTrackEnvelopes(last_track)
	for j = 0, env_count-1 do

		-- GET THE ENVELOPE
		envLast = reaper.GetTrackEnvelope(last_track, j)
		br_envLast = reaper.BR_EnvAlloc(envLast, false)
		
		retval_last_name, envLast_name = reaper.GetEnvelopeName(envLast, "")

		last_env_active, last_env_visible, last_env_armed, last_env_inLane, last_env_laneHeight, last_env_defaultShape, last_env_minValue, last_env_maxValue, last_env_centerValue, last_env_type, last_env_faderScaling = reaper.BR_EnvGetProperties(br_envLast, true, true, true, true, 0, 0, 0, 0, 0, 0, true)

		-- IF ENVELOPE IS A CANDIDATE
		if last_env_visible == true and last_env_armed == true then

			-- LOOP TRHOUGH SELECTED TRACKS
			selected_tracks_count = reaper.CountSelectedTracks(0)
			for i = 0, selected_tracks_count-1  do
				
				-- GET THE TRACK
				track = reaper.GetSelectedTrack(0, i) -- Get selected track i

				env_count = reaper.CountTrackEnvelopes(track)
				for m = 0, env_count-1 do

					-- GET THE ENVELOPE
					env = reaper.GetTrackEnvelope(track, m)
					br_env = reaper.BR_EnvAlloc(env, false)
					
					retval, env_name = reaper.GetEnvelopeName(env, "")

					-- IF VISIBLE AND ARMED
					env_active, env_visible, env_armed, env_inLane, env_laneHeight, env_defaultShape, env_minValue, env_maxValue, env_centerValue, env_type, env_faderScaling = reaper.BR_EnvGetProperties(br_env, true, true, true, true, 0, 0, 0, 0, 0, 0, true)

					if env_visible == true and env_armed == true and envLast_name == env_name then

						-- LOOP THROUGH LAST TOUCHED CURRENT ENVELOPE POINTS

						-- The trick is to insert points from last selected items first, then loop in those on last points and set the value.
						env_points_count = reaper.CountEnvelopePoints(env)
						
						for l = 0, env_points_count-1 do 

							retval, env_time, env_value, env_shape, env_tension, env_selectedOut = reaper.GetEnvelopePoint(env, l)
							
							retval, valueOut, dVdSOut, ddVdSOut, dddVdSOut = reaper.Envelope_Evaluate(envLast, env_time, 0, 0)
							
							point = reaper.GetEnvelopePointByTime(envLast, env_time)
							
							if point >= 0 then
							
								reaper.InsertEnvelopePoint(envLast, env_time, valueOut, env_shape, env_tension, true, true) -- INSERT startLoop point
								
							end
							
							reaper.Envelope_SortPoints(envLast)
						
						end -- ENDIF points on the envelope
						
						envLast_points_count = reaper.CountEnvelopePoints(envLast)
						
						for k = 0, envLast_points_count-1 do 

							retval, envLast_time, envLast_value, envLast_shape, envLast_tension, envLast_selectedOut = reaper.GetEnvelopePoint(envLast, k)
							
							retval, valueOut, dVdSOut, ddVdSOut, dddVdSOut = reaper.Envelope_Evaluate(env, envLast_time, 0, 0)
							
							if envLast_name == "Volume" or envLast_name == "Volume (Pre-FX)" or envLast_name == "Send Volume" then
							
								if env_faderScaling == true then valueOut = reaper.ScaleFromEnvelopeMode(1, valueOut) end
					
								-- CALC
								env_VolDB = 20*(math.log(valueOut, 10)) -- thanks to spk77!
								envLast_VolDB = 20*(math.log(envLast_value, 10)) -- thanks to spk77!

								calc = env_VolDB + envLast_VolDB -- it invert volume based on 0db

								valueIn = math.exp(calc*0.115129254)
								
								if env_faderScaling == true then valueIn = reaper.ScaleToEnvelopeMode(1, valueIn) end
								
							else -- ENDIF Volume
								
								valueIn = valueOut + envLast_value
								
							end
							
							if valueIn < last_env_minValue then valueIn = last_env_minValue end
							if valueIn > last_env_maxValue then valueIn = last_env_maxValue end
							
							reaper.SetEnvelopePoint(envLast, k, envLast_time, valueIn, envLast_shape, envLast_tension, false, true)
						
						end -- ENDIF points on the envelope

					end -- ENDIF envelope passed
					
					reaper.BR_EnvFree(br_env, 0)

				end -- ENDLOOP selected tracks envelope
			
			end -- ENDLOOP selected tracks
		
		end -- ENFIF visible
		
		reaper.BR_EnvFree(br_envLast, 0)
		
	end -- ENDLOOP through envelopes

	-- RESTORE LAST TRACK SELECTION
	if restore_sel == true then
		reaper.SetTrackSelected(last_track, true)
	end

	reaper.Undo_EndBlock("", -1) -- End of the undo block. Leave it at the bottom of your main function.

end -- end main()

--msg_start() -- Display characters in the console to show you the begining of the script execution.

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.
reaper.Undo_BeginBlock()
main() -- Execute your main function
reaper.Undo_EndBlock("Merge visible armed envelopes of selected track to selected tracks VCA like)", -1)

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)

--msg_end() -- Display characters in the console to show you the end of the script execution.

-- BEWARE OF CTRL+Z as last touched track will Change

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