--[[
 * ReaScript Name: Split selected items according to items on selected tracks and keep new items at spaces
 * Screenshot: https://i.imgur.com/6e1H0I2.gif
 * About: A script designed for spliting an ambiance sound to put between dialog items
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0 pre 15
 * Version: 2.0.1
--]]

--[[
 * Changelog:
 * v2.0.1 (2023-11-33)
  # Fix dependency
 * v2.0 (2023-11-10)
  # Renamed
  # Refactor
  # Bug fixes
  + Multitracks as source support
 * v1.1.1 (2019-10-18)
  # No track selected bug fix
  # Few optimizations
  # Error tootip
 * v1.1 (2015-04-01)
  + Works on selected multiple items
 * v1.0 (2015-04-01)
  + Initial Release
--]]

-- USER CONFIG AREA 1/2 ------------------------------------------------------

-- Dependency Name
local script = "X-Raym_Split selected items according to items on selected tracks and delete new items at spaces.lua" -- 1. The target script path relative to this file. If no folder, then it means preset file is right to the target script.

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
delete_at_silence = false
undo_text = "Split selected items according to items on selected tracks and keep new items at spaces"

-------------------------------------------------- END OF USER CONFIG AREA 2/2

-- RUN -------------------------------------------------------------------

Init() -- run the init function of the target script.
