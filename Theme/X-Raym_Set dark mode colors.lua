--[[
 * ReaScript Name: Set dark mode colors
 * About: Set config (reaper.ini) dark colors to unsaturated ones (native ones are a bit green). Initially meant X-Raym Analog Darker theme. Restart REAPER to after process.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2026-02-11)
  + Initial Release
--]]

-- USER CONFIG AREA -----------------------------------------------------------

console = true -- true/false: display debug messages in the console

vals = {
    col_nodarkmodemiscwnd = 0,
    win32_darkmode = 2,
    win32_darkmode_colors= "242424 515151 ffffff 666666 353535 242424 2b2b2b 323232 dddddd 666666 505050 444444 dfdfdf 1d1d1e ffffff ffffff 2a2a2a 888888 454545 575757 484848 414141"
}

reaper_ini_file = reaper.get_ini_file()

------------------------------------------------------- END OF USER CONFIG AREA

if not reaper.BR_Win32_GetPrivateProfileString then
  reaper.MB("SWS extension is required by this script.\nPlease download it on http://www.sws-extension.org/", "Warning", 0)
  return
end

function DisplayTooltip(message)
  local x, y = reaper.GetMousePosition()
  reaper.TrackCtl_SetToolTip( tostring(message), x+17, y+17, false )
end

function Main()
    for k, v in pairs( vals ) do
        reaper.BR_Win32_WritePrivateProfileString( "reaper", k, v, reaper_ini_file )
    end

    DisplayTooltip("Dark colors saved.\nRestart REAPER to apply.\n[Prefence - General - Advanced Settings] to restore.")
end

Main()