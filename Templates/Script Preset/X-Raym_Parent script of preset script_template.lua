--[[
 * ReaScript Name: Parent script of preset script
 * About: For devs
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0.3
 * Provides:
 *   [nomain] .
 *   [nomain] README.md
--]]

-- USER CONFIG AREA ------------------------------------------------------

-- Use Preset Script for safe moding or to create a new action with your own values
-- https://github.com/X-Raym/REAPER-ReaScripts/tree/master/Templates/Script%20Preset

-- Typical global variables names. This will be out global variables which could be altered in the preset file.
popup = false
console = false

link = "https://github.com/X-Raym/REAPER-ReaScripts/Templates/Script%20Preset/README.md"

-------------------------------------------------- END OF USER CONFIG AREA
function Open_URL(url)
  local OS = OS or reaper.GetOS()
  if OS=="OSX32" or OS=="OSX64" then
    os.execute("open ".. url)
   else
    os.execute("start \"\" \"".. url .. "\"")
  end
end

function Init() -- The Init function of the script.
  local retval = reaper.MB( "This script is a template.\nDo you want to open the doc?", "Info", 1)
  if retval == 1 then
    Open_URL( link )
  end
end

if not preset_file_init then -- If the file is run directly, it will execute Init(), else it will wait for Init() to be called explicitely from the preset scripts (usually after having modified some global variable states).
  Init()
end
