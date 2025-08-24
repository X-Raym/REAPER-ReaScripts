--[[
 * ReaScript Name: Set selected items snap offset to first transient
 * About: Note: it is zoom dependant for now
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Editing (various)
 * Forum Thread URI: https://forum.cockos.com/showthread.php?t=163363
 * REAPER: 5.0
 * Version: 1.0.0
--]]

--[[
 * Changelog:
 * v1.0.0 (2025-08-23)
  + Initial Release
--]]


-- USER CONFIG AREA -----------------------------------------------------------

-- Use Preset Script for safe moding or to create a new action with your own values
-- https://github.com/X-Raym/REAPER-ReaScripts/tree/master/Templates/Script%20Preset

console = true -- true/false: display debug messages in the console

------------------------------------------------------- END OF USER CONFIG AREA


-- UTILITIES -------------------------------------------------------------

-- Save item selection
function SaveSelectedItems (table)
  for i = 0, reaper.CountSelectedMediaItems(0)-1 do
    table[i+1] = reaper.GetSelectedMediaItem(0, i)
  end
end

function RestoreSelectedItems (table)
  reaper.SelectAllMediaItems( 0, false ) -- Unselect all items
  for _, item in ipairs(table) do
    reaper.SetMediaItemSelected(item, true)
  end
end


-- Display a message in the console for debugging
function Msg(value)
  if console then
    reaper.ShowConsoleMsg(tostring(value) .. "\n")
  end
end

-- SAVE INITIAL VIEW
function SaveView()
  start_time_view, end_time_view = reaper.BR_GetArrangeView(0)
end

-- RESTORE INITIAL VIEW
function RestoreView()
  reaper.BR_SetArrangeView(0, start_time_view, end_time_view)
end

--------------------------------------------------------- END OF UTILITIES


-- Main function
function main()

  for i, item in ipairs(init_sel_items) do

    local take = reaper.GetActiveTake( item )
    if take and not reaper.TakeIsMIDI( take ) then
      reaper.SelectAllMediaItems(0,false)
      reaper.SetMediaItemSelected( item, true )
      local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
      local item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
      local item_end = item_pos + item_len

      reaper.SetEditCurPos( item_pos, false, false)

      reaper.Main_OnCommand(40375,0) -- Item navigation: Move cursor to next transient in items
      local new_edit_pos = reaper.GetCursorPosition()
    
      reaper.SetMediaItemInfo_Value(item, "D_SNAPOFFSET", new_edit_pos - item_pos)

    end

  end

end


-- INIT

-- See if there is items selected
function Init()
  count_sel_items = reaper.CountSelectedMediaItems(0)
  if count_sel_items == 0 then return end
  
  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  init_sel_items =  {}
  SaveSelectedItems(init_sel_items)

  group_state = reaper.GetToggleCommandState(1156)
  if group_state == 1 then
    reaper.Main_OnCommand(1156,0)
  end

  cur_pos = reaper.GetCursorPosition()
  
  SaveView()

  main()
  
  RestoreSelectedItems(init_sel_items)

  if group_state == 1 then
    reaper.Main_OnCommand(1156,0)
  end

  reaper.SetEditCurPos( cur_pos, true, true)
  
  RestoreView()

  reaper.Undo_EndBlock("Set selected items snap offset to first transient", -1) -- End of the undo block. Leave it at the bottom of your main function.

  reaper.UpdateArrange()

  reaper.PreventUIRefresh(-1)
  
end

if not preset_file_init then
  Init()
end
