--[[
* ReaScript Name: Set SWS project startup action extstate value to On
* About: Put this action at start of your SWS Project startup action, to allow other scripts to check if they are being run from this.
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts/
 * Licence: GPL v3
 * REAPER: 5.0
 * Version:  1.0
--]]

ext_name = "XR_SWSProjectStartupAction"
ext_key = "IsRunning"
console = false

function Msg(val)
  reaper.ShowConsoleMsg(tostring(val).."\n")
end

function Main()
  reaper.SetProjExtState( 0, ext_name, ext_key, "" )
  if console then
    retval, value = reaper.GetProjExtState(0, ext_name, ext_key)
    if value == "" then value = "false" end
    Msg("SWS Project startup action = " .. value)
  end
end

reaper.defer(Main)
