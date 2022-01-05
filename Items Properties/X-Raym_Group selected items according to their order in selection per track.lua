--[[
 * ReaScript Name: Group selected items according to their order in selection per track
 * About: Select item. Run. It will group and colorize item based on their position in selection per track (first selected items on selected track together, second together etc...)
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
 * v2.0 (2021-04-13)
  # new core
 * v1.0 (2015-05-26)
    + Initial Release
--]]

-- USER CONFIG AREA ---------------------------------------
colorize = true
undo_text = "Group selected items according to their order in selection per track"
-----------------------------------------------------------

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

  -- Group items
  for i, column in ipairs( columns ) do
    reaper.SelectAllMediaItems(0, false)
    for j, item in ipairs( column.items ) do
      reaper.SetMediaItemSelected(item, true )
      if colorize then
        reaper.Main_OnCommand(40706, 0) -- set items to one random color
      end
      reaper.Main_OnCommand(40032, 0) -- Item grouping; Group items
    end
  end

  -- Reselect
  for i, column in ipairs( columns ) do
    for j, item in ipairs( column.items ) do
     reaper.SetMediaItemSelected(item, true )
    end
  end

end

-- INIT -----------------------------------------------------

function Init()
  count_sel_items = reaper.CountSelectedMediaItems(0)

  if count_sel_items > 1 then

    reaper.PreventUIRefresh(1)

    reaper.Undo_BeginBlock()

    Main()

    reaper.Undo_EndBlock(undo_text, -1)

    reaper.PreventUIRefresh(-1)

    reaper.UpdateArrange()

  end
end

if not preset_file_init then
  Init()
end
