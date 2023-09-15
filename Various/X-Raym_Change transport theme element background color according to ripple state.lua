--[[
 * ReaScript Name: Change transport theme element background color according to ripple state
 * About: Change theme elements color base on ripple state. Edit the script to change value. Use custom action and SWS start up actions for loading this right at reaper startup. Thx nikolalkc for the inspiration!
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Toolbar button toggle state for script actions?
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=164034
 * REAPER: 5.0
 * Extensions: SWS v2.10.0
 * Version: 1.0.1
--]]

--[[
 * Changelog:
 * v1.0.1 (2020-08-18)
  # New script name
 * v1.0 (2020-05-08)
  + Initial Release
--]]

-- USER CONFIG AREA ------------
ripple_alltracks_color = "#00FF00"
ripple_onetrack_color = "#0000FF"

-- END OF USER CONFIG AREA -----

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


function Main()

  local ripple = reaper.SNM_GetIntConfigVar("projripedit", -666)
  local play_state = reaper.GetPlayState()
  if ripple ~= last_ripple or play_state ~= last_plat_state then
    if play_state ~= 5 and play_state ~=6 then -- Let red bar for recording state
      reaper.SetThemeColor( "ts_lane_bg", ripple_colors[ripple],  0)
      reaper.SetThemeColor( "region_lane_bg", ripple_colors[ripple],  0)
      reaper.SetThemeColor( "marker_lane_bg", ripple_colors[ripple],  0)
      reaper.UpdateTimeline()
    end
  end

  last_ripple = ripple
  last_play_state = play_state
  reaper.defer(Main)
end

if reaper.SetThemeColor then
  last_ripple = reaper.SNM_GetIntConfigVar("projripedit", -666)

  ripple_colors = {HexToInt(  ripple_onetrack_color ), HexToInt( ripple_alltracks_color )}
  ripple_colors[0] = -1

  SetButtonState( 1 )
  Main()
  reaper.atexit( SetButtonState )
else
  reaper.ShowConsoleMsg("This isn't available in your REAPER version. Requires v6.09pre minimum.")
end
