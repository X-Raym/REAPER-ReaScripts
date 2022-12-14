--[[
 * ReaScript Name: Preset Script
 * About: Edit the User Config Areas to make it work. Name above could typicallly be Original Script Name - Preset Name or Num, but it can be whatever you want.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

-- USER CONFIG AREA 1/2 ------------------------------------------------------

-- Dependency Name
local script = "X-Raym_Parent script of preset script_template.lua" -- 1. The target script path relative to this file. If no folder, then it means preset file is right to the target script.

-------------------------------------------------- END OF USER CONFIG AREA 1/2

-- PARENT SCRIPT CALL --------------------------------------------------------

-- Get Script Path
local script_folder = debug.getinfo(1).source:match("@?(.*[\\|/])")
local script_path = script_folder .. script -- This can be erased if you prefer enter absolute path value above.

-- Prevent Init() Execution
preset_file_init = true

-- Run the Script
if reaper.file_exists( script_path ) then
  dofile( script_path )
else
  reaper.MB("Missing parent script.\n" .. script_path, "Error", 0)
  return
end

---------------------------------------------------- END OF PARENT SCRIPT CALL

-- USER CONFIG AREA 2/2 ------------------------------------------------------

-- 2. Put your variables there, so that it overrides the default ones. 
-- You can usually copy the User Config Area variable of the target script. Examples below.

-- Typical global variables names
popup = false
console = false

-------------------------------------------------- END OF USER CONFIG AREA 2/2

-- RUN -------------------------------------------------------------------

Init() -- run the init function of the target script.
