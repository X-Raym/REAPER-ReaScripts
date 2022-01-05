--[[
 * ReaScript Name: Create empty items on selected tracks from selected midi takes notes
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Properties (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=166689
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2021-09-06)
  + Initial Release
--]]


-- USER CONFIG AREA -----------------------------------------------------------

console = true -- true/false: display debug messages in the console

undo_text = "Create empty items on selected tracks from selected midi takes notes"
------------------------------------------------------- END OF USER CONFIG AREA


-- UTILITIES -------------------------------------------------------------

-- Save item selection
function SaveSelectedItems(t)
  local t = t or {}
  for i = 0, reaper.CountSelectedMediaItems(0)-1 do
    t[i+1] = reaper.GetSelectedMediaItem(0, i)
  end
  return t
end

function RestoreSelectedItems( items )
  reaper.SelectAllMediaItems(0, false)
  for i, item in ipairs( items ) do
    reaper.SetMediaItemSelected( item, true )
  end
end


-- Display a message in the console for debugging
function Msg(value)
  if console then
    reaper.ShowConsoleMsg(tostring(value) .. "\n")
  end
end

--------------------------------------------------------- END OF UTILITIES

-- Create a Text Item.
-- Return the item if success. Else, return nil.
function CreateTextItem(track, position, length, text, color)

  local item = reaper.AddMediaItemToTrack(track)

  reaper.SetMediaItemInfo_Value(item, "D_POSITION", position)
  reaper.SetMediaItemInfo_Value(item, "D_LENGTH", length)

  if text then
    reaper.ULT_SetMediaItemNote(item, text)
  end

  if color then
    reaper.SetMediaItemInfo_Value(item, "I_CUSTOMCOLOR", color)
  end

  return item

end

-- Main function
function Main()

  for i, item in ipairs(init_sel_items) do
    local take = reaper.GetActiveTake( item )

    if take and reaper.TakeIsMIDI( take ) then
      -- LOOP IN MIDI NOTES
      local retval, notes, ccs, sysex = reaper.MIDI_CountEvts(take)

      -- GET SELECTED NOTES (from 0 index)
      for k = 0, notes-1 do -- Loop in notes

        local _, sel, mute, startppq, endppq, chan, pitch, vel = reaper.MIDI_GetNote(take, k)

        local start_time =  reaper.MIDI_GetProjTimeFromPPQPos( take, startppq )
        local end_time =  reaper.MIDI_GetProjTimeFromPPQPos( take, endppq )

        for j = 0, count_sel_tracks - 1 do
          local track = reaper.GetSelectedTrack(0,j)
          CreateTextItem(track, start_time, end_time-start_time)
        end

      end
    end
  end

end


-- INIT
function Init()
  -- See if there is items selected
  count_sel_items = reaper.CountSelectedMediaItems(0)
  if count_sel_items == 0 then return false end

  count_sel_tracks = reaper.CountSelectedTracks(0)
  if count_sel_tracks == 0 then return false end

  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock()

  init_sel_items = SaveSelectedItems()

  Main()

  RestoreSelectedItems(init_sel_items)

  reaper.Undo_EndBlock(undo_text, -1)

  reaper.UpdateArrange()

  reaper.PreventUIRefresh(-1)

end

if not preset_file_init then
  Init()
end
