--[[
 * ReaScript Name: Set SWS Notes window font size
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 7.0
 * Version: 1.0.2
--]]

--[[
 * Changelog:
 * v1.0.2 (2025-07-22)
  # Works even if not already set once
 * v1.0.0 (2025-05-28)
  + Initial Release
--]]

if not reaper.BR_Win32_GetPrivateProfileString then
  reaper.MB("SWS extension is required by this script.\nPlease download it on http://www.sws-extension.org/", "Warning", 0)
end

local os_sep = package.config:sub(1,1)
sm_ini = reaper.GetResourcePath() .. os_sep .. "S&M.ini"
--
retval, value = reaper.BR_Win32_GetPrivateProfileString( "Notes", "Fontsize", "",  sm_ini  )
--if not retval or value == "" then return end

retval, retval_csv = reaper.GetUserInputs( "SWS Notes Window Font Size", 1, "Font size? (default=14)", value)
if not retval or not tonumber(retval_csv) or tonumber(retval_csv) <= 0 then return end

reaper.BR_Win32_WritePrivateProfileString( "Notes", "Fontsize", math.ceil(tonumber(retval_csv)),  sm_ini  )

reaper.MB( "Toggle Wrap Text via right click on S&M Notes window twice to refresh font size.", "Success", 0 )
