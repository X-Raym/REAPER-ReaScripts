--[[
 * ReaScript Name: Color selected items from regions at their middle position
 * Screenshot: https://i.imgur.com/q9kBdMb.gifv
 * Author: X-Raym
 * Author URI: https://extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Request, split selected item(s) to regions.
 * Forum Thread URI: https://forum.cockos.com/showthread.php?t=195520
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2019-11-18)
  + Initial Release
--]]

-- USER CONFIG AREA -----------------------------------------------------------

console = false -- true/false: display debug messages in the console

------------------------------------------------------- END OF USER CONFIG AREA

function main()

	-- INITIALIZE loop through selected items
	for i = 0, count_sel_items - 1 do

		-- GET ITEMS
		local item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i

		local take = reaper.GetActiveTake(item)

		local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
		local item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
		local pos = item_pos + item_len / 2

		local marker_idx, region_idx = reaper.GetLastMarkerAndCurRegion(0, pos)

		local iRetval, bIsrgnOut, iPosOut, iRgnendOut, sNameOut, iMarkrgnindexnumberOut, iColorOur = reaper.EnumProjectMarkers3(0, region_idx)
		-- SETNAMES

		if iRetval > 0 then
			if take then
				reaper.SetMediaItemTakeInfo_Value(take, "I_CUSTOMCOLOR", iColorOur, true)
			else
				reaper.SetMediaItemInfo_Value(item, "I_CUSTOMCOLOR", iColorOur, true)
			end
		end

	end -- ENDLOOP through selected items

end

-- INIT

-- See if there is items selected
count_sel_items = reaper.CountSelectedMediaItems(0)

if count_sel_items > 0 then

	reaper.PreventUIRefresh(1)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	main()

	reaper.Undo_EndBlock("Color selected items from regions at their middle position", - 1) -- End of the undo block. Leave it at the bottom of your main function.

	reaper.UpdateArrange()

	reaper.PreventUIRefresh(-1)

end
