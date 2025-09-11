--[[
 * ReaScript Name: Perform action until keyboard shortcut released (Functions)
 * Author: X-Raym
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.1
--]]
 
--[[
 * Changelog:
 * v1.1 (2025-09-11)
  + Preset script support
  # Renamed from Continuous push shortcut
  # Released on X-Raym free repo
 * v1.0 (2019-04-10)
  + Initial Release
--]]

-- USER CONFIG AREA ------------------------------------------------------

-- Use Preset Script for safe moding or to create a new action with your own values
-- https://github.com/X-Raym/REAPER-ReaScripts/tree/master/Templates/Script%20Preset

action_id = 40725 -- 40725 = Grid: Toggle measure grid
action_context = 0
VirtualKeyCode = 0x47 -- G -- https://docs.microsoft.com/en-us/windows/desktop/inputdev/virtual-key-codes

console = true

-------------------------------------------------- END OF USER CONFIG AREA

--a_is_new_value, a_filename, a_sectionID, a_cmdID, a_mode, a_resolution, a_val, a_contextstr = reaper.get_action_context()
--key = a_contextstr:match("key:V:(%d+)")

-- Display a message in the console for debugging
function Msg(value)
  if console then
    reaper.ShowConsoleMsg(tostring(value) .. "\n")
  end
end

if not reaper.JS_VKeys_GetState then
  reaper.MB('Please Install js_ReaScriptAPI extension.\nhttps://forum.cockos.com/showthread.php?t=212174\n', "Error", 1)
  return false
end

-- Set ToolBar Button State
function SetButtonState( set )
  set = set or 0
  local is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  local state = reaper.GetToggleCommandStateEx( sec, cmd )
  reaper.SetToggleCommandState( sec, cmd, set ) -- Set ON
  reaper.RefreshToolbar2( sec, cmd )
end
  
-- Main Function (which loop in background)
function Main()

  state = reaper.JS_VKeys_GetState(0)
  if state:byte(VirtualKeyCode) ~= 0 then
    if toggle_state == 0 then
      --reaper.ShowConsoleMsg("G key is pressed" .. "\n")
      reaper.Main_OnCommand( action_id, action_context ) -- Toggle grid
      toggle_state = 1
    end
  else
    if toggle_state == 1 then
      --reaper.ShowConsoleMsg("G key is released" .. "\n")
      reaper.Main_OnCommand( action_id, action_context ) -- Toggle grid
      toggle_state = 0
    end
  end
  
  reaper.defer( Main )
  
end

-- RUN
function Init()
  reaper.ClearConsole()
  toggle_state = reaper.GetToggleCommandState( action_id )
  SetButtonState( 1 )
  Main()
  reaper.atexit( SetButtonState )
end

if not preset_file_init then
  Init()
end
