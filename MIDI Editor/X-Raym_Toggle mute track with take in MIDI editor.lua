--[[
 * ReaScript Name: Toggle mute track with take in MIDI editor
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2022-04-18)
  + Initial Release
--]]

take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive())
if not take then return end

track = reaper.GetMediaItemTake_Track(take)

reaper.Undo_BeginBlock()

track_mute = reaper.GetMediaTrackInfo_Value(track, 'B_MUTE')
track_mute = track_mute == 1 and 0 or 1
reaper.SetMediaTrackInfo_Value(track, 'B_MUTE', track_mute)

reaper.Undo_EndBlock('Toggle mute track with take in MIDI editor', -1)
