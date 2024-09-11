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
 * Version: 1.0.2
--]]

--[[
 * Changelog:
 * v1.0.2 (2024-11-09)
  # Button state
  # Less refresh
 * v1.0.1 (2024-11-09)
  # Script header
--]]

-- Set ToolBar Button State
function SetButtonState( set )
  local is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  reaper.SetToggleCommandState( sec, cmd, set or 0 )
  reaper.RefreshToolbar2( sec, cmd )
end

for key in pairs(reaper) do _G[key]=reaper[key]  end 
----------------------------------

function IsInTime( s, start_time, end_time )
  if s >= start_time and s <= end_time then return true end
  return false
end

function GetPlayOrEditCursorPos()
  local play_state = reaper.GetPlayState()
  if play_state == 1 or play_state == 5 then
    return reaper.GetPlayPosition()
  else
    return reaper.GetCursorPosition()
  end
end

 -------------------------------------------------------
 function Main()
   local curpos = GetPlayOrEditCursorPos()
   local need_refresh = false
   for i_tr = 1, CountTracks(0) do
     local tr = GetTrack(0,i_tr-1) 
     
     for i_it = 1,  CountTrackMediaItems(tr) do
       local item = GetTrackMediaItem( tr, i_it-1 )
       local it_pos = GetMediaItemInfo_Value( item, 'D_POSITION' )
       local it_len = GetMediaItemInfo_Value( item, 'D_LENGTH' )        
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
     UpdateArrange()
   end
   defer(Main)
 end

-- RUN
SetButtonState( 1 )
Main()
reaper.atexit( SetButtonState )

