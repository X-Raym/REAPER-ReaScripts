--[[
 * ReaScript Name: Set or Offset selected envelope point value in selected envelope
 * Description: A pop up to let you put offset values for selected item points. 
 * Instructions: Write values you want. Use "+" sign for relative value (the value is added to the original), no sign for absolute Exemple: -6 is absolute, or +-6 is relative. Don't use percentage. Example: writte "60" for 60%. You can customize default behavior (relative or absolute mod and prefix character) in the User Area of this script.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: 
 * Licence: GPL v3
 * Forum Thread: ReaScript: Set/Offset selected envelope points values
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1487882#post1487882
 * REAPER: 5.0 pre 9
 * Extensions: None
 * Version: 1.6
]]
 
--[[
 * Changelog:
 * v1.6 (2015-09-09)
	+ Fader-scaling support
 * v1.5 (2015-07-15)
	+ User customization area
	# "Cancel" bug fix
 * v1.4 (2015-07-11)
	+ Send support
 * v1.3 (2015-06-25)
	# Dual pan track support
 * v1.2 (2015-06-02)
	# No envelope selected bug fix (thanks Soli Deo Gloria for the report)
 * v1.1 (2015-05-07)
	# Time selection bug fix
 * v1.0 (2015-03-08)
	+ Initial Release
]]

-- ------ USER AREA =====>
mod1 = "absolute" -- Set the primary mod that will be defined if no prefix character. Values are "absolute" or "relative".
mod2_prefix = "+" -- Prefix to enter the secondary mod
input_default = "" -- "" means no character aka relative per default.
-- <===== USER AREA ------

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

  already_set = false

  envelope = reaper.GetSelectedEnvelope(0)
  
  if envelope ~= nil then

    env_point_count = reaper.CountEnvelopePoints(envelope)

    retval, user_input_str = reaper.GetUserInputs("Set or Offset point value", 1, "Value ?", input_default) -- We suppose that the user know the scale he want
    if retval then
	
		x, y = string.find(user_input_str, mod2_prefix)
		--reaper.ShowConsoleMsg(user_input_str)
		
		if mod1 == "absolute" then
			if x ~= nil then -- set
			  set = false
			else -- offset
			  set = true 
			end
		end
		
		if mod1 == "relative" then
			if x ~= nil then -- set
			  set = true
			else -- offset
			  set = false 
			end
		end

		user_input_str = user_input_str:gsub(mod2_prefix, "")
		--reaper.ShowConsoleMsg(user_input_str)
		user_input_num = tonumber(user_input_str)
		
		-- IF VALID INPUT
		if user_input_num ~= nil then

			-- GET ENVELOPE RANGE -- HERE IT IS
			envelopeName = ""
			retval, envelopeName = reaper.GetEnvelopeName(envelope, envelopeName)
			--msg_stl("Envelope name", envelopeName, 1)
			--reaper.ShowConsoleMsg(envelopeName)
			
			if envelopeName == "Volume" or envelopeName == "Volume (Pre-FX)" or envelopeName == "Send Volume" then
			  already_set = true
			  
			  env_scale = reaper.GetEnvelopeScalingMode(envelope)

			  for i = 0, env_point_count - 1 do
				  
				-- IDX 0 doesnt seem to work
				retval, time, valueOut, shape, tension, selectedOut = reaper.GetEnvelopePoint(envelope,i)
				
				if env_scale == 1 then valueOut = reaper.ScaleFromEnvelopeMode(1, valueOut) end
				
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
				  
				  if env_scale == 1 then valueIn = reaper.ScaleToEnvelopeMode(1, valueIn) end

				  reaper.SetEnvelopePoint(envelope, i, time, valueIn, shape, tension, 1, noSortInOptional)
				  
				end -- ENDIF point is selected
			  end -- END Loop
			end -- ENDIF Volume

			if envelopeName == "Mute" or envelopeName == "Send Mute" then
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

			if envelopeName == "Width" or envelopeName == "Width (Pre-FX)" or envelopeName == "Pan" or envelopeName == "Pan (Pre-FX)" or envelopeName == "Pan (Left)" or envelopeName == "Pan (Right)" or envelopeName == "Pan (Left, Pre-FX)" or envelopeName == "Pan (Right, Pre-FX)" or envelopeName == "Send Pan" then
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
		end
	end
    
  end --if envelope is selected
  reaper.Undo_EndBlock("Set or Offset selected envelope point value", -1) -- End of the undo block. Leave it at the bottom of your main function.
end -- END OF FUNCTION

--msg_start() -- Display characters in the console to show you the begining of the script execution.

set_point_value() -- Execute your main function

reaper.UpdateArrange() -- Update the arrangement (often needed)

--msg_end() -- Display characters in the console to show you the end of the script execution.
