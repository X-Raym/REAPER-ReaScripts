--[[
 * ReaScript Name: Insert named FX on selected tracks
 * About: Insert FX on selected tracks. FX name is can be edited within the script code.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

-- USER CONFIG AREA ------------------------------------------------------

-- Use Preset Script for safe moding or to create a new action with your own values
-- https://github.com/X-Raym/REAPER-ReaScripts/tree/master/Templates/Script%20Preset

-- Typical global variables names. This will be out global variables which could be altered in the preset file.
FX = "ReaEQ"

-------------------------------------------------- END OF USER CONFIG AREA

function Init()
  reaper.Undo_BeginBlock()

  TrackIdx = 0
  TrackCount = reaper.CountSelectedTracks(0)
  while TrackIdx < TrackCount do
    track = reaper.GetSelectedTrack(0, TrackIdx)
    fxIdx = reaper.TrackFX_AddByName( track, FX, false, -1 )
    -- fxIdx = reaper.TrackFX_GetByName (track, FX, true)
    isOpen = reaper.TrackFX_GetOpen(track, fxIdx)
    if isOpen ==0 then
      isOpen = 1
    else
      isOpen = 0
      end
    reaper.TrackFX_SetOpen(track, fxIdx, isOpen)
    TrackIdx =TrackIdx+1
  end

  reaper.Undo_EndBlock("Insert " .. ReaEQ .. "Plugin selected tracks",-1)
end

if preset_file_init then
  Init()
end