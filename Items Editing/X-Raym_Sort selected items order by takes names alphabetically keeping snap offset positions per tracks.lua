--[[
 * ReaScript Name: Sort selected items order by takes names alphabetically keeping snap offset positions per tracks
 * About: Reorder items on your track based on item notes.
 * Instructions: Select items. Run.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0 pre 15
 * Extensions: SWS/S&M 2.7.1 (optional)
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2015-05-29)
  + Initial Release
--]]

 -- THANKS to heda for the multi-dimensional array syntax !


-- INIT
parent_tracks = {}
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

  --reaper.Main_OnCommand(40297, 0) -- Unselect all tracks
  UnselectAllTracks()

  -- LOOP THROUGH SELECTED ITEMS
  selected_items_count = reaper.CountSelectedMediaItems(0)

  -- INITIALIZE loop through selected items
  -- Select tracks with selected items
  for i = 0, selected_items_count - 1  do
    -- GET ITEMS
    item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i

    -- GET ITEM PARENT TRACK AND SELECT IT
    track = reaper.GetMediaItem_Track(item)
    reaper.SetTrackSelected(track, true)

  end -- ENDLOOP through selected items


  -- LOOP TRHOUGH SELECTED TRACKS
  selected_tracks_count = reaper.CountSelectedTracks(0)

  for i = 0, selected_tracks_count - 1  do
    -- GET THE TRACK
    track = reaper.GetSelectedTrack(0, i) -- Get selected track i

    count_items_on_track = reaper.CountTrackMediaItems(track)

    -- REINITILIAZE THE TABLE
    sel_items = {}
    pos = {}
    index = 1

    -- LOOP THROUGH ITEMS ON TRACKS AND STORE SELECTED ITEMS (for later moving) AND OFFSET
    for j = 0, count_items_on_track - 1  do

      item = reaper.GetTrackMediaItem(track, j)
      take = reaper.GetActiveTake(item)

      if reaper.IsMediaItemSelected(item) == true and take ~= nil then

        sel_items[index] = {}

        pos[index] = reaper.GetMediaItemInfo_Value(item, "D_SNAPOFFSET") + reaper.GetMediaItemInfo_Value(item, "D_POSITION")
        sel_items[index].item = item
        retval, str = reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", "", false)
        sel_items[index].note = str
        sel_items[index].pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")

        index = index + 1

      end

    end

    -- SORT TABLE
    -- thanks to https://forums.coronalabs.com/topic/37595-nested-sorting-on-multi-dimensional-array/
    table.sort(pos)
    table.sort(sel_items, function( a,b )
      if (a.note < b.note) then
        -- primary sort on position -> a before b
        return true
      elseif (a.note > b.note) then
        -- primary sort on position -> b before a
        return false
      else
        -- primary sort tied, resolve w secondary sort on rank
        return a.pos < b.pos
      end
    end)

    -- LOOP THROUGH SELECTED ITEMS ON TRACKS
    for k = 1, index - 1 do

      --item_note = sel_items[k].note
      --reaper.ShowConsoleMsg(item_note)
      item = sel_items[k].item
      item_snap = reaper.GetMediaItemInfo_Value(item, "D_SNAPOFFSET")

      reaper.SetMediaItemInfo_Value(item, "D_POSITION", pos[k] - item_snap)

    end

  end -- ENDLOOP through selected tracks

  reaper.Undo_EndBlock("Sort selected items order by takes names alphabetically keeping snap offset positions per tracks", -1) -- End of the undo block. Leave it at the bottom of your main function.

end


-- The following functions may be passed as global if needed
--[[ ----- INITIAL SAVE AND RESTORE ====> ]]

-- TRACKS
-- UNSELECT ALL TRACKS
function UnselectAllTracks()
  first_track = reaper.GetTrack(0, 0)
  reaper.SetOnlyTrackSelected(first_track)
  reaper.SetTrackSelected(first_track, false)
end

-- SAVE INITIAL TRACKS SELECTION
init_sel_tracks = {}
local function SaveSelectedTracks (table)
  for i = 0, reaper.CountSelectedTracks(0)-1 do
    table[i+1] = reaper.GetSelectedTrack(0, i)
  end
end

-- RESTORE INITIAL TRACKS SELECTION
local function RestoreSelectedTracks (table)
  UnselectAllTracks()
  for _, track in ipairs(table) do
    reaper.SetTrackSelected(track, true)
  end
end

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

SaveSelectedTracks(init_sel_tracks)

main() -- Execute your main function

RestoreSelectedTracks(init_sel_tracks)

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)


