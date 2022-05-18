--[[
 * ReaScript Name: Scroll arrange view if mouse reaches reaper window edges
 * Screenshot: https://i.imgur.com/0npTbEB.gifv
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: View and Zoom (Various)
 * Forum Thread URI: https://forum.cockos.com/showthread.php?p=1523568#post1523568
 * REAPER: 5.0
 * Extensions: js_extension
 * Version: 1.1
--]]

--[[
 * Changelog:
 * v1.1 (2022-05-18)
  # Better API
 * v1.0.1 (2022-05-18)
  # Change margin_top value
 * v1.0 (2022-05-18)
  + Initial Release
--]]

-- TODO:
-- Find on which screen is REAPER
-- Fork of X-Raym_Scroll arrange view if mouse reaches screen edges.lua v1.2.0

-- USER CONFIG AREA ----------------------------------
margin_left = 0
margin_right = 1
margin_top = 0
margin_bottom = 1
window_mode = true -- true/false consider the full screen or just the main reaper window size
------------------------------------------------------

 -- Set ToolBar Button State
function SetButtonState( set )
  if not set then set = 0 end
  local is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  local state = reaper.GetToggleCommandStateEx( sec, cmd )
  reaper.SetToggleCommandState( sec, cmd, set ) -- Set ON
  reaper.RefreshToolbar2( sec, cmd )
end

function ReaperHasFocus()
  local hwnd = reaper.JS_Window_GetForeground() -- may be nil when switching windows, so check it!
  if hwnd then
    local rea_hwnd = reaper.GetMainHwnd()
    if hwnd == rea_hwnd or reaper.JS_Window_GetParent(hwnd) == rea_hwnd then
      return true
    end
  end
  return false
end

function Main()

  if ReaperHasFocus() then
  
    retval, window_left, window_top, window_right, window_bottom = reaper.BR_Win32_GetWindowRect( reaper_hwnd )

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

    if mouse_x <= window_left - margin_left or ((mouse_y == 0 or mouse_y >= window_bottom - 1 ) and mouse_x <= window_right * 0.25 ) then
      val_x = -1 * multiplicator_x
      --reaper.JS_Mouse_SetCursor( cursor_left )
    end

    if mouse_x >= window_right - margin_right or ((mouse_y == 0 or mouse_y >= window_bottom - 1 ) and mouse_x >= window_right * 0.75 )then
     val_x = 1 * multiplicator_x
    end

    if mouse_y <= window_top - margin_top or ((mouse_x == 0 or mouse_x >= window_right - 1 ) and mouse_y <= window_bottom * 0.25 ) then
      val_y = -1 * multiplicator_y
      -- reaper.JS_Mouse_SetCursor( cursor_up )
    end

    if mouse_y >= window_bottom - margin_bottom or ((mouse_x == 0 or mouse_x >= window_right - 1 ) and mouse_y >= window_bottom * 0.75 ) then
      val_y = 1 * multiplicator_y
    end

    if val_x ~= 0 or val_y ~= 0 then
      reaper.CSurf_OnScroll( val_x, val_y )
    end

  end

  reaper.defer(Main)

end

function Init()
  if not reaper.JS_Window_MonitorFromRect then
    reaper.ShowConsoleMsg('Please Install js_ReaScriptAPI extension.\nhttps://forum.cockos.com/showthread.php?t=212174\n')
  else
    reaper_hwnd = reaper.GetMainHwnd()
    screen_left, screen_top, screen_right, screen_bottom = reaper.JS_Window_MonitorFromRect(0, 0, 0, 0, false)

    cursor_up = reaper.JS_Mouse_LoadCursor( 32516 )
    cursor_left = reaper.JS_Mouse_LoadCursor( 32644 )

    SetButtonState( 1 )
    Main()
    reaper.atexit( SetButtonState )
  end
end

if not preset_file_init then
  Init()
end
