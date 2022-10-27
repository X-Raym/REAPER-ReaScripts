--[[
 * ReaScript Name: Intercept spacebar key
 * About: Prevent usage of spacebar key while running (typically, to prevent end of recording). Scope is wide, it can deactivate spacebar on unwanted window.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > REAPER ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 6.0
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2022-10-27)
  + Initial Release
 --]]
 
 
keyCode = 0x20 -- SPACE -- https://docs.microsoft.com/en-us/windows/desktop/inputdev/virtual-key-codes

 -- Set ToolBar Button State
function SetButtonState( set )
  local is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  reaper.SetToggleCommandState( sec, cmd, set or 0 )
  reaper.RefreshToolbar2( sec, cmd )
end

function Exit()
  SetButtonState()
  reaper.JS_VKeys_Intercept( keyCode, -1 )
end


-- Main Function (which loop in background)
function Main()
  
  if not first_run then
    reaper.JS_VKeys_Intercept( keyCode, 1 )
    first_run = true
  end
  
  reaper.defer( Main )
  
end



-- RUN
SetButtonState( 1 )
Main()
reaper.atexit( Exit )
