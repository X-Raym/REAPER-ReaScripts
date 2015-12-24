--[[
 * ReaScript Name: Display script infos in the console
 * Description: See title
 * Instructions: Select an item. Use it.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Lua Code Snippet: Text - String Word Wrap for GFX
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=163063
 * REAPER: 5.0 pre 36
 * Extensions: SWS/S&M 2.7.1 #0
 * Version: 1.0
]]
 
 
--[[
 * Changelog:
 * v1.0 (2015-08-21)
	+ Initial Release
]]


function Msg(variable)
	reaper.ShowConsoleMsg(tostring(variable).."\n")
end

----------------------------------------------------------------------

function read_lines(filepath)
	
	reaper.Undo_BeginBlock() -- Begin undo group
	
	name = ""
	folder = ""
	author = ""
	release = ""
	required = ""
	extensions = ""
	thread = ""
	thread_URIs = ""
	screenshot = ""
	folder = ""
	version = ""
	version_date = ""
	
	local f = io.input(filepath)
	repeat
	  
		s = f:read ("*l") -- read one line

		if s then  -- if not end of file (EOF)
		
			-- REASCRIPT NAME
			if string.find(s,'%s%*%sReaScript Name: ') then

				name = tostring(s:match("ReaScript Name: (.*)"))
				Msg(" * ReaScript Name: " .. name)

			end

			-- AUTHOR
			if string.find(s,' * Author: ') then

				author = tostring(s:match("Author: (.*)"))
				Msg(" * Author: " .. author)

			end

			-- THREAD
			if string.find(s,'%s%*%sForum Thread: ') then

				thread = tostring(s:match("Forum Thread: (.*)"))
				Msg(" * Forum Thread: " .. thread)

			end

			-- THREAD URI
			if string.find(s,'%s%*%sForum Thread URI: ') then

				thread_URI = tostring(s:match("Forum Thread URI: (.*)"))
				Msg(" * Forum Thread URI: " .. thread_URI)

			end

			-- REAPER
			if string.find(s,'%s%*%sREAPER: ') then

				required = tostring(s:match("REAPER: (.*)"))
				Msg(" * REAPER: " .. required)

			end

			-- EXTENSIONS
			if string.find(s,'%s%*%sExtensions: ') then

				extensions = tostring(s:match("Extensions: (.*)"))
				Msg(" * Extensions: " .. extensions)

			end

			-- SCREENSHOT
			if string.find(s,'%s%*%sScreenshot: ') then

				screenshot = tostring(s:match("Screenshot: (.*)"))
				Msg(" * Screenshot: " .. screenshot)

			end

			-- VERSION
			if string.find(s,'%s%*%sv') then

				version = tostring(string.match(s, "v(%S*)"))
				version_date = tostring(string.match(s, "%d%d%d%d%-%d%d%-%d%d"))

				--Msg(" * Last Version: " .. version)
				if version ~= "" then Msg(" * Last Version: " .. version) end
				if version_date ~= "" then Msg(" * Last Version Date: " .. version_date) end

			end
			
			-- VERSION
			if string.find(s,'%s%*%sv1.0') then

				release_date = tostring(string.match(s, "%d%d%d%d%-%d%d%-%d%d"))

				if release_date ~= "" then Msg(" * Initial Release Date: " .. release_date) end
				
				break

			end

		end
	
	until not s  -- until end of file

	f:close()
	
	sep = "	" -- Tab
	
	Msg("\n\nCSV OUTPUT\n".. name .. sep .. folder .. sep .. author .. sep .. version.. sep.. version_date .. sep .. release_date .. sep .. required .. " / " .. extensions .. sep .. thread .. sep .. thread_URI .. sep .. screenshot)
	
	Msg("\n\nFORUM OUTPUT\n".. "[b]EDIT: " .. version_date .."[/b]")
	Msg("[List]")
	Msg("[*][b]" .. name .."[/b]")
	Msg("[/list]")
	Msg("[img]" .. screenshot .."[/img]")
	
	reaper.Undo_EndBlock("Display script infos in the console", -1) -- End undo group
	
end



-- START -----------------------------------------------------
retval, filetxt = reaper.GetUserFileNameForRead("", "Select Script file", "lua")

if retval then 
	
	reaper.ShowConsoleMsg("")
	read_lines(filetxt)
	
end
