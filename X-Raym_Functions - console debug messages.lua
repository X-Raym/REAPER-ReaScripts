--[[
 * ReaScript Name: Show console messages
 * Description: This script contains fonctions to be embed in other scripts, for displaying all king of text and variables values in the console.
 * Instructions: Copy the DEBUGGING part of this script inside of your header, and put this functions file in the same folder of your script.
 * Author: X-Raym
 * Author URl: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URl: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URl: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: EEL : Console debug messages 
 * Forum Thread URl: http://forum.cockos.com/showthread.phpthent=153452
 * Version: 1.7
 * Version Date: 2015-02-24
 * REAPER: 5.0 pre 14
 * Extensions: None
 ]]--
 
--[[
 * Changelog:
 * v1.7 (2015-02-24)
	# Lua conversion. Since this point, the EEL and LUA version of the script will evolves together. Many thanks to Heda for string.len!
 * v1.0 (2015-02-23)
	+ Initial Release, from the EEL version.
 ]]--

--[[
-- ----- DEBUGGING ====>
@import X-Raym_Functions - console debug messages.eel

debug = 0 -- 0 => No console. 1 => Display console messages for debugging.
clean = 0 -- 0 => No console cleaning before every script execution. 1 => Console cleaning before every script execution.

msg_clean()
-- <==== DEBUGGING -----
]]--

-- Strings
function msg_s(variable)
	if debug == 1 then
		if string.len(variable) > 0 then
			reaper.ShowConsoleMsg(variable)
			reaper.ShowConsoleMsg("\n")
		else
			reaper.ShowConsoleMsg("ERROR : Empty String")
			reaper.ShowConsoleMsg("\n")
		end
	end
end -- of msg_s()

-- Strings with text and lines
function msg_stl(text,variable,line)
	if debug == 1 then
		if string.len(text) > 0 then
			msg_s(text)
		end
		if string.len(variable) > 0 then
			reaper.ShowConsoleMsg(variable)
		else
			reaper.ShowConsoleMsg("ERROR : Empty String")
		end
		if line == 0 then
			reaper.ShowConsoleMsg("\n")
		else
			reaper.ShowConsoleMsg("\n-----\n")
		end
	end
end -- of msg_stl()

-- Double
function msg_d(variable)
	if debug == 1 then
		str = string.format("%d", variable)
		reaper.ShowConsoleMsg(str)
		reaper.ShowConsoleMsg("\n")
	end
end -- of msg_d()

-- Double with text and lines
function msg_dtl(text,variable,line)
	if debug == 1 then
		if string.len(text) > 0 then
			msg_s(text)
		end
		str = string.format("%d", variable)
		reaper.ShowConsoleMsg(str)
		if line == 0 then
			reaper.ShowConsoleMsg("\n")
		else
			reaper.ShowConsoleMsg("\n-----\n")
		end
	end
end -- of msg_dtl()

-- Float
function msg_f(variable)
	if debug == 1 then
		str = string.format("%f", variable)
		reaper.ShowConsoleMsg(str)
		reaper.ShowConsoleMsg("\n")
	end
end -- of msg_f()

-- Float with text and lines
function msg_ftl(text,variable,line)
	if debug == 1 then
		if string.len(text) > 0 then
			msg_s(text)
		end
		str = string.format("%f", variable)
		reaper.ShowConsoleMsg(str)
		if line == 0 then
			reaper.ShowConsoleMsg("\n")
		else
			reaper.ShowConsoleMsg("\n-----\n")
		end
	end
end -- of msg_ftl()


-- Clean
function msg_clean()	
	if clean == 1 then
		reaper.ShowConsoleMsg("")
	end
end -- of msg_clean()

-- Start
function msg_start()
	if debug == 1 then
		reaper.ShowConsoleMsg("▼▼▼▼▼")
		reaper.ShowConsoleMsg("\n")
	end
end -- of msg_start()

-- End
function msg_end()
	if debug == 1 then
		reaper.ShowConsoleMsg("▲▲▲▲▲")
		reaper.ShowConsoleMsg("\n") -- In case of clean = 0
	end
