--[[
 * ReaScript Name: Send SWS extra project notes to Lyrics web interface
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Link: Forum https://forum.cockos.com/showthread.php?p=2127630#post2127630
 * Version: 1.0.0
--]]

--[[
 * Changelog:
 * v1.0.0 (2026-07-26)
  + Initial Release
--]]


-- GLOBALS -------------------------------------------------

str_no_text = "--XR-NO-TEXT--"

ext_name = "XR_Lyrics"
ext_keys = { "text" }

-- DEBUG

function Msg( val )
  reaper.ShowConsoleMsg( tostring( val ) .. "\n" )
end

-- DEFER

 -- Set ToolBar Button State
function SetButtonState( set )
  if not set then set = 0 end
  local is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  local state = reaper.GetToggleCommandStateEx( sec, cmd )
  reaper.SetToggleCommandState( sec, cmd, set ) -- Set ON
  reaper.RefreshToolbar2( sec, cmd )
end

function Exit()
  for i, k in ipairs( ext_keys ) do
    reaper.SetProjExtState( 0, ext_name, k, "" )
  end
  SetButtonState()
end


function Main()

  notes = reaper.JB_GetSWSExtraProjectNotes( -1 ):gsub("\r?\n", "<br>")
  if notes ~= text then
    text = notes == "" and str_no_text or notes
    reaper.SetProjExtState( 0, ext_name, "text", text )
  end

  reaper.defer( Main )

end

-- RUN -----------------------------------------------------

reaper.ClearConsole()

Main()
reaper.atexit( Exit )

