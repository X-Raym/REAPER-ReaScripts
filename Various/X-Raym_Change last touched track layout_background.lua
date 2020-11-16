--[[
 * ReaScript Name: Change last touched track layout
 * Screenshot: https://i.imgur.com/7ONmP3V.gif
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0.1
--]]
 
--[[
 * Changelog:
 * v1.0.1 (2020-11-16)
  + Be sure last track still exist
 * v1.0 (2020-11-16)
  + Initial Release
--]]

-- USER CONFIG AREA ---------------------
mcp_layout = "1. Classic Default MCP - Blue Fader"
tcp_layout = "1. Classic Default TCP (vertical meters) - Blue Fader"
-----------------------------------------

function Msg(val)
  reaper.ShowConsoleMsg(tostring( val ).."\n")
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
  if last_track and reaper.ValidatePtr(last_track, 'MediaTrack*') then
    if mcp_layout and mcp_layout_last then
      local retval, _ = reaper.GetSetMediaTrackInfo_String( last_track, "P_MCP_LAYOUT", mcp_layout_last, true )
    end
    if tcp_layout and tcp_layout_last then
      local retval, _ = reaper.GetSetMediaTrackInfo_String( last_track, "P_TCP_LAYOUT", tcp_layout_last, true )
    end
  end
end

-- Main Function (which loop in background)
function main()
  
  track = reaper.GetLastTouchedTrack( 0 )
  
  if track and track ~= last_track then

    if last_track and reaper.ValidatePtr(last_track, 'MediaTrack*') then
      if mcp_layout and mcp_layout_last then
        local retval, _ = reaper.GetSetMediaTrackInfo_String( last_track, "P_MCP_LAYOUT", mcp_layout_last, true )
      end
      if tcp_layout and tcp_layout_last then
        local retval, _ = reaper.GetSetMediaTrackInfo_String( last_track, "P_TCP_LAYOUT", tcp_layout_last, true )
      end
    end
  
    retval, mcp_layout_last = reaper.GetSetMediaTrackInfo_String( track, "P_MCP_LAYOUT", "", false )
    retval, tcp_layout_last = reaper.GetSetMediaTrackInfo_String( track, "P_TCP_LAYOUT", "", false )
    
    if mcp_layout then
      local retval, _ = reaper.GetSetMediaTrackInfo_String( track, "P_MCP_LAYOUT", mcp_layout, true )
    end
    if tcp_layout then
      local retval, _ = reaper.GetSetMediaTrackInfo_String( track, "P_TCP_LAYOUT", tcp_layout, true )
    end
  end
  
  last_track = track
  
  reaper.defer( main )
  
end



-- RUN
function Init()
  SetButtonState( 1 )
  main()
  reaper.atexit( Exit )
end

if not preset_file_init then -- DOC: https://gist.github.com/X-Raym/f7f6328b82fe37e5ecbb3b81aff0b744
  Init()
end
