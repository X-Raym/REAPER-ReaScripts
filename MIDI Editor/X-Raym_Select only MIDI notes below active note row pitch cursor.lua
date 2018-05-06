--[[
 * ReaScript Name: Select only MIDI notes below active note row pitch cursor
 * Description: See title
 * Instructions: Run
 * Screenshot: https://i.imgur.com/pjjqMYN.gifv
 * Author: X-Raym
 * Author URI: http://www.extremraym.com
 * Repository: X-Raym Premium Scripts
 * Licence: GPL v3
 * Forum Thread: Scripts: MIDI (Various)
 * Forum Thread URI: https://forum.cockos.com/showthread.php?t=187555
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.0
--]]

--[[
 * v1.0 ( 2018-05-06 )
  + Initial Release
--]]

--// DEBUG //--
function Msg( value )
  if console then
    reaper.ShowConsoleMsg( tostring( value ) .. "\n" )
  end
end

function Main( take )

  editor = reaper.MIDIEditor_GetActive()
  active_note_row = reaper.MIDIEditor_GetSetting_int(editor,"active_note_row")

  start_time, end_time = reaper.GetSet_LoopTimeRange( false, false, 0, 0, false )
  if start_time ~= end_time then time_selection = true end
  if time_selection then
     start_time = reaper.MIDI_GetPPQPosFromProjTime( take, start_time )
      end_time = reaper.MIDI_GetPPQPosFromProjTime( take, end_time )
  end

  local retval, count_notes, count_ccs, count_sysex = reaper.MIDI_CountEvts( take )

  notes = {}

  for k = count_notes - 1, 0, - 1 do

    local retval, sel, muted, startppq, endppq, chan, pitch, vel = reaper.MIDI_GetNote( take, k )
    if pitch <= active_note_row then
      if time_selection then
        if ( startppq >= start_time and endppq <= end_time ) or ( startppq >= start_time and startppq <= end_time ) or ( endppq >= start_time and endppq <= end_time ) or (startppq <= start_time and endppq >= end_time) then
          sel = true
        else
          sel = false
        end
      else
        sel = true
      end
    else
      sel = false
    end
    reaper.MIDI_SetNote( take, k, sel, muted, startppq, endppq, chan, pitch, vel )
  end

  reaper.MIDI_Sort(take)

end

---------------------------------------------------------------------------------------------------
--// INIT //--
--if console then reaper.ClearConsole() end
active_midi_editor = reaper.MIDIEditor_GetActive()
take = reaper.MIDIEditor_GetTake( active_midi_editor)

if take then -- IF MIDI EDITOR
  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
  Main( take )
  reaper.Undo_EndBlock("Select only MIDI notes below active note row pitch cursor", 0) -- End of the undo block. Leave it at the bottom of your main function.
end
