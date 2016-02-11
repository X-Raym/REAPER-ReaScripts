--[[
 * ReaScript Name: Trim MIDI note under mouse start to edit cursor and ripple edit
 * Description: 
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: 
 * Licence: GPL v3
 * Forum Thread: ReaScript: 
 * Forum Thread URI: 
 * REAPER: 5.0
 * Extensions: SWS 2.8.6 #0
 * Version: 1.0.1
]]
 
--[[
 * Changelog:
 * v1.0.1 (2016-02-11)
	+ SWS fix
 * v1.0 (2015-06-05)
	+ Initial Release
]]

--reaper.ShowConsoleMsg("")
function msg(variable)
	reaper.ShowConsoleMsg(tostring(variable).."\n")
end

function main() 
	take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive())
	if take ~= nil then
    
		window, segment, details = reaper.BR_GetMouseCursorContext()
		retval, inlineEditor, noteRow, ccLane, ccLaneVal, ccLaneId = reaper.BR_GetMouseCursorContext_MIDI()
		mouse_time = reaper.BR_GetMouseCursorContext_Position()
		cursor_time = reaper.GetCursorPosition()

		mouse_ppq_pos = reaper.MIDI_GetPPQPosFromProjTime(take, mouse_time)
		cursor_ppq_pos = reaper.MIDI_GetPPQPosFromProjTime(take, cursor_time)

		notes, ccs, sysex = reaper.MIDI_CountEvts(take)
	
		-- IS THERE NOTE UNDER MOUSE ?
		for i = 0, notes - 1 do
			retval, sel, muted, start_note, end_note, chan, pitch, vel = reaper.MIDI_GetNote(take, i)
			if start_note < mouse_ppq_pos and end_note > mouse_ppq_pos and noteRow == pitch then -- if yes then selected it
				reaper.MIDI_SetNote(take, i, 1, muted, start_note, end_note, chan, pitch, vel)
				mouse_note = i
				break
			end
		end
		
		-- IF NOTE UNDER MOUSE END IS BEFORE EDIT CURSOR
		if end_note > cursor_ppq_pos and mouse_note ~= nil then -- uf edit cursor is after mouse
		
			take_fng = reaper.FNG_AllocMidiTake(take)
			take_fng_count_notes = reaper.FNG_CountMidiNotes(take_fng)
			
			-- offset
			offset = math.floor(start_note - (cursor_ppq_pos + 0.5 ))
			--msg(end_note)
			--msg(mouse_ppq_pos)
			--msg(offset)
			
			for i = 0, take_fng_count_notes -1 do
			
				-- CONVERT
				note_fng = reaper.FNG_GetMidiNote(take_fng, i)
				
				-- GET
				note_fng_sel = reaper.FNG_GetMidiNoteIntProperty(note_fng, "SELECTED")
				--msg(note_fng_sel)
				if note_fng_sel == 1 then
					note_fng_len = reaper.FNG_GetMidiNoteIntProperty(note_fng, "LENGTH")
					--msg(note_fng_len)
					
					new_length = note_fng_len + offset
					-- SET
					if new_length > 0 then
						reaper.FNG_SetMidiNoteIntProperty(note_fng, "LENGTH", new_length)
					end
				end
				
				note_fng_pos = reaper.FNG_GetMidiNoteIntProperty(note_fng, "POSITION")
				
				if note_fng_pos <= start_note then
					reaper.FNG_SetMidiNoteIntProperty(note_fng, "POSITION", note_fng_pos - offset)
				
				end
			end		
			
			reaper.FNG_FreeMidiTake(take_fng)
			
			--[[ -- NEED A WAY TO BE CACHED
			-- CCs
			for i = 0, ccs - 1 do
				retval, sel, muted, start, chanmsg, chan, msg2, msg3 = reaper.MIDI_GetCC(take, i)
				if start <= start_note then 
				reaper.MIDI_SetCC(take, i, sel, muted, start - offset, chanmsg, chan, msg2, msg3)
				end
			end -- END OF CCs

			-- SYSEX
			for i = 0, sysex - 1 do
				retval, sel, muted, start, type_sysex, msg = reaper.MIDI_GetTextSysexEvt(take, i)
				if start <= start_note then
					reaper.MIDI_SetTextSysexEvt(take, i, sel, muted, start - offset, type_sysex, msg) 
				end
			end -- END OF SYSEX
			]]
			
		end -- END OF CURSOR AFTER NOTE UNDER MOUSE START
		

	end -- END OF MIDI TAKE
	
	reaper.Undo_OnStateChange("Trim MIDI note under mouse start to edit cursor and ripple edit")

end -- END OF FUNCTION

main()