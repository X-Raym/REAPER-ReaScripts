--[[
 * ReaScript Name: Create text items on first selected track from regions
 * About: Create text items on first selected track from regions
 * Instructions: Select a destination track. Execute the script. Text items will be colored depending on original region color. The text note will came from the original region name.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Script: Scripts (LUA): Create Text Items Actions (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=156763
 * REAPER: 5.0
 * Extensions: SWS/S&M 2.8.3
 * Version: 1.4
--]]

--[[
 * Changelog:
 * v1.4 (2016-01-22)
  # Better item creation
 * v1.3 (2015-07-29)
  # Better Set notes
 * v1.1.1 (2015-03-11)
  # Better item selection restoration
  # First selected track as last touched
 * v1.1 (2015-03-06)
  + Multiple lines support
  + Dialog box if no track selected
 * v1.0 (2015-02-28)
  + Initial Release
--]]


-- CREATE TEXT ITEMS
-- text and color are optional
function CreateTextItem(track, position, length, text, color)

  local item = reaper.AddMediaItemToTrack(track)

  reaper.SetMediaItemInfo_Value(item, "D_POSITION", position)
  reaper.SetMediaItemInfo_Value(item, "D_LENGTH", length)

  if text ~= nil then
    reaper.ULT_SetMediaItemNote(item, text)
  end

  if color ~= nil then
    reaper.SetMediaItemInfo_Value(item, "I_CUSTOMCOLOR", color)
  end

  return item

end


function main()

  track = reaper.GetSelectedTrack(0, 0) -- Get selected track i

  -- IF THERE IS A TRACK SELECTED
  if track ~= nil then

    reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

    -- LOOP THROUGH REGIONS
    i=0
    repeat
      iRetval, bIsrgnOut, iPosOut, iRgnendOut, sNameOut, iMarkrgnindexnumberOut, iColorOut = reaper.EnumProjectMarkers3(0, i)
      if iRetval >= 1 then
        if bIsrgnOut == true then
          length = iRgnendOut - iPosOut
          CreateTextItem(track, iPosOut, length, sNameOut, iColorOut)
        end
        i = i+1
      end
    until iRetval == 0
    reaper.Undo_EndBlock("Create text items on first selected track from regions", -1) -- End of the undo block. Leave it at the bottom of your main function.
  else -- no selected track
    reaper.ShowMessageBox("Select a destination track before running the script","Please",0)
  end

end


reaper.PreventUIRefresh(1)

reaper.Main_OnCommand(40914, 0) -- Select first track as last touched
main() -- Execute your main function

reaper.UpdateArrange() -- Update the arrangement (often needed)

reaper.PreventUIRefresh(-1)


