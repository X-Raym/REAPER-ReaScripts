--[[
 * ReaScript Name: Move selected items snap offset to previous cue
 * About: A way to move edit snap offset of selected items to file cue point / marker (bwf, bext)...
 * Instructions: Select item. Run. No change will occur if there is no "next cue point"
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0 pre 15
 * Extensions: SWS/S&M 2.7.1
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2015-06-09)
  + Initial Release
--]]


function main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.


  -- INITIALIZE loop through selected items
  for i = 1, #init_sel_items do

    UnselectAllItems()
    -- GET ITEMS
    item = init_sel_items[i] -- Get selected item i

    reaper.SetMediaItemSelected(item, true)

    -- GET INFOS
    item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    item_snap = reaper.GetMediaItemInfo_Value(item, "D_SNAPOFFSET") -- Get the value of a the parameter
    old_snap = item_pos+item_snap

    reaper.SetEditCurPos2(0, old_snap, false, false)

    reaper.Main_OnCommand(40742, 0) -- move edit cursor to previous cue in items

    cursor_pos = reaper.GetCursorPositionEx(0)

    -- SET INFOS
    new_snap = cursor_pos-item_pos
    if cursor_pos ~= old_snap then
      reaper.SetMediaItemInfo_Value(item, "D_SNAPOFFSET", cursor_pos-item_pos)
    else
      reaper.SetMediaItemInfo_Value(item, "D_SNAPOFFSET", 0) -- Set the
    end

  end -- ENDLOOP through selected items
  --


  reaper.Undo_EndBlock("Move selected items snap offset to previous cue", -1) -- End of the undo block. Leave it at the bottom of your main function.

end


--[[ ----- INITIAL SAVE AND RESTORE ====> ]]

-- ITEMS
-- UNSELECT ALL ITEMS
function UnselectAllItems()
  for  i = 0, reaper.CountMediaItems(0)-1 do
    reaper.SetMediaItemSelected(reaper.GetMediaItem(0, i), false)
  end
end

-- SAVE INITIAL SELECTED ITEMS
init_sel_items = {}
local function SaveSelectedItems (table)
  for i = 1, reaper.CountSelectedMediaItems(0) do
    table[i] = reaper.GetSelectedMediaItem(0, i-1)
  end
end

-- RESTORE INITIAL SELECTED ITEMS
local function RestoreSelectedItems (table)
  UnselectAllItems() -- Unselect all items
  for _, item in ipairs(table) do
    reaper.SetMediaItemSelected(item, true)
  end
end

-- CURSOR
-- SAVE INITIAL CURSOR POS
function SaveCursorPos()
  init_cursor_pos = reaper.GetCursorPosition()
end

-- RESTORE INITIAL CURSOR POS
function RestoreCursorPos()
  reaper.SetEditCurPos(init_cursor_pos, false, false)
end

-- VIEW
-- SAVE INITIAL VIEW
function SaveView()
  start_time_view, end_time_view = reaper.BR_GetArrangeView(0)
end


-- RESTORE INITIAL VIEW
function RestoreView()
  reaper.BR_SetArrangeView(0, start_time_view, end_time_view)
end

--[[ <==== INITIAL SAVE AND RESTORE ----- ]]

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

SaveSelectedItems(init_sel_items)
SaveView()
SaveCursorPos()

main() -- Execute your main function

RestoreCursorPos()
RestoreView()
RestoreSelectedItems(init_sel_items)

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)


