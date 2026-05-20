--[[
 * ReaScript Name: Solo in place exclusive track under mouse and play
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.2.1
--]]

--[[
 * Changelog:
 * v1.2.1 (2026-05-20)
  # Use GetTrackFromPoint for pinned track support
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
  solo_state = 2
  if reaper.GetTrackFromPoint then
    mouse_x, mouse_y = reaper.GetMousePosition()
    track, info = reaper.GetTrackFromPoint( mouse_x, mouse_y )
    pos = reaper.BR_PositionAtMouseCursor( false )
  else
    track, context, pos = reaper.BR_TrackAtMouseCursor()
  end

  if track then
    local solo = reaper.GetMediaTrackInfo_Value(track, "I_SOLO")
    if solo ~= solo_state then
      reaper.SetMediaTrackInfo_Value(track, "I_SOLO", solo_state)
      reaper.SetOnlyTrackSelected( track )
      --if reaper.AnyTrackSolo( 0 ) then
        local count_track = reaper.CountTracks(0)
        for i = 0, count_track - 1 do
          local tr = reaper.GetTrack(0,i)
          if tr ~= track and reaper.GetMediaTrackInfo_Value(tr, "I_SOLO") ~=0 then
            reaper.SetMediaTrackInfo_Value(tr, "I_SOLO", 0)
          end
        end
      --end
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
