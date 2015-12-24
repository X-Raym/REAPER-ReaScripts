--[[
 * ReaScript Name: Quantize selected items to closest marker position
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
 * v1.0 (2015-12-24)
 	+ Initial release
 --]]

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
	for i, item in ipairs(sel_items) do
		item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
		item_snap = reaper.GetMediaItemInfo_Value(item, "D_SNAPOFFSET")
		index, pos = NearestValue(markers_pos, item_pos+item_snap)
		reaper.SetMediaItemInfo_Value(item, "D_POSITION", pos-item_snap)
	end
end

local function SaveSelectedItems (table)
	for i = 0, reaper.CountSelectedMediaItems(0)-1 do
		table[i+1] = reaper.GetSelectedMediaItem(0, i)
	end
end

count_sel_items = reaper.CountSelectedMediaItems(0, 0)
retval, count_markers, count_regions = reaper.CountProjectMarkers(0)

if count_sel_items > 0 and count_regions > 0 then
	reaper.PreventUIRefresh(1)
	SaveMarkers()
	sel_items = {}
	SaveSelectedItems(sel_items)
	reaper.Undo_BeginBlock()
	main()
	reaper.Undo_EndBlock("Quantize selected items to closest marker position", -1)
	reaper.UpdateArrange()
	reaper.PreventUIRefresh(-1)
end
