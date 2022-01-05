--[[
 * ReaScript Name: BPM Converter
 * Screenshot: https://s3.amazonaws.com/f.cl.ly/items/3j1g3Q050i010P3S0Y3c/bpmconverter.gif
 * Author: Viente, X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Viente's BPM Converter
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=110780
 * REAPER: 5.0
 * Version: 1.1.1
--]]

--[[
 * Changelog:
 * v1.1 (2017-12-15)
  # Works with cropped items
 * v1.0 (2015-05-13)
  # Now in Lua
  + Works on multiple selected items (BPM detection based on first selected item)
  # user input "cancel" corrected
--]]

-- ------------------------------------------

------ functionine variables and functions ----------------------------------------------------------------------------------------------------------------------------------------
numItems = reaper.CountSelectedMediaItems(0)
selItem = reaper.GetSelectedMediaItem(0, 0)

function msg(m)                         -- functionine function: console output alias for debugging
  reaper.ShowConsoleMsg(tostring(m) .. '\n')
end
--msg("")

function getMusicalLenght(selItem)

  -- Get selected item's start and end
  itemStart = reaper.GetMediaItemInfo_Value(selItem, "D_POSITION")
  itemEnd = itemStart + reaper.GetMediaItemInfo_Value(selItem, "D_LENGTH")

  -- Check if there are any tempo changes during item's length (NextChangeTime will output -1 if there are no more tempo markers after the requested position)
  if reaper.TimeMap2_GetNextChangeTime(0, itemStart) > itemEnd or reaper.TimeMap2_GetNextChangeTime(0, itemStart) == -1 then

    -- There are no tempo markers over selected item so we continue
    timeSig, timesig_denomOut, startBPM = reaper.TimeMap_GetTimeSigAtTime(0, itemStart)

    -- This is needed because then we don't have to worry about linear/square difference of tempo points
    timeSig, timesig_denomOut, endBPM = reaper.TimeMap_GetTimeSigAtTime(0, itemEnd) -- we don't use TimeMap_GetDividedBpmAtTime because note in the API says: get the effective BPM at the time (seconds) position (i.e. 2x in /8 signatures)

    -- This is the formula
    musicalLenght = ((startBPM + endBPM) * timesig_denomOut * (itemEnd - itemStart)) / (480 * timeSig)

  else
    -- if there are existing tempo markers during item's length, you have to get them and calculate everything separately
    reaper.Main_OnCommand(65535, 0)

  end
end

function getTempo()

  timeSel = reaper.GetMediaItemInfo_Value(selItem, "D_LENGTH")
  rawTempo = 4*60/timeSel
  tempo = math.floor(rawTempo+0.5, 2)

  if musicalLenght < 1 or musicalLenght == 1 then

    bpm = tempo

  elseif musicalLenght > 1 and musicalLenght < 3 then

    bpm = tempo * 2

  elseif musicalLenght > 3 and musicalLenght < 5 then

    bpm = tempo * 4

  elseif musicalLenght > 5 and musicalLenght < 7 then

    bpm = tempo * 6

  elseif musicalLenght > 7 and musicalLenght < 9 then

    bpm = tempo * 8

  elseif musicalLenght > 9 and musicalLenght < 11 then

    bpm = tempo * 10

  elseif musicalLenght > 11 and musicalLenght < 13 then

    bpm = tempo * 12

  elseif musicalLenght > 13 and musicalLenght < 15 then

    bpm = tempo * 14

  elseif musicalLenght > 15 and musicalLenght < 17 then

    bpm = tempo * 16

  else

    bpm = 1
  end

end     --reaper.ShowConsoleMsg(str(bpm) + "\n")

function SetItemFromBPMToBPM( item, bpm_source, bpm_target )

  local take = reaper.GetActiveTake(item)

  local rate = bpm_target / bpm_source

  if take then
    reaper.SetMediaItemTakeInfo_Value(take, "D_PLAYRATE", rate)
  end

  local item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
  reaper.SetMediaItemInfo_Value(item, "D_LENGTH", item_len * ( bpm_source / bpm_target ) )

  return rate

end

function setTempo()

  master_tempo = math.floor(reaper.Master_GetTempo())

  functionaults = tostring(bpm)..","..tostring(master_tempo)
  retval, retvals_csv = reaper.GetUserInputs("BPM Converter", 2, "Original Tempo (BPM),Target Tempo (BPM)", functionaults)

  if retval == true then

    -- PARSE THE STRING
    bpm_source, bpm_target = retvals_csv:match("([^,]+),([^,]+)")
    bpm_source = tonumber(bpm_source)
    bpm_target = tonumber(bpm_target)

    if bpm_source > 20 and bpm_source < 299 and bpm_target > 20 and bpm_target < 299 then

      for i = 0, numItems - 1 do
        local item = reaper.GetSelectedMediaItem(0, i)
        SetItemFromBPMToBPM( item, bpm_source, bpm_target )
      end

    else
      reaper.ShowMessageBox("Incorrect tempo!", "Error", 0) -- 0=OK,2=OKCANCEL,2=ABORTRETRYIGNORE,3=YESNOCANCEL,4=YESNO,5=RETRYCANCEL : ret 1=OK,2=CANCEL,3=ABORT,4=RETRY,5=IGNORE,6=YES,7=NO
    end
  end
end
------ Calling actions & functions ----------------------------------------------------------------------------------------------------------------------------------------------

reaper.Undo_BeginBlock()

if numItems >= 1 then

  getMusicalLenght(selItem)
  getTempo()
  setTempo()
  reaper.UpdateArrange()

else

  reaper.ShowMessageBox("Please select one item...", "Error", 0) -- 0=OK,2=OKCANCEL,2=ABORTRETRYIGNORE,3=YESNOCANCEL,4=YESNO,5=RETRYCANCEL : ret 1=OK,2=CANCEL,3=ABORT,4=RETRY,5=IGNORE,6=YES,7=NO

end

reaper.Undo_EndBlock("Convert BPM of selected item",-1)
