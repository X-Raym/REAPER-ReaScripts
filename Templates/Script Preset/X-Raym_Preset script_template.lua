--[[
 * ReaScript Name: Preset Script
 * About: Duplicate and Edit the User Config Areas of the duplicated file. Put it anywhere and rename it with the name of your choice. Then import it into action list.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0.1
--]]

-- USER CONFIG AREA 1/2 ------------------------------------------------------

-- Absolute path, or path relative to this script, or path relative to user resource folder. It can be just parent script file name.
local parent_script_path = "X-Raym_Parent script of preset script_template.lua"

-------------------------------------------------- END OF USER CONFIG AREA 1/2

-- PARENT SCRIPT CALL --------------------------------------------------------

-- Get Script Path
os_sep = package.config:sub(1,1)
if not reaper.file_exists( parent_script_path ) then
  parent_script_path = debug.getinfo(1).source:match("@?(.*[\\|/])") .. parent_script_path
  if not reaper.file_exists( parent_script_path ) then
    parent_script_path = reaper.GetResourcePath() .. os_sep .. parent_script_path
    if not reaper.file_exists( parent_script_path ) then
      return reaper.MB("Missing parent script.\n" .. parent_script_path, "Error", 0)
    end
  end
end

preset_file_init = true

dofile( parent_script_path )

---------------------------------------------------- END OF PARENT SCRIPT CALL

-- USER CONFIG AREA 2/2 ------------------------------------------------------

-- Put your variables there, so that it overrides the default ones. 
-- You can usually copy the User Config Area variable of the target script. Examples below.

-- Typical global variables names
popup = false
console = false

-------------------------------------------------- END OF USER CONFIG AREA 2/2

-- RUN -------------------------------------------------------------------

Init() -- Run the init function of the target script.
