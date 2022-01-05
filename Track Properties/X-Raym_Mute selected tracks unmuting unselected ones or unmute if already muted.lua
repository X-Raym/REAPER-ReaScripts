--[[
 * ReaScript Name: Mute selected tracks unmuting unselected ones or unmute if already muted
 * Screenshot: https://i.imgur.com/I0EQB9U.gif
 * Author: X-Raym
 * Author URI: http://www.extremraym.com/
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: hhttps://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0.1
--]]


--[[
 * Changelog:
 * v1.0 (2021-02-14)
  + Initial Release
--]]

function Main()

  local all_mute = true
  for i = 0, count_sel_tracks - 1 do
    local track = reaper.GetSelectedTrack(0,i)
    local mute = reaper.GetMediaTrackInfo_Value(track, "B_MUTE" )
    if mute == 0 then
      all_mute = false
    end
  end

  if all_mute then
    reaper.MuteAllTracks(0)
  else
    local count_tracks = reaper.CountTracks(0)
    for i = 0, count_tracks - 1 do
      local track = reaper.GetTrack(0,i)
      local mute = reaper.GetMediaTrackInfo_Value(track, "B_MUTE")
      if reaper.IsTrackSelected(track) then
        reaper.SetMediaTrackInfo_Value(track, "B_MUTE", 1)
      else
        reaper.SetMediaTrackInfo_Value(track, "B_MUTE", 0)
      end
    end
  end -- Unmute all tracks

end

-- See if there is items selected
count_sel_tracks = reaper.CountSelectedTracks(0)

if count_sel_tracks > 0 then

  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  Main()

  reaper.Undo_EndBlock("Mute selected tracks unmuting unselected ones or unmute if already muted", -1) -- End of the undo block. Leave it at the bottom of your main function.

  reaper.TrackList_AdjustWindows(false)

  reaper.PreventUIRefresh(-1)

end