end -- of msg_end()

-- MULTI-PURPOSE FUNCTION
-- Text is string
-- Variable is your variable
-- Output format are string "%s", integer "%d", and floating point "%f"
-- Debug value can be overide localy with 0 and 1.
-- Line is bolean
--
-- Example:
-- msg_tvold("My variable", variableString, "%s", 1, debug)
-- will ouput in the console :
--
-- My variable
-- *value of variableString* formated into string
-- -----
-- Only if global debug is set to 1 in file header.
--
-- All variables can be set to 0
function msg_tvold(text,variable,output,line,debug)
	
	-- STORE GLOBAL DEBUG STATE
	debugInit = debug
	
	if debug == 1 then

		-- CHECK TEXT
		if string.len(text) > 0 then
			reaper.ShowConsoleMsg(text)
			reaper.ShowConsoleMsg("\n")
		else
			reaper.ShowConsoleMsg("ERROR : Empty String")
			reaper.ShowConsoleMsg("\n")
		end

		-- OUTPUT FLOAT
		if output == "%f" then
			str = string.format("%f", variable)
			reaper.ShowConsoleMsg(str)
		end

		-- OUTPUT DECIMAL
		if output == "%d" then
			str = string.format("%d", variable)
			reaper.ShowConsoleMsg(str)
		end

		if output == "%x" then
			str = string.format("%x", variable)
			reaper.ShowConsoleMsg(str)
		end

		-- OUTPUT STRING
		if output == "%s" then
			if string.len(variable) > 0 then
				reaper.ShowConsoleMsg(variable)
			else
				reaper.ShowConsoleMsg("EMPTY STRING")
			end
		end
		
		-- OUTPUT LINE
		if line == 0 then
			reaper.ShowConsoleMsg("\n")
		else
			reaper.ShowConsoleMsg("\n-----\n")
		end
	
	end

	-- RESTORE PREVIOUS GLOBAL DEBUG
	debug = debugInit
end -- of msg_tvold()

function msg_tvoldi(text,variable,output,line,debug,inline)
	
	-- STORE GLOBAL DEBUG STATE
	debugInit = debug
	
	if debug == 1 then

		-- CHECK TEXT
		if string.len(text) > 0 then
			reaper.ShowConsoleMsg(text)
				if inline == 0 then
					reaper.ShowConsoleMsg("\n")
				end
		else
			reaper.ShowConsoleMsg("ERROR : Empty String")
			if inline == 0 then
				reaper.ShowConsoleMsg("\n")
			end
		end
		
		-- OUTPUT FLOAT
		if output == "%f" then
			str = string.format("%f", variable)
			reaper.ShowConsoleMsg(str)
		end

		-- OUTPUT DECIMAL
		if output == "%d" then
			str = string.format("%d", variable)
			reaper.ShowConsoleMsg(str)
		end

		-- OUTPUT STRING
		if output == "%s" then
			if string.len(variable) > 0 then
				reaper.ShowConsoleMsg(variable)
		else
				reaper.ShowConsoleMsg("EMPTY STRING")
			end
		end
		
		-- OUTPUT LINE
		if line == 0 then
			reaper.ShowConsoleMsg("\n")
		else
			reaper.ShowConsoleMsg("\n-----\n")
		end
	end

	-- RESTORE PREVIOUS GLOBAL DEBUG
	debug = debugInit

end -- of msg_tvoldi()

-- Debug

--[[function main()
	debug = 1
	clean = 1
	msg_clean()
	
	string = "Sample text"
	integer = 1
	float = 1.23456789
	
	msg_tvold("String",string,"%s",0,debug)
	msg_tvold("Integer",integer,"%d",0,debug)
	msg_tvold("Float",float,"%f",0,debug)
	
	msg_tvoldi("String",string,"%s",0,debug,0)
	msg_tvoldi("Integer",integer,"%d",0,debug,0)
	msg_tvoldi("Float",float,"%f",0,debug,0)
end -- of msg_main()

main()]]--
