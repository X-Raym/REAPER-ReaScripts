--[[
 * ReaScript Name: Quantize selected items start and end to closest frame inside them
 * About: Quantize to frame grid. Nice for video items.
 * Instructions: You may consider selecting your items and using SWS/FNG Clean selected overlapping items on same track after that
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5 pre 28
 * Extensions: SWS/S&M 2.7.1
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2015-05-28)
  + Initial Release
--]]


function RoundToX(number, interval)
  round = math.ceil(number/interval) * interval

  --msg_f(interval)
  --msg_f(number)
  --msg_f(round)

  return round
end

function main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  frameRate, dropFrameOut = reaper.TimeMap_curFrameRate(0)

  frame_duration = 1/frameRate

  -- LOOP THROUGH SELECTED ITEMS
  selected_items_count = reaper.CountSelectedMediaItems(0)

  -- INITIALIZE loop through selected items
  for i = 0, selected_items_count-1  do

    -- GET ITEMS
    item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i

    -- GET INFOS
    item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    item_end = item_pos + item_len

    -- MODIFY INFOS
    new_item_pos = RoundToX(item_pos, frame_duration)
    new_item_end = RoundToX(item_end, frame_duration)

    if new_item_pos < item_pos then new_item_pos = new_item_pos + frame_duration end
    if new_item_end > item_end then new_item_end = new_item_end - frame_duration end

    -- SET INFOS
    reaper.BR_SetItemEdges(item, new_item_pos, new_item_end) -- Set the value to the parameter

  end -- ENDLOOP through selected items

  reaper.Undo_EndBlock("Quantize selected items start and end to closest frame inside them", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

reaper.PreventUIRefresh(-1)

reaper.UpdateArrange() -- Update the arrangement (often needed)