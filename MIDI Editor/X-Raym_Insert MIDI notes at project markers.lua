--[[
 * ReaScript Name: Insert MIDI notes at project markers
 * Description: See title.
 * Instructions: Open a MIDI take in MIDI Editor. Run.
 * Screenshot: http://i.giphy.com/xTcnSXojAqCRl0dD8Y.gif
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script Request Sticky? - Page 32
 * Forum Thread URI: http://forum.cockos.com/showpost.php?p=1617117&postcount=1265
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2016-01-14)
	+ Initial Release
--]]

-- USER CONFIG AREA ---------------------

prompt = false -- User input dialog box
selected = false -- new notes are selected

length = 1 -- in seconds

chanmsg = 1
chan = 1
pitch = 36
vel = 88

----------------- END OF USER CONFIG AREA


-- Console Message
function Msg(g)
  reaper.ShowConsoleMsg(tostring(g).."\n")
end


function main() -- local (i, j, item, take, track)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive())

  if take ~= nil then
  
	i=0
	repeat
		iRetval, bIsrgnOut, iPosOut, iRgnendOut, sNameOut, iMarkrgnindexnumberOut, iColorOut = reaper.EnumProjectMarkers3(0, i)
		
		if iRetval >= 1 then
			if bIsrgnOut == false then
				
				next_iRetval, next_bIsrgnOut, next_iPosOut, next_iRgnendOut, next_sNameOut, next_iMarkrgnindexnumberOut, next_iColorOut = reaper.EnumProjectMarkers3(0, i+1)
				
				if next_iRetval >= 1 and next_bIsrgnOut == false then
					if next_iPosOut - iPosOut < length then
						end_time = next_iPosOut
					else
						end_time = iPosOut + length
					end
				else
					end_time = iPosOut + length
				end
				
				iPosOut = reaper.MIDI_GetPPQPosFromProjTime(take, iPosOut)
				end_time = reaper.MIDI_GetPPQPosFromProjTime(take, end_time)
				
				--reaper.MIDI_InsertNote(take, selected, muted, startppqpos, endppqpos, chan, pitch, vel, NoSortInOptional)
				retval = reaper.MIDI_InsertNote(take, selected, false, iPosOut, end_time, chan, pitch, vel, true)
			
			end
			i = i+1
		end
	until iRetval == 0
	
	reaper.MIDI_Sort(take)
	
  end -- ENFIF Take is MIDI

  reaper.Undo_EndBlock("Insert MIDI notes at project markers", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

if prompt == true then
  retval, pitch = reaper.GetUserInputs("Insert Notes at Regions", 1, "Notes Row (0-127):", pitch)
end

if retval or prompt == false then -- if user complete the fields

  pitch = tonumber(pitch)

  if pitch ~= nil then

    pitch = math.floor(pitch)
	if pitch < 0 then pitch = 0 end
	if pitch > 127 then pitch = 127 end

    main() -- Execute your main function

    reaper.UpdateArrange() -- Update the arrangement (often needed)

  end

end
