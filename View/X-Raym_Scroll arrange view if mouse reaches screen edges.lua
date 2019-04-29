--[[
 * ReaScript Name: Scroll arrange view if mouse reaches screen edges
 * About: A template script for running in background REAPER ReaScript, with toolbar button ON/OFF state.
 * Screenshot: https://i.imgur.com/0npTbEB.gifv
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: View and Zoom (Various)
 * Forum Thread URI: https://forum.cockos.com/showthread.php?p=1523568#post1523568
 * REAPER: 5.0
 * Extensions: js_extension
 * Version: 1.2.1
--]]
 
--[[
 * Changelog:
 * v1.2.1 (2019-03-29)
  # remove mouse cursor change because of menu bug
 * v1.2 (2019-03-28)
  + Shift Key for fast speed
  + Ctrl key for slow speed
 * v1.1 (2019-03-23)
  + Scroll only if REAPER has focus (thanks Edgemeal!)
  + Scroll at quarter (no need to be right on screen corners for diagonal scroll)
 * v1.0 (2019-03-22)
  + Initial Release
--]]
 
-- TODO:
-- Scroll Only if REAPER is in FOCUS
-- MAJ + Scroll FAST
-- Find on which screen is REAPER
 
 -- Set ToolBar Button State
function SetButtonState( set )
  if not set then set = 0 end
  local is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  local state = reaper.GetToggleCommandStateEx( sec, cmd )
  reaper.SetToggleCommandState( sec, cmd, set ) -- Set ON
  reaper.RefreshToolbar2( sec, cmd )
end

function ReaperHasFocus()
  hwnd = reaper.JS_Window_GetForeground() -- may be nil when switching windows, so check it!
  if hwnd then
    rea_hwnd = reaper.GetMainHwnd()
    if hwnd == rea_hwnd or reaper.JS_Window_GetParent(hwnd) == rea_hwnd then
      return true
    end 
  end 
  return false
end

function Main()

  if ReaperHasFocus() then

    mouse_x, mouse_y = reaper.GetMousePosition()
    shift = reaper.JS_Mouse_GetState( 8 )
    ctrl = reaper.JS_Mouse_GetState( 4 )
    
    multiplicator_x = 1
    multiplicator_y = 3
    
    if shift == 8 then
      multiplicator_x = 5
      multiplicator_y = 10
    end
    
    if ctrl == 4 then
      multiplicator_x = 1
      multiplicator_y = 1
    end
    
    val_x = 0
    val_y = 0    
    
    if mouse_x == 0 or ((mouse_y == 0 or mouse_y >= screen_bottom - 1 ) and mouse_x <= screen_right * 0.25 ) then
      val_x = -1 * multiplicator_x
      --reaper.JS_Mouse_SetCursor( cursor_left )
    end
    
    if mouse_x >= screen_right - 1 or ((mouse_y == 0 or mouse_y >= screen_bottom - 1 ) and mouse_x >= screen_right * 0.75 )then
     val_x = 1 * multiplicator_x
    end
    
    if mouse_y == 0 or ((mouse_x == 0 or mouse_x >= screen_right - 1 ) and mouse_y <= screen_bottom * 0.25 ) then
      val_y = -1 * multiplicator_y
      -- reaper.JS_Mouse_SetCursor( cursor_up )
    end
    
    if mouse_y >= screen_bottom - 1 or ((mouse_x == 0 or mouse_x >= screen_right - 1 ) and mouse_y >= screen_bottom * 0.75 ) then
      val_y = 1 * multiplicator_y
    end
    
    if val_x ~= 0 or val_y ~= 0 then
      reaper.CSurf_OnScroll( val_x, val_y )
    end
  
  end
  
  reaper.defer(Main)
  
end

if not reaper.JS_Window_MonitorFromRect then
  reaper.ShowConsoleMsg('Please Install js_ReaScriptAPI extension.\nhttps://forum.cockos.com/showthread.php?t=212174\n')
else

  screen_left, screen_top, screen_right, screen_bottom = reaper.JS_Window_MonitorFromRect(0, 0, 0, 0, false)
  
  cursor_up = reaper.JS_Mouse_LoadCursor( 32516 )
  cursor_left = reaper.JS_Mouse_LoadCursor( 32644 )
  
  SetButtonState( 1 )
  Main()
  reaper.atexit( SetButtonState )
  
end
