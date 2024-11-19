--[[
 * ReaScript Name: Snap edit cursor to closest MIDI editor grid line
 * Screenshot: https://i.imgur.com/EBjhma4.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: MIDI (Various)
 * Forum Thread URI: https://forum.cockos.com/showthread.php?t=187555
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * v1.0 (2024-11-13)
  + Initial Release
--]]

midi_editor = reaper.MIDIEditor_GetActive()
if not midi_editor then return end

function Main()
  midi_editor_section = 32060
  snap = reaper.GetToggleCommandStateEx( midi_editor_section, 1014 )
  if snap == 0 then
    reaper.MIDIEditor_OnCommand(midi_editor, 1014)
  end
  
  cur_pos = reaper.GetCursorPosition()
  
  reaper.MIDIEditor_OnCommand(midi_editor, 40048)
  rigth_cur_pos = reaper.GetCursorPosition()
  
  reaper.MIDIEditor_OnCommand(midi_editor, 40047)
  left_cur_pos = reaper.GetCursorPosition()
  
  if left_cur_pos == cur_pos then
    reaper.SetEditCurPos( cur_pos, false, false )
  elseif rigth_cur_pos - cur_pos < cur_pos - left_cur_pos then
    --reaper.SetEditCurPos( rigth_cur_pos, false, false )
    reaper.MIDIEditor_OnCommand(midi_editor, 40048) -- TRICK: this way we prevent one frame visual cursor jump
  else
    reaper.SetEditCurPos( left_cur_pos, false, false )
  end
  
  if snap == 0 then
    reaper.MIDIEditor_OnCommand(midi_editor, 1014)
  end
end

reaper.PreventUIRefresh(1)
Main()
reaper.PreventUIRefresh(-1)
