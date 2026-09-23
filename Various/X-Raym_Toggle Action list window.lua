--[[
 * ReaScript Name: Toggle Action list window
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 6.0
 * Version: 1.0.0
 * Provides: [main=main,midi_editor,midi_inlineeditor,midi_eventlisteditor,mediaexplorer,crossfade_editor] .
--]]

--[[
 * Changelog:
 * v1.0.0 (2026-09-23)
  + Initial Release
--]]

if not reaper.JS_ReaScriptAPI_Version then
  reaper.MB( 'Please install or update js_ReaScriptAPI extension, available via Reapack.', 'Missing Dependency', 0)
  return false
end

hwnd = reaper.JS_Window_Find( "Actions", false )
if hwnd then
  reaper.JS_Window_Destroy( hwnd )
else
 is_new_value, filename, sectionID, cmdID, mode, resolution, val, contextstr = reaper.get_action_context()
 reaper.ShowActionList( sectionID, callerWnd )
end