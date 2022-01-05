--[[
 * ReaScript Name: X-Raym_Set SWS global startup action extstate value to Off
 * About: Put this action at start of your SWS Global startup action, to allow other scripts to check if they are being run from this.
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts/
 * Licence: GPL v3
 * REAPER: 5.0
 * Version:  1.0
--]]

ext_name = "XR_SWSGlobalStartupAction"
ext_key = "IsRunning"
console = false

function Msg(val)
  reaper.ShowConsoleMsg(tostring(val).."\n")
end

function Main()
  reaper.DeleteExtState( ext_name, ext_key, true )
  if console then
    value = reaper.GetExtState(ext_name, ext_key)
    if value == "" then value = "false" end
    Msg("SWS Global startup action = " .. value)
  end
end

reaper.defer(Main)
