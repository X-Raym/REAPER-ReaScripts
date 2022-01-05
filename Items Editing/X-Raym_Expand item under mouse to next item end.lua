--[[
 * ReaScript Name: Expand item under mouse to next item end
 * About: A template script for REAPER ReaScript.
 * Instructions: Here is how to use it. (optional)
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Editing (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=163363
 * REAPER: 5.0 RC 10
 * Extensions: SWS/S&M 2.7.3
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2015-31-07)
  + Initial Release
--]]



function main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  item, position = reaper.BR_ItemAtMouseCursor()

  if item ~= nil then

    track = reaper.GetMediaItem_Track(item)

    item_id = reaper.GetMediaItemInfo_Value(item, "IP_ITEMNUMBER")

    next_item = reaper.GetTrackMediaItem(track, item_id + 1)

    if next_item ~= nil then

      item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
      item_length = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
      item_end = item_pos + item_length

      next_item_pos = reaper.GetMediaItemInfo_Value(next_item, "D_POSITION")
      next_item_length = reaper.GetMediaItemInfo_Value(next_item, "D_LENGTH")
      next_item_end = next_item_pos + next_item_length

      if next_item_end > item_end then

        reaper.BR_SetItemEdges(item, item_pos, next_item_end)

      end

      reaper.DeleteTrackMediaItem(track, next_item)

    end

    reaper.SetMediaItemSelected(item, true)

  end

  reaper.Undo_EndBlock("Expand item under mouse to next item end", -1) -- End of the undo block. Leave it at the bottom of your main function.

end


-- ITEMS
-- UNSELECT ALL ITEMS
function UnselectAllItems()
  for  i = 0, reaper.CountMediaItems(0) - 1 do
    reaper.SetMediaItemSelected(reaper.GetMediaItem(0, i), false)
  end
end

reaper.PreventUIRefresh(1)

UnselectAllItems()
main() -- Execute your main function

reaper.UpdateArrange() -- Update the arrangement (often needed)

reaper.PreventUIRefresh(-1)