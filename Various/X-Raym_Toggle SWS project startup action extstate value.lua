--[[
 * ReaScript Name: Toggle SWS project startup action extstate value
 * About: Put this action at start and end of your SWS Global startup action, to allow ofther script check if they are being run from this. Set this as "run new instance" when the popup will appear.
 * Author URI: http://extremraym.com
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
  retval, value = reaper.GetProjExtState( 0, ext_name, ext_key )
  if value == "" then
    reaper.SetProjExtState( 0, ext_name, ext_key, "true" )
  else
    reaper.SetProjExtState( 0, ext_name, ext_key, "" )
  end
  if console then
    retval, value = reaper.GetProjExtState(0, ext_name, ext_key)
    if value == "" then value = "false" end
    Msg("SWS Project startup action = " .. value)
  end
end

reaper.defer(Main)
