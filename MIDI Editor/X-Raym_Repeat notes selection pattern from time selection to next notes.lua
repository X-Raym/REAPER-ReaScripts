--[[
 * ReaScript Name: Repeat notes selection pattern from time selection to next notes
 * About: Select notes inside a time selection. Run. The script will count every notes after time selection and select/unselect based on the notes in time selection selection value state. The script just cout notes, it doesn't do any complex grid/channel check.
 * Screenshot: https://i.imgur.com/BOKDErc.gifv
 * Author: X-Raym
 * Author URI: http://www.extremraym.com
 * Repository: X-Raym Premium Scripts
 * Licence: GPL v3
 * Forum Thread: Scripts: MIDI (Various)
 * Forum Thread URI: https://forum.cockos.com/showthread.php?t=187555
 * REAPER: 5.0
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2018-05-11)
  + Initial Release
--]]

local reaper = reaper

function Main( take )
      
  retval, notes, ccs, sysex = reaper.MIDI_CountEvts( take )
  
  local time_startppq = reaper.MIDI_GetPPQPosFromProjTime( take, start_time )
  local time_endppq = reaper.MIDI_GetPPQPosFromProjTime( take, end_time )
  
  pattern = {}
  local j = 0
  -- GET SELECTED NOTES (from 0 index)
  for k = 0, notes - 1 do
        
    local retval, sel, muted, startppq, endppq, chan, pitch, vel = reaper.MIDI_GetNote( take, k )

    
      if startppq >= time_startppq and startppq < time_endppq and endppq > time_startppq and endppq <= time_endppq then
        local offset = k
        if pattern[1] then offset = pattern[1] end
        table.insert( pattern, sel )
      else
        -- ACTION HERE
        reaper.MIDI_SetNote( take, k, false, muted, startppq, endppq, chan, pitch, vel )
        if startppq >= time_startppq then
          j = j % #pattern
          j = j + 1
         reaper.MIDI_SetNote( take, k, pattern[j], muted, startppq, endppq, chan, pitch, vel )
        end
        
      end

  end

end

-------------------------------
-- INIT
-------------------------------

take = reaper.MIDIEditor_GetTake( reaper.MIDIEditor_GetActive() )
start_time, end_time =  reaper.GetSet_LoopTimeRange( false, false, 0, 0, false )

if take and start_time ~= end_time then
  
  reaper.ClearConsole()
  
  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
  
  Main( take ) -- Execute your main function
  
  reaper.Undo_EndBlock("Repeat notes selection pattern from time selection to next notes", 0) -- End of the undo block. Leave it at the bottom of your main function.
  
  reaper.UpdateArrange() -- Update the arrangement (often needed)

end -- ENDIF Take is MIDI
