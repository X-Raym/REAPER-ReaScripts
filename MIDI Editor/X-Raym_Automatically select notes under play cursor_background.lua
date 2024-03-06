--[[
 * ReaScript Name: Automatically select notes under play cursor (background)
 * Screeshot: https://i.imgur.com/DISBpSe.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 6.0
 * Version: 1.0.1
--]]

--[[
 * Changelog:
 * v1.0 (2023-08-30)
  + Initial Release
--]]

local reaper = reaper

-- Set ToolBar Button State
function SetButtonState( set )
  local is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  reaper.SetToggleCommandState( sec, cmd, set or 0 )
  reaper.RefreshToolbar2( sec, cmd )
end

function Process( take )
  local _,notes = reaper.MIDI_CountEvts(take)
  local mouse_ppq_pos = reaper.MIDI_GetPPQPosFromProjTime(take, time)
  for i = 0, notes - 1 do
    local _, sel, muted, start_note, end_note, chan, pitch, vel = reaper.MIDI_GetNote(take, i)
    if mouse_ppq_pos >= start_note and mouse_ppq_pos < end_note then
      sel = true
    else
      sel = false
    end
    reaper.MIDI_SetNote(take, i, sel, nil, nil, nil, nil, nil, nil)
  end
end

-- Main Function (which loop in background)
function Main()

  active_midi_editor = reaper.MIDIEditor_GetActive()
  time = reaper.GetPlayState() > 0 and reaper.GetPlayPosition() or reaper.GetCursorPosition()

  if active_midi_editor and  reaper.GetPlayState() > 0 then
    local i = 0
    local take
    repeat
      take = reaper.MIDIEditor_EnumTakes( active_midi_editor, i, true )
      if take then
        Process( take )
      end
      i = i + 1
    until not take
  end

  reaper.defer( Main )

end

-- RUN
SetButtonState( 1 )
Main()
reaper.atexit( SetButtonState )
