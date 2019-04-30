--[[
 * ReaScript Name: Convert region names for the dedicated web browser interface
 * About: Have a track named lyrics and text items on it. Run the web interface.
 * Screenshot: https://monosnap.com/file/lDLQNmSP9K6SHCdK7tMWXS3zW31lP7
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * Link: Forum https://forum.cockos.com/showthread.php?p=2127630#post2127630
 * REAPER: 5.0
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2019-08-30)
  + Initial Release
 --]]
 
 -- Set ToolBar Button State
function SetButtonState( set )
  if not set then set = 0 end
  local is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  local state = reaper.GetToggleCommandStateEx( sec, cmd )
  reaper.SetToggleCommandState( sec, cmd, set ) -- Set ON
  reaper.RefreshToolbar2( sec, cmd )
end


-- Main Function (which loop in background)
function main()
  
  -- Get play or edit cursor
  if reaper.GetPlayState() > 0 then
    cur_pos = reaper.GetPlayPosition()
  else
    cur_pos = reaper.GetCursorPosition()
  end
  
  marker_idx, region_idx = reaper.GetLastMarkerAndCurRegion(0, cur_pos)
  if region_idx >= 0 then -- IF LAST REGION
  
    retval, is_region, region_start, region_end, region_name, markrgnindexnumber, region_color = reaper.EnumProjectMarkers3(0, region_idx)
    if region_name ~= notes then
      notes = region_name
      reaper.SetProjExtState( 0, "XR_Lyrics", "text", notes )
    end
    
  else
    
    if notes then
      notes = nil
      reaper.SetProjExtState( 0, "XR_Lyrics", "text", "" )
    end
    
  end
    
  reaper.defer( main )
  
end


notes = nil

-- RUN
SetButtonState( 1 )
main()
reaper.atexit( SetButtonState )
