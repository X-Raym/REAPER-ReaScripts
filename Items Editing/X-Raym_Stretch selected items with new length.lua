--[[
 * ReaScript Name: Stretch selected items with new length
 * Description: A way to stretch items with a new length
 * Instructions: Select items. Choose length. Run.
 * Screenshot: http://i.imgur.com/39zHx2j.gifv
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Editing (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=163363
 * REAPER: 5.0
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2016-11-26)
  + Initial Release
--]]

-- ------ USER AREA =====>

length = 2 -- number > 1
prompt = true -- true/false

-- <===== USER AREA ------

local reaper = reaper

function Main( length ) -- local (i, j, item, take, track)
  
  -- INITIALIZE loop through selected items
  for i, item in ipairs(init_sel_items)  do
    
    local take = reaper.GetActiveTake( item )

    local item_len = reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )    
    
    if take then
      
      -- INITIAL ITEM INFOS
      local init_take_rate = reaper.GetMediaItemTakeInfo_Value( take, "D_PLAYRATE" )
      local item_fadein = reaper.GetMediaItemInfo_Value(item, "D_FADEINLEN")
      local item_fadeout = reaper.GetMediaItemInfo_Value(item, "D_FADEOUTLEN")
      local item_position = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
      local item_snap = reaper.GetMediaItemInfo_Value(item, "D_SNAPOFFSET")
      
      -- SNAP
      local item_snap_absolute = item_snap + item_position

      local take_rate = item_len / length * init_take_rate
      
      local take_rate_ratio = init_take_rate / take_rate
      
      local new_snap_offset = item_snap * take_rate_ratio
      local new_fadein = item_fadein * take_rate_ratio
      local new_fadeout = item_fadeout * take_rate_ratio
      
      reaper.SetMediaItemTakeInfo_Value( take, "D_PLAYRATE", take_rate )
      reaper.SetMediaItemInfo_Value(item, "D_SNAPOFFSET", new_snap_offset)
      reaper.SetMediaItemInfo_Value(item, "D_FADEINLEN", new_fadein)
      reaper.SetMediaItemInfo_Value(item, "D_FADEOUTLEN", new_fadeout)
      
      local new_pos = item_position - (new_snap_offset - item_snap)
      
      reaper.SetMediaItemInfo_Value(item, "D_POSITION", new_pos)
    
    end
    
    reaper.SetMediaItemInfo_Value( item, "D_LENGTH", length )

  end -- ENDLOOP through selected items

end

-- SAVE INITIAL SELECTED ITEMS
function SaveSelectedItems (table)
  for i = 0, reaper.CountSelectedMediaItems(0)-1 do
    table[i+1] = reaper.GetSelectedMediaItem(0, i)
  end
end

selected_items_count = reaper.CountSelectedMediaItems(0)

if selected_items_count > 0 then
    
  if prompt then
    retval, length = reaper.GetUserInputs("Stretch Items", 1, "New length ( s > 0 )", tostring(length))
  end 

  if retval or prompt == false then
    
    length = tonumber(length)
    
    if length then
    
      length = math.abs(length)
    
      if length > 0 then
    
        reaper.PreventUIRefresh(1)
        
        reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
        
        init_sel_items = {}
        SaveSelectedItems( init_sel_items )

        Main( length ) -- Execute your main function
        
        reaper.Undo_EndBlock("Stretch selected items with new length", -1) -- End of the undo block. Leave it at the bottom of your main function.

        reaper.PreventUIRefresh(-1)

        reaper.UpdateArrange() -- Update the arrangement (often needed)
      
      end
      
    end
  
    end
  
end
