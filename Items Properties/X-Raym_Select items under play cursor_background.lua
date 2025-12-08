--[[
 * ReaScript Name: Select items under play cursor (background)
 * Screenshot: https://i.imgur.com/CGtMQC5.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Items selection (Various)
 * Forum Thread URI: https://forum.cockos.com/showthread.php?t=163321
 * REAPER: 5.0
 * Version: 1.0.4
--]]

--[[
 * Changelog:
 * v1.0.3 (2025-12-09)
  + Works only on selected tracks
  # Delay get play position at play start by one frame to avoid GetPlayPosition to return value before GetCursorPosition
  # Strict "IsInTime" end
 * v1.0.2 (2024-11-09)
  # Button state
  # Less refresh
 * v1.0.1 (2024-11-09)
  # Script header
--]]

only_sel_tracks = true
frame = 0

-- Set ToolBar Button State
function SetButtonState( set )
  local is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  reaper.SetToggleCommandState( sec, cmd, set or 0 )
  reaper.RefreshToolbar2( sec, cmd )
end

----------------------------------

function IsInTime( s, start_time, end_time )
  if s >= start_time and s < end_time then return true end
  return false
end

function GetPlayOrEditCursorPos2()
  local play_state = reaper.GetPlayState()
  if play_state == 1 or play_state == 5 then
    frame = (frame < 2 and frame + 1) or frame
  else
    frame = 0
  end
  if (play_state == 1 or play_state == 5) and frame == 2 then
    return reaper.GetPlayPosition()
  else
    return reaper.GetCursorPosition()
  end
end

function Msg( value )

    reaper.ShowConsoleMsg( tostring( value ) .. "\n" )

end

 -------------------------------------------------------
 function Main()
   local curpos = GetPlayOrEditCursorPos2()
   local need_refresh = false
   local count_tracks = only_sel_tracks and reaper.CountSelectedTracks(0) or reaper.CountTracks(0)
   for i_tr = 1, count_tracks do
     local tr = only_sel_tracks and reaper.GetSelectedTrack(0,i_tr-1) or reaper.GetTrack(0,i_tr-1)
     
     for i_it = 1, reaper.CountTrackMediaItems(tr) do
       local item = reaper.GetTrackMediaItem( tr, i_it-1 )
       local it_pos = reaper.GetMediaItemInfo_Value( item, 'D_POSITION' )
       local it_len = reaper.GetMediaItemInfo_Value( item, 'D_LENGTH' )
       if IsInTime( curpos, it_pos, it_pos + it_len ) then
          if reaper.IsMediaItemSelected( item ) == false then
            need_refresh = true
            reaper.SetMediaItemSelected( item, true )
          end
        elseif reaper.IsMediaItemSelected( item ) then
          need_refresh = true
          reaper.SetMediaItemSelected( item, false )
        end
     end
   end
   if need_refresh then
     reaper.UpdateArrange()
   end
   reaper.defer(Main)
 end

-- RUN
SetButtonState( 1 )
Main()
reaper.atexit( SetButtonState )

