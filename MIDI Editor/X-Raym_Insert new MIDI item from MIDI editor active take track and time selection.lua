--[[
 * ReaScript Name: Insert new MIDI item from MIDI editor active take track and time selection
 * Screenshot: https://i.imgur.com/EtzVfGF.gif
 * Author: X-Raym
 * Author URI: http://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * v1.0 ( 2023-08-07 )
  + Initial Beta
--]]

-- USER CONFIG AREA ---------------------------------------

re_open_midi_editor = false

-------------------------------- END OF USER CONFIG AREA --

undo_text = "Insert new MIDI item from MIDI editor active take track and time selection"

take = reaper.MIDIEditor_GetTake( reaper.MIDIEditor_GetActive() )
if not take then return false end

item = reaper.GetMediaItemTake_Item( take )
track = reaper.GetMediaItemTrack( item )

time_start, time_end = reaper.GetSet_LoopTimeRange2( 0, false, false, 0, 0, false )
if time_start == time_end then return end

reaper.Undo_BeginBlock()

new_item = reaper.CreateNewMIDIItemInProj( track, time_start, time_end, nil )

reaper.SelectAllMediaItems( 0, false )
reaper.SetMediaItemSelected( new_item, true )

if re_open_midi_editor then
	reaper.Main_OnCommand(40153,0)--Item: Open in built-in MIDI editor (set default behavior in preferences)
end

reaper.Undo_EndBlock( undo_text, 0 )

reaper.UpdateTimeline()

reaper.UpdateArrange()
