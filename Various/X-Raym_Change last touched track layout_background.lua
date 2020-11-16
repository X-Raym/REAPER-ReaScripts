--[[
 * ReaScript Name: Change last touched track layout
 * Screenshot: https://i.imgur.com/7ONmP3V.gif
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 2.0.6
--]]
 
--[[
 * Changelog:
 * v2.0.6 (2020-11-16)
  # Remove project dirty
 * v2.0.5 (2020-11-16)
  # Bug fix
 * v2.0.4 (2020-11-16)
  # Deactivate console
 * v2.0.3 (2020-11-16)
  # ProjExtState base
 * v1.0.3 (2020-11-16)
  + Better project tab
 * v1.0.2 (2020-11-16)
  + Better project tab but still buggy
 * v1.0.1 (2020-11-16)
  + Be sure last track still exist
 * v1.0 (2020-11-16)
  + Initial Release
--]]

-- NOTE: Known issue: Project tab have to be in focus for changing layout. https://forum.cockos.com/showthread.php?p=2365622#post2365622
-- THis could be solve if ATexit could differentiate between script closed manually or closed at reaper exit

-- USER CONFIG AREA ---------------------
mcp_layout = "1. Classic Default MCP - Blue Fader"
tcp_layout = "1. Classic Default TCP (vertical meters) - Blue Fader"
console = false
-----------------------------------------

ext_name = "XR_LastTouchedTrackLayout"

function Msg(val)
  if console then
    reaper.ShowConsoleMsg(tostring( val ).."\n")
  end
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
  reaper.ClearConsole()
  local cur_proj, projfn = reaper.EnumProjects( -1 )
  local proj
  local i = 0
  console = true
  repeat
    proj, projfn = reaper.EnumProjects( i )
    reaper.SelectProjectInstance( proj )
    Msg("\n-------------")
    Msg(projfn)
    if proj then
      local ext_state_retval, last_track_guid = reaper.GetProjExtState(proj, ext_name, "track_guid")
      Msg(i)
      Msg(last_track_guid)
      local last_track = reaper.BR_GetMediaTrackByGUID( i, last_track_guid )
      Msg(last_track)
      if last_track and reaper.ValidatePtr2(i,last_track, 'MediaTrack*') then
        Msg("VALID")
        retval, name = reaper.GetTrackName( last_track )
        Msg(name)
        local ext_state_retval, last_track_mcp = reaper.GetProjExtState(i, ext_name, "mcp_layout")
        local ext_state_retval, last_track_tcp = reaper.GetProjExtState(i, ext_name, "tcp_layout")
        Msg(last_track_mcp)
        Msg(last_track_tcp)
        if last_track_mcp == "Default" then last_track_mcp = "" end
        if last_track_tcp == "Default" then last_track_tcp = "" end
        if mcp_layout and last_track_mcp then
          local retval, _ = reaper.GetSetMediaTrackInfo_String( last_track, "P_MCP_LAYOUT", last_track_mcp, true )
          Msg(retval)
        end
        if tcp_layout and last_track_tcp then
          local retval, _ = reaper.GetSetMediaTrackInfo_String( last_track, "P_TCP_LAYOUT", last_track_tcp, true )
          Msg(retval)
        end
      end
    end
    i = i + 1
  until not proj
  reaper.SelectProjectInstance( cur_proj )
end

-- Main Function (which loop in background)
function main()

  local cur_proj, projfn = reaper.EnumProjects( -1 )

  local track = reaper.GetLastTouchedTrack()
  local ext_state_retval, last_track_guid = reaper.GetProjExtState(-1, ext_name, "track_guid")
  local last_track = reaper.BR_GetMediaTrackByGUID( -1, last_track_guid )
  if track and (track ~= last_track or not first_run) then
    if last_track and reaper.ValidatePtr(last_track, 'MediaTrack*') then
      ext_state_retval, last_track_tcp = reaper.GetProjExtState(-1, ext_name, "tcp_layout")
      ext_state_retval, last_track_mcp = reaper.GetProjExtState(-1, ext_name, "mcp_layout")
      if last_track_mcp == "Default" then last_track_mcp = "" end
      if last_track_tcp == "Default" then last_track_tcp = "" end
      last_track =   reaper.GetTrack(0, reaper.GetMediaTrackInfo_Value(last_track, "IP_TRACKNUMBER") - 1 )
      local retval, _ = reaper.GetSetMediaTrackInfo_String( last_track, "P_MCP_LAYOUT", last_track_mcp, true )
      local retval, _ = reaper.GetSetMediaTrackInfo_String( last_track, "P_TCP_LAYOUT", last_track_tcp, true )
    end
    
    -- Backup Track Layout
    local retval, mcp_layout_last = reaper.GetSetMediaTrackInfo_String( track, "P_MCP_LAYOUT", "", false )
    local retval, tcp_layout_last = reaper.GetSetMediaTrackInfo_String( track, "P_TCP_LAYOUT", "", false )
    if mcp_layout_last == "" then mcp_layout_last = "Default" end
    if tcp_layout_last == "" then tcp_layout_last = "Default" end
    
    reaper.SetProjExtState(cur_proj, ext_name, "tcp_layout", tcp_layout_last)
    reaper.SetProjExtState(cur_proj, ext_name, "mcp_layout", mcp_layout_last)
    reaper.SetProjExtState(cur_proj, ext_name, "track_guid", reaper.GetTrackGUID(track))
    
    if mcp_layout then
      local retval, _ = reaper.GetSetMediaTrackInfo_String( track, "P_MCP_LAYOUT", mcp_layout, true )
    end
    if tcp_layout then
      local retval, _ = reaper.GetSetMediaTrackInfo_String( track, "P_TCP_LAYOUT", tcp_layout, true )
    end
    
  end
  
  if first_run then first_run = false end
  
  if cur_proj ~= last_proj then
    reaper.TrackList_AdjustWindows( false ) -- Update TCP and MCP -- Maybe not necessary
  end
  
  last_proj = cur_proj
  
  reaper.defer( main )
  
end

first_run = true

-- RUN
function Init()
  SetButtonState( 1 )
  main()
  reaper.atexit( Exit )
end

if not preset_file_init then -- DOC: https://gist.github.com/X-Raym/f7f6328b82fe37e5ecbb3b81aff0b744
  Init()
end
