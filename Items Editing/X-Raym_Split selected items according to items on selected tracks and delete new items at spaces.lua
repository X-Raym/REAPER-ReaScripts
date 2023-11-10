--[[
 * ReaScript Name: Split selected items according to items on selected tracks and delete new items at spaces
 * About: A script to do multi mic based editing using one single track.
 * Screenshot: https://i.imgur.com/xmPVYZi.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Editing (various)
 * Forum Thread URI: https://forum.cockos.com/showthread.php?t=163363
 * REAPER: 5.0
 * Version: 2.0
--]]

--[[
 * Changelog:
 * v2.0 (2023-11-10)
  # Renamed
  # Refactor
  # Bug fixes
  + Multitracks as source support
 * v1.0.1 (2020-07-06)
  # Actually delete items at spaces
 * v1.0 (2020-07-06)
  + Initial Release
 * v0.9 (2019-10-18)
  # based on X-Raym_Split selected items according to items on first selected track and keep new items at spaces.lua
--]]

-----------------------------------------------------------
-- USER CONFIG AREA --
-----------------------------------------------------------

console = true
delete_at_silence = true
undo_text = "Split selected items according to items on selected tracks and delete new items at spaces"

-----------------------------------------------------------
                              -- END OF USER CONFIG AREA --
-----------------------------------------------------------

-----------------------------------------------------------
-- DEBUG --
-----------------------------------------------------------

-- Display a message in the console for debugging
function Msg(value)
  if console then
    reaper.ShowConsoleMsg(tostring(value) .. "\n")
  end
end

-----------------------------------------------------------
                                         -- END OF DEBUG --
-----------------------------------------------------------

-----------------------------------------------------------
-- MATHS --
-----------------------------------------------------------

function IsInTimeStictEnd( s, start_time, end_time )
  if s >= start_time and s < end_time then return true end
  return false
end

function FloatConverstion( num )
  return tonumber( tostring( num ) )
end

-----------------------------------------------------------
                                         -- END OF MATHS --
-----------------------------------------------------------

-----------------------------------------------------------
-- ITEMS --
-----------------------------------------------------------

-- With Tracks and GUID
function SaveSelectedItems( t )
  t = t or {}
  for i = 0, count_sel_items - 1 do
    local entry = {}
    entry.item = reaper.GetSelectedMediaItem(0,i)
    entry.pos_start = reaper.GetMediaItemInfo_Value(entry.item, "D_POSITION")
    entry.pos_end = entry.pos_start + reaper.GetMediaItemInfo_Value(entry.item, "D_LENGTH")
    entry.track = reaper.GetMediaItemTrack( entry.item )
    entry.track_id = reaper.GetMediaTrackInfo_Value( entry.track, "IP_TRACKNUMBER"  )
    retval, entry.GUI = reaper.GetSetMediaItemInfo_String( entry.item, "GUID", "", false )
    table.insert(t, entry)
  end
  return t
end

function GetTrackOverlappingAndAdjacentItemsAndSplits() -- Exclude select items (see commented lines)
  
  -- Globals
  all_track_items = {}
  split_pos_unique = {}
  split_pos = {}
  
  for i = 0, count_sel_tracks - 1 do
    local track = reaper.GetSelectedTrack( 0, i )
    local count_track_items = reaper.CountTrackMediaItems( track )
    for j = 0, count_track_items - 1 do
      local item = reaper.GetTrackMediaItem( track, j )
      --if not reaper.IsMediaItemSelected( item ) then -- Ignore Selected Items
        local pos_start = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
        local pos_end = pos_start + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
        split_pos_unique[pos_start] = true
        split_pos_unique[pos_end] = true
        table.insert(all_track_items, {item = item, pos_start = pos_start, pos_end = pos_end})
      --end
    end
  end
  
  for k, v in pairs( split_pos_unique ) do
    table.insert( split_pos, k )
  end
  table.sort( split_pos )

  table.sort(all_track_items, function( a,b )
    if (a.pos_start < b.pos_start) then
      -- primary sort on position -> a before b
      return true
    elseif (a.pos_start > b.pos_start) then
      -- primary sort on position -> b before a
      return false
    else
      -- primary sort tied, resolve w secondary sort on rank
      return a.pos_end < b.pos_end
    end
  end)

  regions ={}
  local entry
  local reset = true

  for i, current in ipairs( all_track_items ) do

    if entry and FloatConverstion( current.pos_start ) > entry.pos_end then -- Note: would be >= for overlapping non adjacent
      reset = true
      table.insert( regions, entry )
    else
      if entry and FloatConverstion(current.pos_end) > entry.pos_end then
        entry.pos_end = current.pos_end
      end
    end

    if reset then
      entry = {}
      entry.pos_start = current.pos_start
      entry.pos_end = current.pos_end
      reset = false
    end

    if not entry.items then entry.items = {} end
    table.insert(entry.items, current.item )

  end

  table.insert( regions, entry ) -- Insert the last entry

end

-----------------------------------------------------------
                                         -- END OF ITEMS --
-----------------------------------------------------------

-----------------------------------------------------------
-- SPLIT --
-----------------------------------------------------------

function SplitItems()
  for i, entry in ipairs(init_sel_items) do
    local item = entry.item
    for j, pos in ipairs(split_pos) do
      if pos < entry.pos_end and pos > entry.pos_start then
        local item_new = reaper.SplitMediaItem(item, pos)
        if item_new then item = item_new end
      end
      if pos > entry.pos_end then break end
    end
  end
end

function DeleteAtSpaces()
  local count_sel_items = reaper.CountSelectedMediaItems()
  for i = count_sel_items - 1, 0, -1 do
    local item = reaper.GetSelectedMediaItem( 0, i )
    local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    local delete = delete_at_silence
    for z, region in ipairs( regions ) do
      if IsInTimeStictEnd( item_pos, region.pos_start, region.pos_end ) then
        delete = not delete_at_silence
        break
      end
    end
    if delete then
      reaper.DeleteTrackMediaItem( reaper.GetMediaItemTrack( item ), item )
    end
  end
end

-----------------------------------------------------------
                                         -- END OF SPLIT --
-----------------------------------------------------------

-----------------------------------------------------------
-- MAIN --
-----------------------------------------------------------

function Main()

  GetTrackOverlappingAndAdjacentItemsAndSplits()
  
  SplitItems()

  DeleteAtSpaces()
  
end

-----------------------------------------------------------
                                          -- END OF MAIN --
-----------------------------------------------------------

-----------------------------------------------------------
-- INIT --
-----------------------------------------------------------

function Init()
  count_sel_tracks = reaper.CountSelectedTracks(0)
  if count_sel_tracks == 0 then return end
  
  count_sel_items = reaper.CountSelectedMediaItems(0)
  if count_sel_items == 0 then return end
  
  reaper.Undo_BeginBlock() -- Begining of the undo block.
  
  reaper.PreventUIRefresh(1)-- Prevent UI refreshing. Uncomment it only if the script works.
  
  init_sel_items = SaveSelectedItems()
  
  Main() -- Run
  
  reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.
  
  reaper.UpdateArrange() -- Update the arrangement (often needed)
  
  reaper.Undo_EndBlock(undo_text, -1) -- End of the undo block.
end

if not preset_file_init then
  Init()
end
