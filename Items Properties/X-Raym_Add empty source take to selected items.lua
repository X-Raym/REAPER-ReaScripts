--[[
 * ReaScript Name: Add empty source take to selected items
 * About: Useful to put take markers on an empty items without using MIDI items
 * Author: X-Raym
 * Author URI: https://extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0 pre 36
 * Version: 1.0.1
--]]

--[[
 * Changelog:
 * v1.0.1 (2023-01-24)
  # Better undo
 * v1.0 (2020-04-29)
  + Initial Release
--]]

function main()

  -- LOOP THROUGH SELECTED ITEMS

  selected_items_count = reaper.CountSelectedMediaItems(0)

  -- INITIALIZE loop through selected items
  for i = 0, selected_items_count-1  do

    -- GET ITEMS
    item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i

    reaper.AddTakeToMediaItem(item)

  end -- ENDLOOP through selected items

  reaper.Undo_OnStateChange("Add empty source take to selected items")

end

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

reaper.UpdateArrange() -- Update the arrangement (often needed)

reaper.PreventUIRefresh(-1)  -- Restore UI Refresh. Uncomment it only if the script works.
