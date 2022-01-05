--[[
 * ReaScript Name: Add all items right to selected items to items selection
 * Screenshot: https://i.imgur.com/vBqRybO.gif
 * Author: X-Raym
 * Author URI: https://extremraym.com
 * Repository: GitHub > X-Raym > REAPER ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2021-02-16)
  + Initial Release
--]]

-- Save item selection
function SaveSelectedItems (table)
  for i = 0, reaper.CountSelectedMediaItems(0)-1 do
    table[i+1] = reaper.GetSelectedMediaItem(0, i)
  end
end

function Main()

  local track_ids ={}
  for i, item in ipairs(init_sel_items) do
    local track = reaper.GetMediaItem_Track(item)
    local track_id = reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
    if not track_ids[track_id] then
      track_ids[track_id] = true
      local track_count_items = reaper.GetTrackNumMediaItems(track)
      local item_id =  reaper.GetMediaItemInfo_Value(item, "IP_ITEMNUMBER")
      for j = item_id, track_count_items - 1 do
        local track_item = reaper.GetTrackMediaItem(track, j )
        reaper.SetMediaItemSelected(track_item, 1)
      end
    end
  end

end

count_sel_items = reaper.CountSelectedMediaItems(0)

if count_sel_items > 0 then
  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock()

  init_sel_items =  {}
  SaveSelectedItems(init_sel_items)

  Main()

  reaper.UpdateArrange()

  reaper.Undo_EndBlock("Add all items right to selected items to items selection", 0)

  reaper.PreventUIRefresh(1)
end
