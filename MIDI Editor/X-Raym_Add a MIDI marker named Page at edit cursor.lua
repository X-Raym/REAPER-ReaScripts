--[[
 * ReaScript Name: Duplicate selected notes as fifth and octave triad
 * Description: See title
 * Instructions: Run
 * Author: X-Raym
 * Author URI: http://www.extremraym.com
 * Repository: X-Raym Premium Scripts
 * Licence: GPL v3
 * Forum Thread:
 * Forum Thread URI:
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.0.1
--]]

--[[
 * v1.0 ( 2016-06-04 )
  + Initial Beta
--]]

--// DEBUG //--
function Msg( value )
  if console then
    reaper.ShowConsoleMsg( tostring( value ) .. "\n" )
  end
end

function Main( take )
  
  edit_cur = reaper.GetCursorPosition()
  
  edit_cur_ppq = reaper.MIDI_GetPPQPosFromProjTime( take, edit_cur )
  
  reaper.MIDI_InsertTextSysexEvt( take, true, false, edit_cur_ppq, 6, "Page" )
  
  reaper.MIDI_Sort( take )

end

---------------------------------------------------------------------------------------------------
--// INIT //--
--if console then reaper.ClearConsole() end
active_midi_editor = reaper.MIDIEditor_GetActive()
take = reaper.MIDIEditor_GetTake( active_midi_editor)

if take then -- IF MIDI EDITOR
  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
  Main( take )
  reaper.Undo_EndBlock("Advanced MIDI Humanization", 0) -- End of the undo block. Leave it at the bottom of your main function.
end
