--[[
 * ReaScript Name: X-Raym_Set flat points value in time selection preserving edges if time selection.lua
 * Description: A pop up to let you put offset values for selected item points. 
 * Instructions: Write values you want. Use "+" sign for relative value (the value is added to the original), no sign for absolute Exemple: -6 is absolute, or +-6 is relative. Don't use percentage. Example: writte "60" for 60%.
 * Author: X-Raym
 * Author URl: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URl: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URl: 
 * Licence: GPL v3
 * Forum Thread: ReaScript: Set/Offset selected envelope points values
 * Forum Thread URl: http://forum.cockos.com/showthread.php?p=1487882#post1487882
 * Version: 1.0
 * Version Date: 2015-03-21
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

preserve_edges = true -- True will insert points à time selection edges before the action.

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

	if time_selection == true then

		retval, user_input_str = reaper.GetUserInputs("Set point value", 1, "Value ?", "") -- We suppose that the user know the scale he want

		-- IF USER PASTE A VALUE
		if retval ~= nil then

			user_input_num = tonumber(user_input_str)

			-- GET SELECTED ENVELOPE
			sel_env = reaper.GetSelectedEnvelope(0)
			
				if sel_env ~= nil then
				env_point_count = reaper.CountEnvelopePoints(sel_env)
				retval, env_name = reaper.GetEnvelopeName(sel_env, "")

				-- LOOP TRHOUGH SELECTED TRACKS
				selected_tracks_count = reaper.CountSelectedTracks(0)
				for j = 0, selected_tracks_count-1  do
					
					-- GET THE TRACK
					track = reaper.GetSelectedTrack(0, j) -- Get selected track i

					env_count = reaper.CountTrackEnvelopes(track)
					
					for m = 0, env_count-1 do

						-- GET THE ENVELOPE
						env_dest = reaper.GetTrackEnvelope(track, m)
						retval, env_name_dest = reaper.GetEnvelopeName(env_dest, "")

						-- IF VISIBLE AND ARMED
						br_env = reaper.BR_EnvAlloc(env_dest, false)
						active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, type, faderScaling = reaper.BR_EnvGetProperties(br_env, true, true, true, true, 0, 0, 0, 0, 0, 0, true)
						if visible == true and armed == true then
						
							retval3, valueOut3, dVdSOutOptional3, ddVdSOutOptional3, dddVdSOutOptional3 = reaper.Envelope_Evaluate(env_dest, start_time, 0, 0)
							retval4, valueOut4, dVdSOutOptional4, ddVdSOutOptional4, dddVdSOutOptional4 = reaper.Envelope_Evaluate(env_dest, end_time, 0, 0)
							
							start_time_temp = math.floor(start_time * 100000000+0.5)/100000000
							end_time_temp = math.floor(end_time * 100000000+0.5)/100000000

							start_point = reaper.GetEnvelopePointByTime(env_dest, start_time+0.000000001)
							retval, start_point_time, valueOut, shape, tension, selectedOut = reaper.GetEnvelopePoint(env_dest,start_point-1)
							
							start_point_time = math.floor(start_point_time * 100000000+0.5)/100000000
							
							if start_point_time == start_time_temp then
								valueOut3 = valueOut
							end

							reaper.DeleteEnvelopePointRange(env_dest, start_time-0.000000001, end_time+0.000000001)
						

							SetValue(env_dest)

							-- PRESERVE EDGES INSERTION
							if preserve_edges == true then
								
								reaper.InsertEnvelopePoint(env_dest, start_time, valueOut3, 0, 0, true, true) -- INSERT startLoop point
								reaper.InsertEnvelopePoint(env_dest, start_time, valueIn, 0, 0, true, true) -- INSERT startLoop point
								reaper.InsertEnvelopePoint(env_dest, end_time, valueIn, 0, 0, true, true) -- INSERT startLoop point
								reaper.InsertEnvelopePoint(env_dest, end_time, valueOut4, 0, 0, true, true) -- INSERT startLoop point
							
							else

								reaper.InsertEnvelopePoint(env_dest, start_time, valueIn, 0, 0, true, true) -- INSERT startLoop point
								reaper.InsertEnvelopePoint(env_dest, end_time, valueIn, 0, 0, true, true) -- INSERT startLoop point

							end

							reaper.BR_EnvFree(br_env, 0)
							reaper.Envelope_SortPoints(env_dest)

						end -- ENDIF envelope passed

					end -- ENDLOOP selected tracks envelope
				
				end -- ENDLOOP selected tracks
			end
		end
	end
end -- end main()

function SetValue(envelope)

	already_set = false
	valueOut = 0
	
	if env_name == "Volume" or env_name == "Volume (Pre-FX)" then
		already_set = true

		-- CALC
		valueOut = math.exp(0*0.115129254)
		OldVol = valueOut
		OldVolDB = 20*(math.log(OldVol, 10)) -- thanks to spk77!

		--msg_ftl("Old vol db:", OldVolDB, 1)

		calc = OldVolDB + user_input_num
		--msg_ftl("Calc", calc, 1)
		--reaper.ShowConsoleMsg(tostring(calc))
		
		if calc <= -146 then
			valueIn = 0
			--msg_s("Volume <= -146")
		end
		if calc >= 6 then
			valueIn = 2
			--msg_s("+12 <= Volume")
		end
		if calc < 6 and calc > -146 then
			valueIn = math.exp(calc*0.115129254)
			--msg_s("-146 < Volume < +12")
		end
			
	end -- ENDIF Volume

	if env_name == "Mute" then
		already_set = true

		-- CALC
		calc = valueOut + user_input_num

		if calc < 0 then
			valueIn = 0
			--msg_s("Mute = 0")
		end
		if calc >= 1 then
			valueIn = 1
			--msg_s("Mute = 1")	
		end
		if calc < 0.5 then
			valueIn = 0
			--msg_s("Mute Floor < 0.5")	
		end
		if calc >= 0.5 then
			valueIn = 1
			--msg_s("0.5 <= Mute Floor")	
		end
			
	end -- ENDIF Mute

	if env_name == "Width" or env_name == "Width (Pre-FX)" or env_name == "Pan" or env_name == "Pan (Pre-FX)" then
		already_set = true
							
			-- CALC
			calc = valueOut*100 - user_input_num

			if calc <= -100 then
				valueIn = - 1.0
				--msg_s("Pan/Width <= -100")
			end
			if calc >= 100 then
				valueIn = 1.0
				--msg_s("Pan/Width >= 100")	
			end
			if calc < 100 and calc > -100 then
				valueIn = calc / 100
				--msg_s("-100 < Pan/Width < 100")	
			end
			

	end -- ENDIF Pan or Width

	if already_set == false then -- IF ENVELOPE HAS NO NAME PAS ICI LA BOUCL !!
			
			-- CALC
			calc = valueOut*100 + user_input_num
			
			if calc <= 0 then
				valueIn = 0
				--msg_s("FX <= 0")	
			end
			if calc >= 100 then
				valueIn = 1.0
				--msg_s("100 <= FX")
			end
			if calc < 100 and calc > -100 then
				valueIn = calc / 100
				--msg_s("0 < FX < 100")	
			end
			
	end -- ENDIF Fx

end -- END OF FUNCTION

--msg_start() -- Display characters in the console to show you the begining of the script execution.

reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
main() -- Execute your main function
reaper.Undo_EndBlock("Set flat points value in time selection preserving edges if time selection", 0) -- End of the undo block. Leave it at the bottom of your main function.

reaper.UpdateArrange() -- Update the arrangement (often needed)

--msg_end() -- Display characters in the console to show you the end of the script execution.