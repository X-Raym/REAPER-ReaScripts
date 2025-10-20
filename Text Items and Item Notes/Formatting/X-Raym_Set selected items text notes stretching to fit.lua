--[[
 * ReaScript Name: Set selected items text notes stretching to fit
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0.0
--]]

-- USER CONFIG AREA 1/2 ------------------------------------------------------

-- Absolute path, or path relative to this script, or path relative to user resource folder. It can be just parent script file name.
local parent_script_path = "X-Raym_Toggle selected items text notes stretching.lua"

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

force_new_flags = 3
undo_text = "Set selected items text notes stretching to fit"

-------------------------------------------------- END OF USER CONFIG AREA 2/2

-- RUN -------------------------------------------------------------------

Init() -- Run the init function of the target script.