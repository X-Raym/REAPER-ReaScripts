--[[
 * ReaScript Name: Split selected MIDI notes half in 2 notes
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 6.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2024-03-06)
  + Initial Release
--]]

local reaper = reaper

function Process( take )
  local _,notes = reaper.MIDI_CountEvts(take)
  reaper.MIDI_DisableSort( take )
  for i = notes -1, 0, -1 do
    local _, sel, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote(take, i)
    if sel then
      local len = (endppqpos - startppqpos) / 2
      reaper.MIDI_SetNote(take, i, sel, muted, startppqpos, startppqpos + len, chan, pitch, val)
      reaper.MIDI_InsertNote( take, sel, muted, startppqpos + len, endppqpos, chan, pitch, vel, true )
    end
  end
  reaper.MIDI_Sort( take )
end

-- Main Function
function Main()

  active_midi_editor = reaper.MIDIEditor_GetActive()

  if active_midi_editor then
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

end

-- RUN
reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock()
Main()
reaper.Undo_EndBlock("Split selected MIDI notes half in 2 notes", -1)
reaper.UpdateArrange()
reaper.PreventUIRefresh(-1)
