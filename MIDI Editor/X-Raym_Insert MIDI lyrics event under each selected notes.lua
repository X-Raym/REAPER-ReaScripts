--[[
 * ReaScript Name: Insert MIDI lyrics event under each selected notes
 * Description: See title.
 * Instructions: Open a MIDI take in MIDI Editor. Select Notes. Run.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script: Script name
 * Forum Thread URI: http://forum.cockos.com/***.html
 * REAPER: 5.0
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2018-24-12)
  + Initial Release
--]]

-- Split CSV string
function string:split(sep)
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  self:gsub(pattern, function(c) fields[#fields+1] = c end)
  return fields
end

var = reaper.GetSetProjectNotes( 0, false, '' )
var = var:gsub('[ |%-|\n]', '|%1')

sep = "|"
test = var:split(sep)

for i, j in ipairs(test) do
  print(j)
end

-- INIT
note_sel = 0
events = {}

function main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive())

  if take then
      
      local retval, notes, ccs, sysex = reaper.MIDI_CountEvts(take)

      -- GET SELECTED NOTES (from 0 index)
      for k = 0, notes-1 do
            
        local retval, sel, muted, startppqposOut, endppqposOut, chan, pitch, vel = reaper.MIDI_GetNote(take, k)

        if sel then

          table.insert(events, startppqposOut)
          
        end
          
      end
      
      str = '' -- "1.1.2\tLyric\t2.1.1\tLyric"
      for i, ppqpos in ipairs( events ) do
        pos = reaper.MIDI_GetProjTimeFromPPQPos( take, ppqpos )
        lyric = "bla"
        if test[i] then lyric = test[i] end
        str = str .. reaper.format_timestr_pos( pos, '', 1 ) .. '\t' .. lyric ..'\t'
      end
      str = str:sub(1, -2)
      
      reaper.SetTrackMIDILyrics( reaper.GetSelectedTrack(0,0), 2, str )
      
      
      reaper.MIDI_Sort( take )

  end -- ENFIF Take is MIDI  
  
  --retval, str = reaper.GetTrackMIDILyrics(  reaper.GetSelectedTrack(0,0), 2, "" )
  -- reaper.ShowConsoleMsg( str )

  reaper.Undo_EndBlock("Insert MIDI lyrics event under each selected notes", 0) -- End of the undo block. Leave it at the bottom of your main function.

end

main() -- Execute your main function

reaper.UpdateArrange() -- Update the arrangement (often needed)


