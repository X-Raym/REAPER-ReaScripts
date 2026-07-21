--[[
 * ReaScript Name: Change transport theme element background color according to ripple state
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Toolbar button toggle state for script actions?
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=164034
 * REAPER: 6.0
 * Version: 1.0.0
--]]

--[[
 * Changelog:
 * v1.0.0 (2026-07-21)
  + Initial Release
--]]

-----------------------------------------------------------
-- USER CONFIG AREA --
-----------------------------------------------------------

-- Use Preset Script for safe moding or to create a new action with your own values
-- https://github.com/X-Raym/REAPER-ReaScripts/tree/master/Templates/Script%20Preset

color = "#FF0000"

theme_elements = {
  "col_tl_bgsel", "col_tl_bgsel2", "midi_selbg"
}

-----------------------------------------------------------
                              -- ENF OF USER CONFIG AREA --
-----------------------------------------------------------

function Msg(v)
  reaper.ShowConsoleMsg( tostring( v ) .. "\n" )
end

function HexToInt( hex )
  local r, g, b = HexToRGB( hex )
  local int =  reaper.ColorToNative( r, g, b )|16777216
  return int
end

function HexToRGB( hex )
  local hex = hex:gsub("#","")
  local R = tonumber("0x"..hex:sub(1,2))
  local G = tonumber("0x"..hex:sub(3,4))
  local B = tonumber("0x"..hex:sub(5,6))
  return R, G, B
end

-- Set ToolBar Button State
function SetButtonState( set )
  if not set then set = 0 end
  local is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  local state = reaper.GetToggleCommandStateEx( sec, cmd )
  reaper.SetToggleCommandState( sec, cmd, set ) -- Set ON
  reaper.RefreshToolbar2( sec, cmd )
end

function Exit()
  SetButtonState()
  for i, theme_element in ipairs( theme_elements ) do
    reaper.SetThemeColor( theme_element, -1,  0)
  end
  reaper.UpdateTimeline()
end


function Main()

  local is_loop = reaper.GetSetRepeat(-1) == 1
  local play_state = reaper.GetPlayState()
  if is_loop ~= last_loop then
    for i, theme_element in ipairs( theme_elements ) do
      reaper.SetThemeColor( theme_element, is_loop and color or -1,  0)
      reaper.UpdateTimeline()
    end
  end

  last_is_loop = is_loop
  reaper.defer(Main)
end

function Init()

  if reaper.SetThemeColor then
    last_is_loop = reaper.GetSetRepeat(-1)

    color = HexToInt(  color )

    SetButtonState( 1 )
    Main()
    reaper.atexit( Exit )
  else
    reaper.ShowConsoleMsg("This isn't available in your REAPER version. Requires v6.09pre minimum.")
  end
end

if not preset_file then
  Init()
end
