--[[
 * ReaScript Name: Quantize selected items to closest region start
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
 * Version: 1.1
 --]]

--[[
 * Changelog:
 * v1.1 (2015-12-24)
   + Preserve relative position of items in groups (considering min pos of selected items in groups as referance, and propagate offset on al items in groups, even non selected ones.
 * v1.0 (2015-12-24)
   + Initial release
 --]]

console = true
function Msg(variable)
  if console == true then
    reaper.ShowConsoleMsg(tostring(variable).."\n")
  end
end


function SaveRegionsStart()
  regions_start = {}

  i=0
  repeat
    iRetval, bIsrgnOut, iPosOut, iRgnendOut, sNameOut, iMarkrgnindexnumberOut, iColorOur = reaper.EnumProjectMarkers3(0,i)
    if iRetval >= 1 then
      if bIsrgnOut == true then
        table.insert(regions_start, iPosOut)
      end
      i = i+1
    end
  until iRetval == 0
  table.sort(regions_start)
  return regions_start

end

-- http://stackoverflow.com/questions/29987249/find-the-nearest-value
function NearestValue(table, number)
  local smallestSoFar, smallestIndex
  for i, y in ipairs(table) do
      if not smallestSoFar or (math.abs(number-y) < smallestSoFar) then
          smallestSoFar = math.abs(number-y)
          smallestIndex = i
      end
  end
  return smallestIndex, table[smallestIndex]
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
      index, pos = NearestValue(regions_start, item_pos+item_snap)
      reaper.SetMediaItemInfo_Value(item, "D_POSITION", pos-item_snap)
    end
  end
  
  offsets = {}
  -- Transform Min Pos in Groups into Offset Settings
  for key, min_pos in pairs(groups) do
    index, closest_grid = NearestValue(regions_start, min_pos)
    offset = closest_grid - min_pos
    Msg(closest_grid .. "-" .. min_pos .. "=" .. "offset")
    offsets[key] = offset
  end
  
  SaveAllItems(all_items)
  
  -- Apply offset of items in groups
  for i, item in ipairs(all_items) do
    group = reaper.GetMediaItemInfo_Value(item, "I_GROUPID")
        -- If in Group
    if group > 0 then
      -- If group doesn't exist
      if groups[group] ~= nil then
        
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

if count_sel_items > 0 and count_regions > 0 then
  reaper.PreventUIRefresh(1)
  SaveRegionsStart()
  sel_items = {}
  all_items = {}
  SaveSelectedItems(sel_items)
  reaper.Undo_BeginBlock()
  main()
  reaper.Undo_EndBlock("Quantize selected items to closest region start", -1)
  reaper.UpdateArrange()
  reaper.PreventUIRefresh(-1)
end
