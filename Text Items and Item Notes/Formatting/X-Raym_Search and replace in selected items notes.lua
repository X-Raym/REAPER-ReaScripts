--[[
 * ReaScript Name: Search and replace in selected items notes
 * About: Search and replace in selected items notes
 * Instructions: Select item with notes. Run.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts (LUA): Text Items Formatting Actions (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=156757
 * REAPER: 5.0 pre 32
 * Extensions: SWS/S&M 2.7.1
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2015-05-25)
  + Initial Release
--]]

 -- TO DO: MAke it Work with - chracter in search

function main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.


  -- LOOP THROUGH SELECTED ITEMS
  selected_items_count = reaper.CountSelectedMediaItems(0)

  -- INITIALIZE loop through selected items
  for i = 0, selected_items_count-1  do
    -- GET ITEMS
    item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i

    -- GET NOTES
    note = reaper.ULT_GetMediaItemNote(item)

    -- MODIFY NOTES
    note = note:gsub(search, replace)

    -- SET NOTES
    note = reaper.ULT_SetMediaItemNote(item, note)

  end -- ENDLOOP through selected items

  reaper.Undo_EndBlock("Search and replace in selected items notes", 0) -- End of the undo block. Leave it at the bottom of your main function.

end

-- START
defaultvals_csv = ","

retval, retvals_csv = reaper.GetUserInputs("Search & Replace", 2, "Search (% for escape char),Replace (/del for deletion)", defaultvals_csv)

if retval then -- if user complete the fields

  search, replace = retvals_csv:match("([^,]+),([^,]+)")

  if replace == "/del" then replace = "" end

  if search ~= nil then

    reaper.PreventUIRefresh(1)

    main() -- Execute your main function

    reaper.PreventUIRefresh(-1)

    reaper.UpdateArrange() -- Update the arrangement (often needed)
  end

end
