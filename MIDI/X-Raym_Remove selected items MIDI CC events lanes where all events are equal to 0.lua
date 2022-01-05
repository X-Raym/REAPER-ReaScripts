--[[
 * ReaScript Name: Remove selected items MIDI CC events lanes where all events are equal to 0
 * Screenshot: https://i.imgur.com/sallb63.gif
 * Author: X-Raym
 * Author URI: http://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2021-12-26)
  + Initial Release
--]]

-- DEBUG -----------------------------------

-- Display Messages in the Console
function Msg(value)
  if console then
    reaper.ShowConsoleMsg(tostring(value).."\n")
  end
end

-------------------------------------- DEBUG


-- MIDI ------------------------------------

-- MAIN
function Main(item, take)

  -- LOOP IN MIDI NOTES
  retval, notes, ccs, sysex = reaper.MIDI_CountEvts(take)

  cc_t = {}

  -- Filter CC
  for i = 0, ccs-1 do -- Loop in notes

    local retval, selected, muted, ppqpos, chanmsg, chan, num, val = reaper.MIDI_GetCC( take, i )
    if not cc_t[num] then cc_t[num] = 0 end
    if val > 0 then cc_t[num] = cc_t[num] + 1 end

  end

  -- Get CC ID to delete
  cc_to_delete = {}
  for i = ccs-1, 0, -1 do -- Loop in notes
    local retval, selected, muted, ppqpos, chanmsg, chan, num, val = reaper.MIDI_GetCC( take, i )
    if cc_t[num] == 0 then
      reaper.MIDI_DeleteCC( take, i )
    end
  end

  reaper.MIDI_Sort( take )

end -- Main()


-------------
function SaveSelectedItems(table)
  for i = 0, reaper.CountSelectedMediaItems(0)-1 do
    table[i+1] = reaper.GetSelectedMediaItem(0, i)
  end
end

-- INIT
count_sel_items = reaper.CountSelectedMediaItems(0)

if count_sel_items > 0 then

  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  -- Save items selection
  sel_items = {}
  SaveSelectedItems(sel_items)

  for i, item in ipairs(sel_items) do
    take = reaper.GetActiveTake(item)
    if reaper.TakeIsMIDI(take) then
      Main(item, take) -- Execute your main function
    end
  end

  reaper.Undo_EndBlock("Remove selected items MIDI CC events lanes where all events are equal to 0", -1) -- End of the undo block. Leave it at the bottom of your main function.

  reaper.UpdateArrange() -- Update the arrangement (often needed)

  reaper.PreventUIRefresh(-1)

end -- if count sel items

