--[[
 * ReaScript Name: Add italic markup to selected items notes
 * About: Add italic markup to selected items notes.
 * Instructions: Here is how to use it. (optional)
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts (LUA): Text Items Formatting Actions (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=156757
 * REAPER: 5.0 pre 15
 * Extensions: SWS/S&M 2.7.3 #0
 * Version: 1.2
--]]

--[[
 * Changelog:
 * v1.2 (2015-07-29)
  # Better Set Notes
 * v1.1 (2015-03-03)
  + Multiline support
  + Prevent duplicated tags
 * v1.0 (2015-03-03)
  + Initial Release
--]]


function italic()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.


  -- LOOP THROUGH SELECTED ITEMS
  selected_items_count = reaper.CountSelectedMediaItems(0)

  -- INITIALIZE loop through selected items
  for i = 0, selected_items_count-1  do
    -- GET ITEMS
    item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i

    -- GET NOTES
    note = reaper.ULT_GetMediaItemNote(item)

    x, y = string.find(note, "<i>")

    if x == nil then

      -- MODIFY NOTES
      note = "<i>" .. note .. "</i>"

      -- SET NOTES
      reaper.ULT_SetMediaItemNote(item, note)

    end


  end -- ENDLOOP through selected items

  reaper.Undo_EndBlock("Add italic markup to selected items notes", 0) -- End of the undo block. Leave it at the bottom of your main function.

end



reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

italic() -- Execute your main function

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)

