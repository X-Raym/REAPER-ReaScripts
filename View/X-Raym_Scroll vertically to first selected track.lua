--[[
 * ReaScript Name: Scroll vertically to first selected track
 * About: Alternative to native Track: Vertical scroll selected tracks into view, but scroll to top instead
 * Author: X-Raym
 * Author URI: https://extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2022-11-19)
  + Initial Release
--]]

if not reaper.JS_Window_FindChildByID then
  reaper.ShowMessageBox( 'Please install or update js_ReaScriptAPI extension, available via Reapack.', 'Missing Dependency', 0)
end

function ScrollTrackToTop( track )
  -- NOTE: No check for visibility, cause not needed for now

  reaper.PreventUIRefresh( 1 )
  
  local track_tcpy = reaper.GetMediaTrackInfo_Value( track, "I_TCPY" )
  
  local mainHWND = reaper.GetMainHwnd()
  local windowHWND = reaper.JS_Window_FindChildByID(mainHWND, 1000)
  local scroll_retval, scroll_position, scroll_pageSize, scroll_min, scroll_max, scroll_trackPos = reaper.JS_Window_GetScrollInfo( windowHWND, "v" )
  reaper.JS_Window_SetScrollPos( windowHWND, "v", track_tcpy + scroll_position )
  
  reaper.PreventUIRefresh( -1 )

end


function Init()
  track = reaper.GetSelectedTrack( 0, 0)
  if not track then return end
  
  ScrollTrackToTop( track )
end

reaper.defer(Init)
