--[[
 * ReaScript Name: Rename selected takes from regions
 * Author: X-Raym
 * Author URI: https://extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Request, split selected item(s) to regions.
 * Forum Thread URI: https://forum.cockos.com/showthread.php?t=169127
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2017-09-21)
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

    if take then

      local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")


      local marker_idx, region_idx = reaper.GetLastMarkerAndCurRegion(0, item_pos)

      local iRetval, bIsrgnOut, iPosOut, iRgnendOut, sNameOut, iMarkrgnindexnumberOut, iColorOur = reaper.EnumProjectMarkers3(0, region_idx)
      -- SETNAMES

      if iRetval > 0 then
        reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", sNameOut, true)
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

  reaper.Undo_EndBlock("Rename selected takes from regions", - 1) -- End of the undo block. Leave it at the bottom of your main function.

  reaper.UpdateArrange()

  reaper.PreventUIRefresh(-1)

end
