--[[
 * ReaScript Name: Open project folder in explorer or finder
 * Description: See title.
 * Instructions: Run.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Various
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1622146
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.1.1
--]]

--[[
 * Changelog:
 * v1.1.1 (2018-12-08)
	# Mac fix fixed
 * v1.1 (2018-12-07)
	# Mac fix
 * v1.0 (2016-01-14)
	+ Initial Release
--]]

 
--------------------------------------------------------
-- DEBUG
-- -----

-- Console Message
function Msg(g)
	reaper.ShowConsoleMsg(tostring(g).."\n")
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

	retval, project_path_name = reaper.EnumProjects(-1, "")
	if project_path_name ~= "" then
		
		dir = GetPath(project_path_name, separator)
		--msg(name)
		name = string.sub(project_path_name, string.len(dir) + 1)
		name = string.sub(name, 1, -5)

		name = name:gsub(dir, "")
		
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

----------------------------------------------------------------
-- MAIN FUNCTION
-- -------------

function main()

	reaper.CF_ShellExecute(dir)

end -- ENDFUNCTION MAIN


----------------------------------------------------------------------
-- RUN
-- ---

-- Check if there is selected Items

project_saved = IsProjectSaved() -- See if Project has been save and determine file paths
if project_saved then
	main() -- Execute your main function
end