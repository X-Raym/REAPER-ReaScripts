--[[
 * ReaScript Name: Quantize selected items to previous marker position
 * Description: A template script for REAPER ReaScript.
 * Instructions: Have Regions. Select items. Run.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Editing (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=163363
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.0
 --]]

--[[
 * Changelog:
 * v1.0 (2016-01-14)
   + Initial release
 --]]

console = false
function Msg(variable)
  if console == true then
    reaper.ShowConsoleMsg(tostring(variable).."\n")
  end
end

function SaveMarkers()
  markers_pos = {}

  i=0
  repeat
    iRetval, bIsrgnOut, iPosOut, iRgnendOut, sNameOut, iMarkrgnindexnumberOut, iColorOur = reaper.EnumProjectMarkers3(0,i)
    if iRetval >= 1 then
      if bIsrgnOut == false then
        table.insert(markers_pos, iPosOut)
      end
      i = i+1
    end
  until iRetval == 0
  table.sort(markers_pos)
  return markers_pos

end


function PreviousValue(table, number)
  local smallestSoFar, smallestIndex
  for i, y in ipairs(table) do
	if y < number then
      index = i
    else
	  break
	end
  end
  return index, table[index]
end

function main()
groups = {}
 for i, item in ipairs(sel_items) do
    -- Check Group
    group = reaper.GetMediaItemInfo_Value(item, "I_GROUPID")
    item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    item_snap = reaper.GetMediaItemInfo_Value(item, "D_SNAPOFFSET")
    item_snap_abs = item_pos + item_snap
    -- If in Group
    if group > 0 then
      -- If group doesn't exist
      if groups[group] == nil then
        
        -- Groups have ID as key and minimum POS as reference
        groups[group] = item_snap_abs
      
      else -- if group exist, set minimum item pos of the group (first selected items in groups in time behave like the leader of the group)
      
        if item_snap_abs < groups[group] then groups[group] = item_snap_abs end
      
      end
    else -- no group
      index, pos = PreviousValue(markers_pos, item_pos+item_snap)
      if index ~= nil then
		reaper.SetMediaItemInfo_Value(item, "D_POSITION", pos-item_snap)
      end
    end
  end
  
  offsets = {}
  -- Transform Min Pos in Groups into Offset Settings
  for key, min_pos in pairs(groups) do
    index, closest_grid = PreviousValue(markers_pos, min_pos)
	if index ~= nil then
		offset = closest_grid - min_pos
		--Msg(closest_grid .. "-" .. min_pos .. "=" .. "offset")
		offsets[key] = offset
	end
  end
  
  SaveAllItems(all_items)
  
  -- Apply offset of items in groups
  for i, item in ipairs(all_items) do
    group = reaper.GetMediaItemInfo_Value(item, "I_GROUPID")
        -- If in Group
    if group > 0 then
      -- If group doesn't exist
      if groups[group] ~= nil and offsets[group] ~= nil then
        
        item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
        reaper.SetMediaItemInfo_Value(item, "D_POSITION", item_pos + offsets[group])
      
      end
    
    end
    
  end  
end

function SaveSelectedItems (table)
  for i = 0, reaper.CountSelectedMediaItems(0)-1 do
    table[i+1] = reaper.GetSelectedMediaItem(0, i)
  end
end

function SaveAllItems(table)
  for i = 0, reaper.CountMediaItems(0)-1 do
    table[i+1] = reaper.GetMediaItem(0, i)
  end
end

count_sel_items = reaper.CountSelectedMediaItems(0, 0)
retval, count_markers, count_regions = reaper.CountProjectMarkers(0)

if count_sel_items > 0 and count_markers > 0 then
  reaper.PreventUIRefresh(1)
  SaveMarkers()
  sel_items = {}
  all_items = {}
  SaveSelectedItems(sel_items)
  reaper.Undo_BeginBlock()
  main()
  reaper.Undo_EndBlock("Quantize selected items to previous marker position", -1)
  reaper.UpdateArrange()
  reaper.PreventUIRefresh(-1)
end
