--[[
 * ReaScript Name: Export regions as txt file
 * Description: See title.
 * Instructions: Save project. Have regions. Run.
 * Author: X-Raym
 * Author URl: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URl: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URl: 
 * Licence: GPL v3
 * Forum Thread: Export regions as file
 * Forum Thread URl: http://forum.cockos.com/showthread.php?p=1617036&posted=1#post1617036
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.0
 --]]

--[[
 * Changelog:
 * v1.0 (2015-04-01)
	+ Initial Release
 --]]

 
--------------------------------------------------------
-- DEBUG
-- -----

-- Console Message
function Msg(g)
	reaper.ShowConsoleMsg(tostring(g).."\n")
end



---------------------------------------------------------
-- NUMBER
-- ------

-- Format Seconds
function Format(number)
	str = reaper.format_timestr_pos(number, "", 5)
	return str
end



--------------------------------------------------------
-- PATHS
-- -----

-- Get Path from file name
function GetPath(str,sep)
    return str:match("(.*"..sep..")")
end


-- Check if project has been saved
function IsProjectSaved()
	-- OS BASED SEPARATOR
	if reaper.GetOS() == "Win32" or reaper.GetOS() == "Win64" then
		-- user_folder = buf --"C:\\Users\\[username]" -- need to be test
		separator = "\\"
	else
		-- user_folder = "/USERS/[username]" -- Mac OS. Not tested on Linux.
		separator = "/"
	end

	--path = reaper.GetProjectPath("") -- E:\Bureau\Projet\Audio
	--path = path:gsub("Audio", "") -- E:\Bureau\Projet\

	retval, project_path_name = reaper.EnumProjects(-1, "")
	if project_path_name ~= "" then
		
		dir = GetPath(project_path_name, separator)
		--msg(name)
		name = string.sub(project_path_name, string.len(dir) + 1)
		name = string.sub(name, 1, -5)

		name = name:gsub(dir, "")
		--file = dir .. "HTML" .. separator .. name .. " - Items List.html"
		file = dir .. name .. " - Regions List.txt"
		--msg(name)
		project_saved = true
		return project_saved
	else
		display = reaper.ShowMessageBox("You need to save the project to execute this script.", "File Export", 1)

		if display == 1 then

			reaper.Main_OnCommand(40022, 0) -- SAVE AS PROJECT

			return IsProjectSaved()

		end
	end
end


------------------------------------------------------------------
-- COLOR FUNCTIONS
-- ---------------


--------------------------------------------------------------
-- CREATE FILE
-- -----------

-- New HTML Line
function export(f, variable)
	f:write(variable)
	f:write("\n")
end

-- Create File
function create(f)
	-- CREATE THE FILE
	io.output(file)
	
	i=0
	repeat
		iRetval, bIsrgnOut, iPosOut, iRgnendOut, sNameOut, iMarkrgnindexnumberOut, iColorOur = reaper.EnumProjectMarkers3(0,i)
		if iRetval >= 1 then
			if bIsrgnOut == true then
				start_time = reaper.format_timestr(iPosOut, "")
				end_time =  reaper.format_timestr(iRgnendOut, "")
				-- [start time HH:MM:SS.F] [end time HH:MM:SS.F] [name]
				line = start_time .. " " .. end_time .. " " .. sNameOut
				export(f, line)
			end
			i = i+1
		end
	until iRetval == 0

	-- CLOSE FILE
	f:close() -- never forget to close the file

	Msg("Regions Lists exported to:\n" .. file .."\n")

end



----------------------------------------------------------------
-- MAIN FUNCTION
-- -------------

function main() -- local (i, j, item, take, track)

	local f = io.open(file, "w")

	-- HTML FOLDER EXIST
	if f ~= nil then
		create(f)
	end

end -- ENDFUNCTION MAIN



----------------------------------------------------------------
-- MAIN FUNCTION
-- -------------

-- SAVE INITIAL SELECTED ITEMS
function SaveSelectedItems (table)
	for i = 0, reaper.CountSelectedMediaItems(0)-1 do
		table[i+1] = reaper.GetSelectedMediaItem(0, i)
	end
end

-- RESTORE INITIAL SELECTED ITEMS
function RestoreSelectedItems (table)
	reaper.SelectAllMediaItems(0, false) -- Unselect all items
	for _, item in ipairs(table) do
		reaper.SetMediaItemSelected(item, true)
	end
end



----------------------------------------------------------------------
-- RUN
-- ---

-- Check if there is selected Items
retval, count_markers, count_regions = reaper.CountProjectMarkers(0)

if count_regions > 0 then

	project_saved = IsProjectSaved() -- See if Project has been save and determine file paths
	if project_saved then
		main() -- Execute your main function
	end

else
	Msg("No regions in the project.")
end -- ENDIF Item in project
