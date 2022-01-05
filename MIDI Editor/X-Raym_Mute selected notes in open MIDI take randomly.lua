--[[
 * ReaScript Name: Mute selected notes in open MIDI take randomly
 * Instructions: Open a MIDI take in MIDI Editor. Select Notes. Run.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0 pre 15
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2015-06-12)
  + Initial Release
--]]

-- USER AREA -----------
-- strength_percent = 0.5
-- END OF USER AREA ----

-- INIT
note_sel = 0
init_notes = {}
t = {}

-- SHUFFLE TABLE FUNCTION
-- from Tutorial: How to Shuffle Table Items by Rob Miracle
-- https://coronalabs.com/blog/2014/09/30/tutorial-how-to-shuffle-table-items/
math.randomseed( os.time() )

local function ShuffleTable( t )
  local rand = math.random

  local iterations = #t
  local w

  for z = iterations, 2, -1 do
    w = rand(z)
    t[z], t[w] = t[w], t[z]
  end
end


function main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive())

  if take ~= nil then

      retval, notes, ccs, sysex = reaper.MIDI_CountEvts(take)

      -- GET SELECTED NOTES (from 0 index)
      for k = 0, notes-1 do

        retval, sel, muted, startppqposOut, endppqposOut, chan, pitch, vel = reaper.MIDI_GetNote(take, k)

        if sel == true then

          note_sel = note_sel + 1
          init_notes[note_sel] = k

        end

      end


      defaultvals_csv = note_sel
    retval, retvals_csv = reaper.GetUserInputs("Mute Selected Notes Randomly", 1, "Number of Notes to Mute?", defaultvals_csv)

    if retval then -- if user complete the fields

      notes_selection = tonumber(retvals_csv)

      -- SHUFFLE TABLE
      ShuffleTable( init_notes )

      -- MUTE RANDOMLY
      -- if percentage is needed
      --notes_selection = math.floor(notes * strength_percent)

      for j = 1, note_sel do

        if j <= notes_selection then

            retval, sel, muted, startppqposOut, endppqposOut, chan, pitch, vel = reaper.MIDI_GetNote(take, init_notes[j])
            reaper.MIDI_SetNote(take, init_notes[j], true, true, startppqposOut, endppqposOut, chan, pitch, vel)

          else
          -- this allow to execute the action several times. Else, all notes end to be muted.

            retval, sel, muted, startppqposOut, endppqposOut, chan, pitch, vel = reaper.MIDI_GetNote(take, init_notes[j])
            reaper.MIDI_SetNote(take, init_notes[j], false, false, startppqposOut, endppqposOut, chan, pitch, vel)

          end

      end

    end

  end -- ENFIF Take is MIDI

  reaper.Undo_EndBlock("Mute selected note in open MIDI take randomly", 0) -- End of the undo block. Leave it at the bottom of your main function.

end

main() -- Execute your main function

reaper.UpdateArrange() -- Update the arrangement (often needed)