--[[
 * ReaScript Name: Create text items on first selected track from markers
 * About: Create text items on first selected track from markers
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
 * Version: 1.1
--]]

--[[
 * Changelog:
 * v1.1 (2016-01-22)
  # Better item creation

 * v1.0 (2016-01-14)
  + Initial Release
--]]

-- User Config Area ------------>

length = "2" -- default length of created items in seconds
prompt = true -- input popup active or not

----------End of User Config Area

-- Console Message
function Msg(g)
  reaper.ShowConsoleMsg(tostring(g).."\n")
end


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
        if bIsrgnOut == false then
          next_iRetval, next_bIsrgnOut, next_iPosOut, next_iRgnendOut, next_sNameOut, next_iMarkrgnindexnumberOut, next_iColorOut = reaper.EnumProjectMarkers3(0, i+1)
          if next_iRetval >= 1 and next_bIsrgnOut == false then
            if next_iPosOut - iPosOut < length then
              end_time = next_iPosOut
            else
              end_time = iPosOut + length
            end
          else
            end_time = iPosOut + length
          end
          item_length = end_time - iPosOut
          CreateTextItem(track, iPosOut, item_length, sNameOut, iColorOut)
        end
        i = i+1
      end
    until iRetval == 0
    reaper.Undo_EndBlock("Create text items on first selected track from markers", -1) -- End of the undo block. Leave it at the bottom of your main function.
  else -- no selected track
    reaper.ShowMessageBox("Select a destination track before running the script","Please",0)
  end

end


----------------------------------------------
-- INIT

if prompt == true then
  retval, length = reaper.GetUserInputs("Items Length", 1, "Item Length (s)", length)
end

if retval or prompt == false then -- if user complete the fields

  length = tonumber(length)

  if length ~= nil then

  reaper.PreventUIRefresh(1)

    length = math.abs(length)

  reaper.Main_OnCommand(40914, 0) -- Select first track as last touched

    main() -- Execute your main function

  reaper.UpdateArrange() -- Update the arrangement (often needed)

  reaper.PreventUIRefresh(-1)

  end

end


