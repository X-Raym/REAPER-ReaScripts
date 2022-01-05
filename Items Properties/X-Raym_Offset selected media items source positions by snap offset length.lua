--[[
 * ReaScript Name: Offset selected media items source positions by snap offset length
 * About: Use this with Xenakios/SWS: Switch item contents to next cue. Note: the cue shouldn't be visible.
 * Author: X-Raym
 * Author URI: https://extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2020-09-17)
  + Initial Release
--]]

function main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  -- LOOP THROUGH SELECTED ITEMS

  selected_items_count = reaper.CountSelectedMediaItems(0)

  -- INITIALIZE loop through selected items
  for i = 0, selected_items_count-1  do
    -- GET ITEMS
    local item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i


    local take = reaper.GetActiveTake( item )

    if take and not reaper.TakeIsMIDI( take ) then

      -- GET INFOS
      local item_snap = reaper.GetMediaItemInfo_Value(item, "D_SNAPOFFSET")

      local source_offset = reaper.GetMediaItemTakeInfo_Value(take, "D_STARTOFFS")

      -- SET SNAP OFFSET
      reaper.SetMediaItemTakeInfo_Value(take, "D_STARTOFFS", source_offset+item_snap)

    end

  end -- ENDLOOP through selected items

  reaper.Undo_EndBlock("Offset selected media items source positions by snap offset length", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

reaper.PreventUIRefresh(-1)  -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)
