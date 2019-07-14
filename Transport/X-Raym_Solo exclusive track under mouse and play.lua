--[[
 * ReaScript Name: Solo exclusive track under mouse and play
 * Author: X-Raym
 * Author URI: https://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.2
--]]
 
--[[
 * Changelog:
 * v1.2 (2019-07-14)
  + Snap to grid
  # no SWS dependency
 * v1.1 (2019-06-26)
  # Only check any track solo if needed
 * v1.0 (2019-06-26)
  + Initial Release
--]]

function Main()
  reaper.PreventUIRefresh(1)
  local solo_state = 1
  local track, context, pos = reaper.BR_TrackAtMouseCursor()
  if track then
    local solo = reaper.GetMediaTrackInfo_Value(track, "I_SOLO")
    if solo ~= solo_state then
      --reaper.PreventUIRefresh(1)
      reaper.SetMediaTrackInfo_Value(track, "I_SOLO", solo_state)
      reaper.SetOnlyTrackSelected( track )
      --if reaper.AnyTrackSolo() then
        local count_track = reaper.CountTracks(0)
        for i = 0, count_track - 1 do
          local tr = reaper.GetTrack(0,i)
          if tr ~= track and reaper.GetMediaTrackInfo_Value(tr, "I_SOLO") ~=0 then
            reaper.SetMediaTrackInfo_Value(tr, "I_SOLO", 0)
          end
        end
      --end
      --reaper.PreventUIRefresh(-1)
    end
    --reaper.Main_OnCommand(reaper.NamedCommandLookup("_BR_PLAY_MOUSECURSOR"),0) -- SWS/BR: Play from mouse cursor position
    if reaper.GetToggleCommandState( 1157 ) then
      pos = reaper.SnapToGrid( 0, pos )
    end
    local pos_init = reaper.GetCursorPosition()
    reaper.SetEditCurPos( pos, false, false )
    reaper.OnPlayButton()
    reaper.SetEditCurPos( pos_init, false, false )
    reaper.PreventUIRefresh(-1)
  end
end

reaper.defer(Main)
