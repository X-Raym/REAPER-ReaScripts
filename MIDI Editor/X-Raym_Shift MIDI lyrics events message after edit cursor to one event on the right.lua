--[[
 * ReaScript Name: Insert sysex events at time selection
 * Screenshot: https://i.imgur.com/bzhSa2O.gif
 * Author: X-Raym
 * Author URI: https://extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0.1
--]]

--[[
 * Changelog:
 * v1.0 (2023-02-12)
  + Initial Release
--]]

midi_editor = reaper.MIDIEditor_GetActive()
if not midi_editor then return end

take = reaper.MIDIEditor_GetTake( midi_editor )
if not take then return end

retval, notes, cc, evts = reaper.MIDI_CountEvts( take )
if evts == 0 then return end

edit_cursor = reaper.GetCursorPosition()
edit_cur_pos_ppq = reaper.MIDI_GetPPQPosFromProjTime( take, edit_cursor )

texts = {}
for i = 0, evts - 1 do
  local retval, selected, muted, ppqpos, type, msg = reaper.MIDI_GetTextSysexEvt( take, i )
  texts[i] = msg
end

reaper.Undo_BeginBlock()
for i = 0, evts - 1 do
  local retval, selected, muted, ppqpos, type, msg = reaper.MIDI_GetTextSysexEvt( take, i )
  if ppqpos >= edit_cur_pos_ppq then
    reaper.MIDI_SetTextSysexEvt( take, i, selected, mute, ppqpos, type, (not has_done and "_") or texts[i-1], false )
    has_done = true
  end
end
reaper.Undo_EndBlock("Shift MIDI lyrics events message after edit cursor to one event on the left", -1)
