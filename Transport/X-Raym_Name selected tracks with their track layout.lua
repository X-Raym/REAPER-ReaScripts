 --[[
 * ReaScript Name: Name selected tracks with their track layout
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
 * v1.0 (2021-05-31)
  # Initial release
--]]

reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock()
count_sel_tracks = reaper.CountSelectedTracks(0)
for i = 0, count_sel_tracks - 1 do
  track = reaper.GetSelectedTrack(0,i)
  retval, layout = reaper.GetSetMediaTrackInfo_String( track, "P_TCP_LAYOUT", "", false )
  name = layout .. " - " .. reaper.GetMediaTrackInfo_Value(track, "I_PANMODE")
  retval, str = reaper.GetSetMediaTrackInfo_String( track, "P_NAME", name, true )
end
reaper.Undo_EndBlock("Name selected tracks with their track layout", -1)
reaper.PreventUIRefresh(-1)