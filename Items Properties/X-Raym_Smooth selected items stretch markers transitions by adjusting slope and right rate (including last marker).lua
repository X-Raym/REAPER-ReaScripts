--[[
 * ReaScript Name: Smooth selected items stretch markers transitions by adjusting slope and right rate (including last marker)
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2021-02-04)
  + Initial Release
--]]

-- USER CONFIG AREA 1/2 ------------------------------------------------------

-- Dependency Name
script = "X-Raym_Smooth selected items stretch markers transitions by adjusting slope and right rate.lua" -- 1. The target script path relative to this file. If no folder, then it means preset file is right to the target script.

-------------------------------------------------- END OF USER CONFIG AREA 1/2

-- PARENT SCRIPT CALL --------------------------------------------------------

-- Get Script Path
script_folder = debug.getinfo(1).source:match("@?(.*[\\|/])")
script_path = script_folder .. script -- This can be erased if you prefer enter absolute path value above.

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
console = false -- true/false: display debug messages in the console
gui = false
dont_do_last = false


-------------------------------------------------- END OF USER CONFIG AREA 2/2

-- RUN -------------------------------------------------------------------

Init() -- run the init function of the target script.
