--[[
 * ReaScript Name: Convert selected item notes to take name
 * About: Convert selected item notes to take name
 * Instructions: Select an item. Use it.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Version: 1.1
 * Version Date: 2015-03-25
 * REAPER: 5.0 pre 15
 * Extensions: SWS/S&M 2.6.0
--]]

--[[
 * Changelog:
 * v1.1 (2015-03-25)
  + bug fix (if empty item was selected)
 * v1.0 (2015-03-24)
  + Initial Release
--]]


-- From Heda's HeDa_SRT to text items.lua ====>
--[[dbug_flag = 0 -- set to 0 for no debugging messages, 1 to get them
function dbug (text)
  if dbug_flag==1 then
    if text then
      reaper.ShowConsoleMsg(text .. '\n')
    else
      reaper.ShowConsoleMsg("nil")
    end
  end
end]]
-- <==== From Heda's HeDa_SRT to text items.lua

function notes_to_names()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.


  -- LOOP THROUGH SELECTED ITEMS
  selected_items_count = reaper.CountSelectedMediaItems(0)

  -- INITIALIZE loop through selected items
  for i = 0, selected_items_count-1  do
    -- GET ITEMS
    item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i
    take = reaper.GetActiveTake(item)

    if take ~= nil then
      -- GET NOTES
      note = reaper.ULT_GetMediaItemNote(item)
      note = note:gsub("\n", " ")
      --reaper.ShowConsoleMsg(note)

      -- MODIFY TAKE
      retval, stringNeedBig = reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", note, 1)
    end

  end -- ENDLOOP through selected items

  reaper.Undo_EndBlock("Convert selected item notes to take name", 0) -- End of the undo block. Leave it at the bottom of your main function.

end



reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

notes_to_names() -- Execute your main function

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)

