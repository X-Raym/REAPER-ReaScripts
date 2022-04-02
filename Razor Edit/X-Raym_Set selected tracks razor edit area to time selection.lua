--[[
 * ReaScript Name: Set selected tracks razor edit area to time selection
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
]]


--[[
 * Changelog:
 * v1.0 (2022-04-02)
  + Initial Release
]]

function Msg( val )
  reaper.ShowConsoleMsg( tostring( val ) .. "\n" )
end

reaper.ClearConsole()

time_start, time_end = reaper.GetSet_LoopTimeRange( false, false, 0, 0, false )
if time_start == time_end then return false end

count_sel_tracks = reaper.CountSelectedTracks( 0 )
count_tracks = reaper.CountTracks( 0 )

reaper.PreventUIRefresh( 1 )

reaper.Undo_BeginBlock()

for i = 0, count_tracks - 1 do
  local track = reaper.GetTrack( 0, i )
  if count_sel_tracks == 0 or reaper.IsTrackSelected( track ) then
    local razor_str = time_start .. " " .. time_end .. ' ""'
    local retval, stringNeedBig = reaper.GetSetMediaTrackInfo_String( track, "P_RAZOREDITS", razor_str, true )
  end
end

reaper.Undo_BeginBlock( "Set selected tracks razor edit area to time selection", -1 )

reaper.UpdateArrange()

reaper.PreventUIRefresh( 1 )
