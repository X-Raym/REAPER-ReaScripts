--[[
 * ReaScript Name: Move selected notes to pitch under mouse
 * Screenshot: https://i.imgur.com/zrwgpl1.gif
 * Author: X-Raym
 * Author URI: http://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * v1.0 (2021-05-04)
  + Initial Release
--]]

console = true

if not reaper.BR_GetMouseCursorContext_MIDI then
  reaper.ShowMessageBox("SWS extension is required by this script.\nHowever, it doesn't seem to be present for this REAPER installation.\n\nDownload: http://www.sws-extension.org/", "Warning", 0)
  return false
end

--// DEBUG //--
function Msg( value )
  if console then
    reaper.ShowConsoleMsg( tostring( value ) .. "\n" )
  end
end

function StoreNote( k, sel, muted, startppq, endppq, chan, pitch, vel )
  notes[k] = {}
  notes[k].sel = sel
  notes[k].muted = muted
  notes[k].startppq = startppq
  notes[k].endppq = endppq
  notes[k].chan = chan
  notes[k].pitch = pitch
  notes[k].vel = vel
  notes[k].ccs = {}
end

function Main( take )

  local retval, count_notes, count_ccs, count_sysex = reaper.MIDI_CountEvts( take )

  notes = {}

  for k = count_notes - 1, 0, - 1 do
    local retval, sel, muted, startppq, endppq, chan, pitch, vel = reaper.MIDI_GetNote( take, k )
    if sel then
      pitch = noteRow
    end
    StoreNote( k, sel, muted, startppq, endppq, chan, pitch, vel )
    reaper.MIDI_DeleteNote(take, k )
  end

  InsertNotes( take )

end

function InsertNotes( take, offset )
  for i, note in pairs( notes ) do
    --Insert Note
    reaper.MIDI_InsertNote( take, note.sel, note.muted, note.startppq, note.endppq, note.chan, note.pitch, note.vel, true )
  end

  reaper.MIDI_Sort( take )
end

---------------------------------------------------------------------------------------------------
--// INIT //--
--if console then reaper.ClearConsole() end
active_midi_editor = reaper.MIDIEditor_GetActive()
take = reaper.MIDIEditor_GetTake( active_midi_editor)

if take then -- IF MIDI EDITOR
  reaper.ClearConsole()
  window, segment, details = reaper.BR_GetMouseCursorContext()
  retval, inlineEditor, noteRow, ccLane, ccLaneVal, ccLaneId = reaper.BR_GetMouseCursorContext_MIDI()
  if retval and noteRow >= 0 then
    reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
    Main( take )
    reaper.Undo_EndBlock("Move selected notes to pitch under mouse", 0) -- End of the undo block. Leave it at the bottom of your main function.
  end
end
