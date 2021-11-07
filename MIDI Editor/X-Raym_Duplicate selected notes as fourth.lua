--[[
 * ReaScript Name: Duplicate selected notes as fourth
 * Description: See title
 * Instructions: Run
 * Author: X-Raym
 * Author URI: http://www.extremraym.com
 * Repository: X-Raym Premium Scripts
 * Licence: GPL v3
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
			StoreNote( k, sel, muted, startppq, endppq, chan, pitch, vel )
		end
	end

	InsertNotes( take, 5 )

end

function InsertNotes( take, offset )
	for i, note in pairs( notes ) do
		--Insert Note
		reaper.MIDI_InsertNote( take, note.sel, note.muted, note.startppq, note.endppq, note.chan, note.pitch + offset, note.vel, true )
	end

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
