--[[
 * ReaScript Name: Create markers at selected items snap offset
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0 pre 15
 * Extensions: SWS/S&M 2.7.1
 * Version: 1.0.2
--]]

--[[
 * Changelog:
 * v1.0.2 (2020-07-05)
  + Cancel button
 * v1.0.1 (2019-02-24)
  + Message Box
 * v1.0 (2015-06-09)
  + Initial Release
--]]

function main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  retval = reaper.MB("Rename from:\n\t- Takes Names (OK)\n\t- Item Notes (NO)", "Create Markers", 3 ) -- We suppose that the user know the scale he want

  if retval and retval ~= 2 then
    -- INITIALIZE loop through selected items
    for i = 0, reaper.CountSelectedMediaItems(0) - 1 do

      -- GET ITEMS
      item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i

      item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
      item_snap = reaper.GetMediaItemInfo_Value(item, "D_SNAPOFFSET")

      take = reaper.GetActiveTake(item)
      if take == nil then
        item_color = reaper.GetDisplayedMediaItemColor(item)
      else
        item_color = reaper.GetDisplayedMediaItemColor2(item, take)
      end

      if retval == 6 then
        if take ~= nil then
          name = reaper.GetTakeName(take)
        else
          name = reaper.ULT_GetMediaItemNote(item)
        end
      else
        name = reaper.ULT_GetMediaItemNote(item)
      end

      snap = item_pos + item_snap
      reaper.AddProjectMarker2(0, false, snap, 0, name, -1, item_color)


    end -- ENDLOOP through selected items
  end

  reaper.Undo_EndBlock("Create markers at selected items snap offset", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)
