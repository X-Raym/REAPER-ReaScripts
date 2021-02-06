--[[
 * ReaScript Name: Toggle selected tracks solo (no undo)
 * Author: X-Raym
 * Author URI: http://www.extremraym.com/
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]
 

--[[
 * Changelog:
 * v1.0 (2021-02-06)
  + Initial Release
--]]

reaper.PreventUIRefresh(1)
count_sel_tracks = reaper.CountSelectedTracks(0)

for i = 0, count_sel_tracks - 1 do
  local track = reaper.GetSelectedTrack(0,i)
  local solo = reaper.GetMediaTrackInfo_Value(track, "I_SOLO")
  if solo == 0 then solo = 1 else solo = 0 end
  reaper.SetMediaTrackInfo_Value(track, "I_SOLO",solo)
end

reaper.TrackList_AdjustWindows(false)
reaper.UpdateArrange()
reaper.PreventUIRefresh(-1)
