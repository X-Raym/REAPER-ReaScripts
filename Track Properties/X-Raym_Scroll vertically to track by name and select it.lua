--[[
 * ReaScript Name: Scroll vertically to track by name and select it
 * Author: X-Raym
 * Author URI: https://extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Track Selection (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1569551
 * REAPER: 5.0
 * Version: 1.3
 * Screenshot: https://i.imgur.com/6qMLP2s.gifv
--]]

--[[
 * Changelog:
 * v1.3 (2022-11-19)
  # Scroll track to top or arrange view custom function
  + Only check visible tracks
 * v1.2.1 (2022-11-08)
  # Preset file support
 * v1.2 (2019-09-27)
  + User Config Area
 * v1.1 (2019-06-23)
  + Also set as last touched
 * v1.0 (2019-06-23)
  + Initial Release
--]]

-- USER CONFIG AREA -----------

-- To mod the script, better create preset file
-- https://gist.github.com/X-Raym/f7f6328b82fe37e5ecbb3b81aff0b744

popup = true -- true/false

scroll_track_to_top = true -- true needs js_ReaScriptAPI extension

str = "" -- choosen track name if popup is false

------------------------------

if scroll_track_to_top and not reaper.JS_Window_FindChildByID then
  -- reaper.ShowMessageBox( 'Please install or update js_ReaScriptAPI extension, available via Reapack.', 'Missing Dependency', 0)
  scroll_track_to_top = false
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

function Main()
  reaper.Main_OnCommand(40297,0)-- Unselect all tracks
  if popup then
    retval, str = reaper.GetUserInputs("Search Track Name", 1, "Track Name ?extrawidth=150", "")
  end
  if (popup and retval) or not popup then
    str = str:lower()
    local count_tracks = reaper.CountTracks(0)
    for i = 0, count_tracks - 1 do
      local track = reaper.GetTrack( 0, i )
      local r, track_name = reaper.GetTrackName( track )
      local track_tcp_visible = reaper.GetMediaTrackInfo_Value( track, "B_SHOWINTCP" )
      -- if track_name:lower() == str then
      if track_tcp_visible == 1 and track_name:lower():match("^(" .. str .. ")") then
        reaper.SetTrackSelected(track, true)
        if scroll_track_to_top then
          ScrollTrackToTop( track )
        else
          reaper.Main_OnCommand(40913,0) -- Track: Vertical scroll selected tracks into view
        end
        reaper.Main_OnCommand(40914,0) -- Track: Set first selected track as last touched track
        break
      end
    end
  end
end


function Init()
  reaper.Undo_BeginBlock()
  Main()
  reaper.Undo_EndBlock("Scroll vertically to track by name and select it", -1)
end

if not preset_file_init then
  Init()
end
