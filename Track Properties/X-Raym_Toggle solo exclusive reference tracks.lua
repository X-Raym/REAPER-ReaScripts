--[[
 * ReaScript Name: Toggle solo exclusive reference tracks
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0.1
 * Provides: [main=main,midi_editor] .
--]]

--[[
 * Changelog:
 * v1.0 (2024-03-13)
  + Initial release
--]]


-- USER CONFIG AREA -----------

-- Use Preset Script for safe moding or to create a new action with your own values
-- https://github.com/X-Raym/REAPER-ReaScripts/tree/master/Templates/Script%20Preset

undo_text = "Toggle solo exclusive reference tracks"
also_select = true
also_lock = true
exclusive = true
fallback_to_other_sel_track = true -- If all track solo, fallback to other sel track (true) or fallback to previous state
console = true

------------------------------

if not reaper.SNM_CreateFastString then
  reaper.MB("SWS extension is required by this script.\nPlease download it on http://www.sws-extension.org/", "Warning", 0)
  return
end

function Msg( val )
  if console then
    reaper.ShowConsoleMsg( tostring( val ) .. "\n" )
  end
end

function Tooltip(message)
  local x, y = reaper.GetMousePosition()
  reaper.TrackCtl_SetToolTip( tostring(message), x+17, y+17, false )
end

function GetTrackChunk(track)
  if not track then return end
  local fast_str, track_chunk
  fast_str = reaper.SNM_CreateFastString("")
  if reaper.SNM_GetSetObjectState(track, fast_str, false, false) then
    track_chunk = reaper.SNM_GetFastString(fast_str)
  end
  reaper.SNM_DeleteFastString(fast_str)
  return track_chunk
end

function SetTrackChunk(track, track_chunk)
  if not (track and track_chunk) then return end
  local fast_str, ret
  fast_str = reaper.SNM_CreateFastString("")
  if reaper.SNM_SetFastString(fast_str, track_chunk) then
    ret = reaper.SNM_GetSetObjectState(track, fast_str, true, false)
  end
  reaper.SNM_DeleteFastString(fast_str)
  return ret
end

function ToggleTrackLock( track, val, chunk )
  local chunk = chunk or GetTrackChunk(track)
  local track_lock = chunk:find("\nLOCK 1\n") and 1 or 0
  local new_lock
  if track_lock == 1 then
    if not val or val == 0 then
      SetTrackChunk( track, chunk:gsub("\nLOCK 1\n", "\n" ) )
      new_lock = 0
    else
      new_lock = 1
    end
  else
    if not val or val == 1 then
      SetTrackChunk( track, chunk:gsub("^<TRACK", "^TRACK\nLOCK 1\n" ) )
      new_lock = 1
    else
      new_lock = 0
    end
  end
  return track_lock, new_lock, chunk
end

function Main()
  all_ref_solo = true
  ref_tracks = {}
  other_tracks = {}
  other_tracks_selected = {}
  for i = 0, count_all_tracks - 1 do
    local track = reaper.GetTrack(0, i)
    local retval, state = reaper.GetSetMediaTrackInfo_String( track, "P_EXT:XR_REF", "", false )
    if state == "REF" then
      table.insert( ref_tracks, track )
      if reaper.GetMediaTrackInfo_Value(track, "I_SOLO") == 0
      or reaper.GetMediaTrackInfo_Value(track, "B_MUTE") == 1 then
        all_ref_solo = false
      end
    else
      table.insert( other_tracks, track )
      if reaper.IsTrackSelected( track ) then
        table.insert( other_tracks_selected, track )
      end
    end
  end
  
  if #ref_tracks == 0 then
    Tooltip("No ref tracks")
    return
  end

  if all_ref_solo then
    Tooltip("Reference tracks unselected")
  else
    Tooltip("Reference tracks selected")
  end

  solo = all_ref_solo and 0 or 1
  mute = all_ref_solo and 1 or 0
  sel = all_ref_solo and 0 or 1
  lock = all_ref_solo and 1 or 0
  
  for i, track in ipairs( ref_tracks ) do
    local track_lock_a, track_lock_b = ToggleTrackLock( track, 0 ) -- Track needs to be unlock so API can pass
    reaper.SetMediaTrackInfo_Value(track, "I_SOLO", solo)
    reaper.SetMediaTrackInfo_Value(track, "B_MUTE", mute)
    if also_select then
      reaper.SetMediaTrackInfo_Value(track, "I_SELECTED", sel)
    end
    if also_lock then
      ToggleTrackLock( track, lock )
    else
      if track_lock_a == 1 then
        ToggleTrackLock( track, 1 ) -- restore lock
      end
    end
  end
  
  if exclusive then
    for i, track in ipairs( other_tracks ) do
      if all_ref_solo then -- then go back to previous track states
        if not fallback_to_other_sel_track or #other_tracks_selected == 0 then -- NOTE: If all ref track selected and no other track is selected, restore previous state, else just unselect ref tracks (code block above)
          local retval, state = reaper.GetSetMediaTrackInfo_String( track, "P_EXT:XR_REF", "", false )
          local solo, sel = state:match( "SOLO=(%d),SEL=(%d)" )
          if solo and sel then
            reaper.SetMediaTrackInfo_Value(track, "I_SOLO", solo)
            reaper.SetMediaTrackInfo_Value(track, "I_SELECTED", sel)
            local retval, state = reaper.GetSetMediaTrackInfo_String( track, "P_EXT:XR_REF", "", true )
          end
        end
      else -- then store current track state
        local solo = reaper.GetMediaTrackInfo_Value(track, "I_SOLO")
        local sel = reaper.GetMediaTrackInfo_Value(track, "I_SELECTED")
        local str = "SOLO=" .. math.floor( solo ) .. ",SEL=" .. math.floor( sel )
        local retval, state = reaper.GetSetMediaTrackInfo_String( track, "P_EXT:XR_REF", str, true )
        reaper.SetMediaTrackInfo_Value(track, "I_SOLO", 0)
        reaper.SetMediaTrackInfo_Value(track, "I_SELECTED", 0)
      end
    end
  end
end

function Run()
  count_all_tracks = reaper.CountTracks( 0 )
  if count_all_tracks == 0 then return end
  
  reaper.ClearConsole()
  
  reaper.PreventUIRefresh( 1 )
  
  -- reaper.Undo_BeginBlock()
  
  reaper.set_action_options( 1 )
  
  Main()
  
  reaper.TrackList_AdjustWindows( false )
  
  --reaper.Undo_EndBlock( undo_text, 0 )
  
  reaper.PreventUIRefresh( - 1 )
end

function Init()
  
  reaper.set_action_options( 1 )
  
  reaper.defer( Run )

end

if not preset_file_init then
  Init()
end


