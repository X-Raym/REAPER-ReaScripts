--[[
 * ReaScript Name: Select reference tracks
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2024-03-13)
  + Initial release
--]]

undo_text = "Select reference tracks"
select_exclusive = true

function Main()
  for i = 0, count_all_tracks - 1 do
    local track = reaper.GetTrack(0, i)
    local retval, state = reaper.GetSetMediaTrackInfo_String( track, "P_EXT:XR_REF", "", false )
    if select_exclusive and state ~= "REF" then
      reaper.SetTrackSelected( track, false )
    end
    if state == "REF" then
      reaper.SetTrackSelected( track, true )
    end
  end
end

function Init()
  count_all_tracks = reaper.CountTracks( 0 )
  if count_all_tracks == 0 then return end
  
  reaper.PreventUIRefresh( 1 )
  
  reaper.Undo_BeginBlock()
  
  Main()
  
  reaper.TrackList_AdjustWindows( false )
  
  reaper.Undo_EndBlock( undo_text, 0 )
  
  reaper.PreventUIRefresh( - 1 )
end

if not preset_file_init then
  Init()
end

