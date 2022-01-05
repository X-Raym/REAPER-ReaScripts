--[[
 * ReaScript Name: Insert FX
 * About: Insert FX on selected tracks. FX name is can be edited witing the script code.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread:
 * Forum Thread URI:
 * REAPER: 5.0
 * Version: 1.0
--]]

reaper.Undo_BeginBlock()

FX = "Massive"

TrackIdx = 0
TrackCount = reaper.CountSelectedTracks(0)
while TrackIdx < TrackCount do
  track = reaper.GetSelectedTrack(0, TrackIdx)
  fxIdx = reaper.TrackFX_GetByName (track, FX, 1)
  isOpen = reaper.TrackFX_GetOpen(track, fxIdx)
  if isOpen ==0 then
    isOpen = 1
  else
    isOpen = 0
    end
  reaper.TrackFX_SetOpen(track, fxIdx, isOpen)
  TrackIdx =TrackIdx+1
end

reaper.Undo_EndBlock("Insert FX Plugin",-1)
