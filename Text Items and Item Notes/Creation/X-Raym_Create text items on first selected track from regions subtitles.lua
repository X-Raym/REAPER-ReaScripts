--[[
 * ReaScript Name: Create text items on first selected track from regions subtitles
 * Instructions: Select a destination track. Execute the script. Text items will be colored depending on original region color. The text note will came from the original region subtitles.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Script: Scripts (LUA): Create Text Items Actions (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=156763
 * REAPER: 5.0
 * Extensions: SWS/S&M 2.8.3
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2022-20-02)
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
          notes = reaper.NF_GetSWSMarkerRegionSub( i )
          CreateTextItem(track, iPosOut, length, notes, iColorOut)
        end
        i = i+1
      end
    until iRetval == 0
    reaper.Undo_EndBlock("Create text items on first selected track from regions subtitles", -1) -- End of the undo block. Leave it at the bottom of your main function.
  else -- no selected track
    reaper.ShowMessageBox("Select a destination track before running the script","Please",0)
  end

end

if not reaper.ULT_SetMediaItemNote then 
  reaper.ShowConsoleMsg("SWS extension is required by this script.\nHowever, it doesn't seem to be present for this REAPER installation.\n\nDownload it here:\nhttp://www.sws-extension.org/download/")
  return false
end

reaper.PreventUIRefresh(1)

reaper.Main_OnCommand(40914, 0) -- Select first track as last touched
main() -- Execute your main function

reaper.UpdateArrange() -- Update the arrangement (often needed)

reaper.PreventUIRefresh(-1)


