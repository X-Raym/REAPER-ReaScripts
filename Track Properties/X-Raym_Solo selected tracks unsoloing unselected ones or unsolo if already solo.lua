--[[
 * ReaScript Name: Solo selected tracks unsoloing unselected ones or unsolo if already solo
 * Screenshot: https://i.imgur.com/I0EQB9U.gif
 * Author: X-Raym
 * Author URI: http://www.extremraym.com/
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0.2
--]]


--[[
 * Changelog:
 * v1.0.2 (2021-30-09)
  + Performance
 * v1.0 (2021-02-14)
  + Initial Release
--]]

local reaper = reaper

function Main()

  local all_solo = true
  for i = 0, count_sel_tracks - 1 do
    local track = reaper.GetSelectedTrack(0,i)
    local solo = reaper.GetMediaTrackInfo_Value(track, "I_SOLO" )
    if solo == 0 then
      all_solo = false
      break
    end
  end

  if all_solo then
    reaper.SoloAllTracks(0)
  else
    local count_tracks = reaper.CountTracks(0)
    for i = 0, count_tracks - 1 do
      local track = reaper.GetTrack(0,i)
      if not reaper.IsTrackSelected(track) and reaper.GetMediaTrackInfo_Value(track, "I_SOLO") ~= 0 then
        reaper.SetMediaTrackInfo_Value(track, "I_SOLO", 0)
      end
    end
    reaper.Main_OnCommand( 40728, 0 ) -- Track: Solo tracks
  end -- Unsolo all tracks

end

-- See if there is items selected
count_sel_tracks = reaper.CountSelectedTracks(0)

if count_sel_tracks > 0 then

  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  Main()

  reaper.Undo_EndBlock("Solo selected tracks unsoloing unselected ones or unsolo if already solo", -1) -- End of the undo block. Leave it at the bottom of your main function.

  reaper.TrackList_AdjustWindows(false)

  reaper.PreventUIRefresh(-1)

end
