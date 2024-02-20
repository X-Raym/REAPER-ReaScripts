--[[
 * ReaScript Name: Add new MIDI take to selected items
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0.1
--]]

--[[
 * Changelog:
 * v1.0.1 (2024-02-20)
  # Bug fix
 * v1.0 (2023-07-24)
  + Initial Release
--]]

undo_text = "Add new MIDI take to selected items"

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

function Main()

  -- INITIALIZE loop through selected items
  for i, item in ipairs( init_sel_items ) do

    reaper.SelectAllMediaItems( 0, false )
    reaper.SetMediaItemSelected( item, true )

    -- Chunk require dealing with end value in tick. Let's do another approach.
    -- retval, item_chunk = reaper.GetItemStateChunk( item, "", false )
    -- item_chunk = item_chunk:gsub("<SOURCE EMPTY\n>\n>",  "<SOURCE MIDI\nHASDATA 1\nE 5760 b0 7b 00\n>\n>" )
    -- reaper.ShowConsoleMsg( item_chunk )

    local track = reaper.GetMediaItemTrack( item )
    local item_pos = reaper.GetMediaItemInfo_Value( item, "D_POSITION" )
    local item_len = reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )
    local offset = 1 -- be sure tat it will be implode as last take
    local midi_item = reaper.CreateNewMIDIItemInProj( track, item_pos + offset, item_pos + offset + item_len, qnIn )

    local name = ""
    local take = reaper.GetActiveTake( item )
    if take then
      name = reaper.GetTakeName( take )
    else
      retval, name = reaper.GetSetMediaItemInfo_String( item, "P_NOTES", "", false )
    end

    local midi_take = reaper.GetActiveTake( midi_item )
    reaper.GetSetMediaItemTakeInfo_String( midi_take, "P_NAME", name, true )

    reaper.SetMediaItemSelected( item, true )
    reaper.SetMediaItemSelected( midi_item, true )

    reaper.Main_OnCommand( 40543, 0 ) -- Take: Implode items on same track into takes

    local item = reaper.GetSelectedMediaItem( 0, 0 )
    init_sel_items[i] = item

    reaper.SetActiveTake( reaper.GetTake( item, ( reaper.CountTakes( item ) - 1 ) ) )

    -- reaper.SetItemStateChunk( item, item_chunk, false )

  end -- ENDLOOP through selected items

end

-- INIT
function Init()

  reaper.ClearConsole()

  -- See if there is items selected
  count_sel_items = reaper.CountSelectedMediaItems(0)
  if count_sel_items == 0 then return false end

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
