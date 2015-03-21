--[[
 * ReaScript Name: Set or Offset selected envelope point value
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
 * Version Date: 2015-03-08
 * REAPER: 5.0 pre 9
 * Extensions: None
]]
 
--[[
 * Changelog:
 * v1.0 (2015-03-08)
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

function set_point_value()

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, true, 0, 0, false)

	if start_time ~= end_time then
		time_selection = true
	end

	already_set = false

	envelope = reaper.GetSelectedEnvelope(0)

	env_point_count = reaper.CountEnvelopePoints(envelope)

	dialog_ret_vals = ""
	retval, user_input_str = reaper.GetUserInputs("Set point value", 1, "Value ?", dialog_ret_vals) -- We suppose that the user know the scale he want
	x, y = string.find(user_input_str, "+")
	--reaper.ShowConsoleMsg(user_input_str)
	
	if x ~= nil then -- set
		set = false
	else -- offset
		set = true 
	end

	user_input_str = user_input_str:gsub("+", "")
	--reaper.ShowConsoleMsg(user_input_str)
	user_input_num = tonumber(user_input_str)

	-- GET ENVELOPE RANGE -- HERE IT IS
	envelopeName = ""
	retval, envelopeName = reaper.GetEnvelopeName(envelope, envelopeName)
	--msg_stl("Envelope name", envelopeName, 1)
	--reaper.ShowConsoleMsg(envelopeName)
	
	if envelopeName == "Volume" or envelopeName == "Volume (Pre-FX)" then
		already_set = true

		for i = 0, env_point_count - 1 do
				
			-- IDX 0 doesnt seem to work
			retval, time, valueOut, shape, tension, selectedOut = reaper.GetEnvelopePoint(envelope,i)

			if set == true then
				valueOut = math.exp(0*0.115129254)
			end

			if selectedOut == true then

				-- CALC
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
				----msg_ftl("Value ouput", valueIn, 1)
				-- SET POINT VALUE

				if time_selection = true and time >= star_time and time <= end_time then
					reaper.SetEnvelopePoint(envelope, i, time, valueIn, shape, tension, 1, noSortInOptional)
				else
					reaper.SetEnvelopePoint(envelope, i, time, valueIn, shape, tension, 1, noSortInOptional)
				end
			end -- ENDIF point is selected
		end -- END Loop
	end -- ENDIF Volume

	if envelopeName == "Mute" then
		already_set = true

		for i = 0, env_point_count - 1 do
				
			-- IDX 0 doesnt seem to work
			retval, time, valueOut, shape, tension, selectedOut = reaper.GetEnvelopePoint(envelope,i)
			if set == true then
				valueOut = 0
			end

			if selectedOut == true then

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

				-- SET POINT VALUE
				reaper.SetEnvelopePoint(envelope, i, time, valueIn, shape, tension, 1, noSortInOptional)
			end -- ENDIF point is selected
		end -- END Loop
	end -- ENDIF Mute

	if envelopeName == "Width" or envelopeName == "Width (Pre-FX)" or envelopeName == "Pan" or envelopeName == "Pan (Pre-FX)" then
		already_set = true

		for i = 0, env_point_count - 1 do
				
			-- IDX 0 doesnt seem to work
			retval, time, valueOut, shape, tension, selectedOut = reaper.GetEnvelopePoint(envelope,i)
			if set == true then
				valueOut = 0

			end
							
			if selectedOut == true then

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
				
				-- SET POINT VALUE
				reaper.SetEnvelopePoint(envelope, i, time, valueIn, shape, tension, 1, noSortInOptional)
			end -- ENDIF point is selected
		end -- END Loop
	end -- ENDIF Pan or Width
	
	if envelopeName == "Pitch" then
		already_set = true

		
		for i = 0, env_point_count - 1 do
				
			-- IDX 0 doesnt seem to work
			retval, time, valueOut, shape, tension, selectedOut = reaper.GetEnvelopePoint(envelope,i)
			if set == true then
				valueOut = 0
			end
							
			if selectedOut == true then

				-- CALC
				calc = valueOut + user_input_num
				--msg_ftl("Old pitch:", valueOut, 1)
				--msg_ftl("New pitch (before floor):", calc, 1)

				if calc <= -3 then
					valueIn = -3
					--msg_s("Pitch <= -3")
				end
				if calc >= 3 then
					valueIn = 3
					--msg_s("Pitch <= +3")
				end
				if calc > -3 and calc < 3 then
					valueIn = floor((calc)*20+0.5)/20
					--msg_s("-3 < Pitch < 3")
				end
				-- SET POINT VALUE
				reaper.SetEnvelopePoint(envelope, i, time, valueIn, shape, tension, 1, noSortInOptional)
			end -- ENDIF point is selected
		end -- END Loop
	end -- ENDIF Pan or Width

	if already_set == false then -- IF ENVELOPE HAS NO NAME PAS ICI LA BOUCL !!
		
		for i = 0, env_point_count - 1 do
				
			-- IDX 0 doesnt seem to work
			retval, time, valueOut, shape, tension, selectedOut = reaper.GetEnvelopePoint(envelope,i)
			
			if set == true then
				valueOut = 0
			end
							
			if selectedOut == true then

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
				-- SET POINT VALUE
				reaper.SetEnvelopePoint(envelope, i, time, valueIn, shape, tension, 1, noSortInOptional)
			end -- ENDIF point is selected
		end -- END Loop
	end -- ENDIF Fx
	reaper.Undo_EndBlock("Set or Offset selected envelope point value", 0) -- End of the undo block. Leave it at the bottom of your main function.
end -- END OF FUNCTION

--msg_start() -- Display characters in the console to show you the begining of the script execution.

set_point_value() -- Execute your main function

reaper.UpdateArrange() -- Update the arrangement (often needed)

--msg_end() -- Display characters in the console to show you the end of the script execution.