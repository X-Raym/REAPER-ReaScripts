--[[*
 * ReaScript Name: Select-Unselect all MIDI notes with same pitch left of the mouse
 * About: Assign the script to a keyboard shortcut, and load it into MIDI actions, from the MIDI editor Action window.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Script: Script (EEL): Select-Unselect all MIDI notes with same pitch right of the mouse
 * REAPER: 5.0
 * Extensions: SWS/S&M 2.6.3 #0
 * Version: 2.0
]]

--[[*
 * Changelog:
 * v2.0 (2024-11-05)
  # Lua version, deprecation of X-Raym_Select-Unselect all MIDI notes with same pitch left of the mouse.eel
  + Enum all editable takes
 * v1.0 (2015-04-06)
  + Initial release
 ]]

local reaper = reaper
local undo_text = "Select-Unselect all MIDI notes with same pitch left of the mouse"

if not reaper.BR_GetMouseCursorContext_MIDI then
  reaper.ShowMessageBox("SWS extension is required by this script.\nHowever, it doesn't seem to be present for this REAPER installation.\n\nDownload: http://www.sws-extension.org/", "Warning", 0)
  return false
end

-- Console Message
function Msg(g)
  reaper.ShowConsoleMsg(tostring(g).."\n")
end

function Main()
  local midi_editor = reaper.MIDIEditor_GetActive()
  if not midi_editor then return end

  local window, segment, details = reaper.BR_GetMouseCursorContext()
  local cursor_time = reaper.BR_GetMouseCursorContext_Position()
  local retval, inlineEditor, noteRow, ccLane, ccLaneVal, ccLaneId = reaper.BR_GetMouseCursorContext_MIDI()

  local select_all = false

  local takeindex = 0
  local take
  repeat
    take = reaper.MIDIEditor_EnumTakes( midi_editor, takeindex, 1)
    if take then
      local notes, ccs, sysex = reaper.MIDI_CountEvts(take)
      for noteidx = 0, notes -1 do
        local retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote( take, noteidx )
        if reaper.MIDI_GetProjTimeFromPPQPos( take, startppqpos ) <= cursor_time then
          if noteRow == pitch and not selected then -- IF NOTE IS AT PITCH OF MOUSE
            select_all = true
            break
          end
        else
          break
        end
      end
    end
    takeindex = takeindex + 1
  until not take or select_all

  takeindex = 0
  repeat
    take = reaper.MIDIEditor_EnumTakes( midi_editor, takeindex, 1)
    if take then
      local notes, ccs, sysex = reaper.MIDI_CountEvts(take)
      for noteidx = 0, notes -1 do
        local retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote( take, noteidx )
        if reaper.MIDI_GetProjTimeFromPPQPos( take, startppqpos ) <= cursor_time then
          if noteRow == pitch then -- IF NOTE IS AT PITCH OF MOUSE
            reaper.MIDI_SetNote(take, noteidx, select_all)
          end
        else
          break
        end
      end

    end

    takeindex = takeindex + 1
  until not take
end

reaper.PreventUIRefresh(1)
reaper.ClearConsole()
Main()
reaper.PreventUIRefresh(-1)
reaper.Undo_OnStateChange( undo_text )
