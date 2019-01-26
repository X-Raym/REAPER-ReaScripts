--[[
 * ReaScript Name: Export markers and regions as Davinci Resolve EDL file
 * About: This was designed to have a tempo map inside DaVinci Resolve
 * Screenshot: https://i.imgur.com/xEsD5a8.gifv
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Links
    Forum Thread https://forum.cockos.com/showthread.php?p=1670961
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2018-12-21)
  + Initial Release
--]]

 
--------------------------------------------------------
-- DEBUG
-- -----

frame_duration = 1 / 25

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
    file = dir .. name .. " - Regions List.edl"
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
  
  title = "TITLE: Timeline 1"
  FCM = "FCM: NON-DROP FRAME"
  export(f, title)
  export(f, FCM .. "\n")
  
  i=0
  repeat
    iRetval, bIsrgnOut, iPosOut, iRgnendOut, name, iMarkrgnindexnumberOut, iColorOur = reaper.EnumProjectMarkers3(0,i)
    if iRetval >= 1 then
      if bIsrgnOut == false then
        start_time = "0" .. reaper.format_timestr_pos(iPosOut + 3600, "",5)
        start_time_1 = "0" .. reaper.format_timestr_pos(iPosOut + 3600 + frame_duration, "",5)
        end_time =  reaper.format_timestr_pos(iRgnendOut, "",5)
        -- [start time HH:MM:SS.F] [end time HH:MM:SS.F] [name]
        -- 001  001      V     C        01:00:00:00 01:00:00:01 01:00:00:00 01:00:00:01  
-- |C:ResolveColorBlue |M:Marker 1 |D:1
        line = i .. "  001      V     C        " .. start_time .. " " .. start_time_1 .. " " .. start_time .. " " .. start_time_1 .. "  " .. "\n |C:ResolveColorBlue |M:" .. name .. " |D:1\n"
        export(f, line)
      end
      i = i+1
    end
  until iRetval == 0
  
  export(f, "\n")

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
  
  -- CLOSE FILE
  io.close(f)

end -- ENDFUNCTION MAIN


----------------------------------------------------------------------
-- RUN
-- ---

-- Check if there is selected Items
retval, count_markers, count_regions = reaper.CountProjectMarkers(0)

if count_regions > 0 then

  project_saved = IsProjectSaved() -- See if Project has been save and determine file paths
  if project_saved then
    reaper.defer(main) -- Execute your main function
  end

else
  Msg("No regions in the project.")
end -- ENDIF Item in project
