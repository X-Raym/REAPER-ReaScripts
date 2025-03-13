--[[
 * ReaScript Name: Sort selected tracks order according to their first item positions
 * Screenshot: https://i.imgur.com/oeZNhFf.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0.2
--]]

--[[
 * Changelog:
 * v1.0.2 (2025-03-13)
  # Last track in folder fix. Thx Luca!
 * v1.0 (2020-01-06)
  + Initial Release
--]]

function SaveSelectedTracks( t )
  if not t then t = {} end
  local count_sel_tracks = reaper.CountSelectedTracks()
  for i = 0, count_sel_tracks - 1 do
    t[i+1] = reaper.GetSelectedTrack( 0, i )
  end
  return t
end

-- RESTORE INITIAL TRACKS SELECTION
local function RestoreSelectedTracks (table)
  reaper.Main_OnCommand(40297,0) -- Track: Unselect all tracks
  for _, track in ipairs(table) do
    reaper.SetTrackSelected(track, true)
  end
end

function Main()

  positions = {}
  for i, track in ipairs( sel_tracks ) do
    first_item = reaper.GetTrackMediaItem( track, 0 )
    track_id = reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
    if not first_item then
      positions[i] = {id = i, pos = 0, track = track, track_id = track_id }
    else
      positions[i] = {id = i, pos = reaper.GetMediaItemInfo_Value(first_item, "D_POSITION"), track = track, track_id =  track_id}
    end
  end


  table.sort(positions, function( a,b )
    if (a.pos < b.pos) then
      -- primary sort on position -> a before b
      return true
    elseif (a.pos > b.pos) then
      -- primary sort on position -> b before a
      return false
    else
      -- primary sort tied, resolve w secondary sort on rank
      return a.id < b.id
    end
  end)

  idx = {}
  for i, track in ipairs( sel_tracks ) do
    idx[i] = reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
  end

  for i = 1, #positions do
    reaper.SetOnlyTrackSelected( positions[i].track )
    reaper.ReorderSelectedTracks( idx[i], 2 )
  end

end

count_sel_tracks = reaper.CountSelectedTracks()

if count_sel_tracks > 1 then
  reaper.Undo_BeginBlock()
  reaper.PreventUIRefresh(1)
  sel_tracks = SaveSelectedTracks(sel_tracks)
  Main()
  RestoreSelectedTracks( sel_tracks )
  reaper.TrackList_AdjustWindows(false)
  reaper.UpdateArrange()
  reaper.PreventUIRefresh(-1)
  reaper.Undo_EndBlock("Sort selected tracks order according to their first item positions", -1)
end
