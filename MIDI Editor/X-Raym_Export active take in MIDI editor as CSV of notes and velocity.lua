--[[
 * ReaScript Name: Export active take in MIDI editor as CSV of notes and velocity
 * Description: Designed for my MIDI CSV as notes sequence JSFX.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Links:
    Forum Thread http://forum.cockos.com/showthread.php?t=181105
 * Licence: GPL v3
 * REAPER: 5.0
 * Extensions: None
 * Version: 2.0
--]]

--[[
 * Changelog:
 * v2.0 (2017-09-26)
  # Change CSV separator from . to , This is not compatible with v1 workflow
  + Added channel infos
  + Prevent muted notes to be exported
 * v1.0.1 (2017-09-26)
  # Fix MacOS folder creation issue
 * v1.0 (2016-09-19)
  + Initial Release
--]]

local reaper = reaper
notes_array = {}

function Main( take )

  retval, notes, ccs, sysex = reaper.MIDI_CountEvts( take )

  -- GET SELECTED NOTES (from 0 index)
  for k = 0, notes - 1 do

    local retval, sel, muted, startppq, endppq, chan, pitch, vel = reaper.MIDI_GetNote( take, k )

  	if not muted then
        notes_array[k+1] = {}
        notes_array[k+1].pitch = pitch
        notes_array[k+1].vel = vel
        notes_array[k+1].chan = chan
    end

  end

end


function export()
  -- OS BASED SEPARATOR
  if reaper.GetOS() == "Win32" or reaper.GetOS() == "Win64" then
    slash = "\\"
  else
    slash = "/"
  end

  resource = reaper.GetResourcePath()

  file_name = reaper.GetTakeName( take )
  dir_name = resource .. slash .. "Data" .. slash .. "MIDI Sequences"

  reaper.RecursiveCreateDirectory(dir_name, 0)

  file = dir_name .. slash .. file_name .. ".txt"

  -- CREATE THE FILE
  f = io.open(file, "w")
  io.output(f)
  --Msg(file)

  for i, note in ipairs(notes_array) do
    f:write( tostring( note.pitch .. "," .. note.vel .. "," .. note.chan ) )
    if i == #notes_array then break end
    f:write("\n")
  end

  f:close() -- never forget to close the file

  Msg("File exported: " .. file)

end

function Msg(g)
  reaper.ShowConsoleMsg(tostring(g).."\n")
end



-------------------------------
-- INIT
-------------------------------
midi_editor = reaper.MIDIEditor_GetActive()
if not midi_editor then return end

take = reaper.MIDIEditor_GetTake( midi_editor )

if take then

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  Main( take ) -- Execute your main function
  export()

  reaper.Undo_EndBlock("Export active take in MIDI editor as CSV of notes and velocity", 0) -- End of the undo block. Leave it at the bottom of your main function.

  reaper.UpdateArrange() -- Update the arrangement (often needed)

end -- ENDIF Take is MIDI
