--[[
 * ReaScript Name: Split selected items every X seconds intervals
 * Description: See title
 * Instructions: Select Items. Run.
 * Author: X-Raym
 * Author URI: http://www.extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Lua Script: Split Media Into Into X Equal Parts
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1609741#post1609741
 * REAPER: 5.0
 * Extensions: None
 *
 * Version: 1.0
 * Changelog: (2015-19-12)
 *   + Initial Release
--]]

--[[
  Based on SplitX script
  v1.1 written by yellowmix
  Entered into the Public Domain
-]]

function ShowMessage(msg)
  reaper.ShowConsoleMsg(tostring(msg))
end

function main()
  reaper.Undo_BeginBlock()
  
  if reaper.CountSelectedMediaItems(0) > 0 then
    numSplitItems = getNumSplitItems()
    if numSplitItems == nil then
      return
    else
      splitCounter = 0
      for i = 1, (reaper.CountSelectedMediaItems(0)) do
        it = reaper.GetSelectedMediaItem(0, i - 1 + splitCounter)
        length = reaper.GetMediaItemInfo_Value(it, "D_LENGTH")
        split_position = reaper.GetMediaItemInfo_Value(it, "D_POSITION") + numSplitItems
		split_number = math.floor(length/numSplitItems)
        for j = 1,(split_number - 1) do
          it = reaper.SplitMediaItem(it, split_position)
          split_position = split_position + numSplitItems
          splitCounter = splitCounter + 1
        end
      end
    end
  else
      ShowMessage("Error: No Media Item selected.")
  end
  
  reaper.Undo_EndBlock("Split Items X times", 0)
end

function getNumSplitItems()
  title = "Split selected items every X seconds"
  num_inputs = 1
  captions_csv = "Interval"
  retvals_csv = "1"
  retval, retvals_csv = reaper.GetUserInputs(title, num_inputs, captions_csv, retvals_csv)
  if retval == true then
    return tonumber(retvals_csv)
  else
    ShowMessage("None or invalid number.")
    return nil
  end
end

reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()