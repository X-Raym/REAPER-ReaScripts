--[[
 * ReaScript Name: Shuffle order of selected items columns keeping snap offset positions and parent tracks
 * About: This works nicely only if there is as many items selected on each track, as it works on item selected ID on track and not "visual" columns
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Script (Lua): Shuffle Items
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=159961
 * REAPER: 5.0
 * Version: 2.0
--]]

--[[
 * Changelog:
 * v2.0 (2021-01-07)
  + new core
  # remove group support
 * v1.1 (2016-01-07)
  + Preserve grouping if groups active. Treat first selected item (in position) in each group as group leader (other are ignored during the alignement).
 * v1.0 (2015-06-09)
  + Initial Release
--]]

-------------------------------------------------------------

function Msg(variable)
  reaper.ShowConsoleMsg(tostring(variable).."\n")
end

-------------------------------------------------------------

-- SHUFFLE TABLE FUNCTION
-- https://gist.github.com/Uradamus/10323382
function shuffle(t)
  local tbl = {}
  for i = 1, #t do
    tbl[i] = t[i]
  end
  for i = #tbl, 2, -1 do
    local j = math.random(i)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
  if do_tables_match( t, tbl ) then -- MOD: be sure tables are different
    --tbl = shuffle(t)
  end
  return tbl
end

function do_tables_match( a, b )
  return table.concat(a) == table.concat(b)
end


-------------------------------------------------------------
function Main()

  -- Get Columns of Selected Items
  columns = {} -- Original minimum positions and list of items for each columns
  positions = {} -- Minimum positions of items snap for each columns
  local column = 0

  for i = 0, count_sel_items - 1 do

    local item = reaper.GetSelectedMediaItem(0,i)
    local track = reaper.GetMediaItemTrack( item )
    local track_id = reaper.GetMediaTrackInfo_Value( track, "IP_TRACKNUMBER")

    if track_id ~= last_track_id then column = 0 end -- reset column counter
    column = column + 1 -- increment column

    local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    local item_snap = reaper.GetMediaItemInfo_Value(item, "D_SNAPOFFSET")
    local item_possnap = item_pos + item_snap

    if not columns[column] then
      columns[column] = {min_possnap = item_possnap, items = {} }
    else
      columns[column].min_possnap = math.min( columns[column].min_possnap, item_possnap )
    end
    positions[column] = columns[column].min_possnap
    table.insert(columns[column].items, item)

    last_track_id = track_id

  end

  if #columns > 1 then --  No need if there is only one column
    positions = shuffle( positions )

    for i, column in ipairs( columns ) do
      offset = positions[i] - column.min_possnap
      for j, item in ipairs( column.items ) do
        local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
        reaper.SetMediaItemInfo_Value(item, "D_POSITION", item_pos + offset)
      end
    end

  end

end

-- INIT -----------------------------------------------------

count_sel_items = reaper.CountSelectedMediaItems(0)

if count_sel_items > 1 then

  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock()

  Main()

  reaper.Undo_EndBlock("Shuffle order of selected items columns keeping snap offset positions and parent tracks", -1)

  reaper.PreventUIRefresh(-1)

  reaper.UpdateArrange()

end
