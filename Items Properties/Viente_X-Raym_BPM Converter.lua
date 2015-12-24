--[[
 * ReaScript Name: BPM Converter
 * Description: Insert FX on selected tracks. FX name is can be edited witing the script code.
 * Instructions: Run
 * Screenshot:
 * Author: Viente, X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI:
 * Licence: GPL v3
 * Forum Thread: Viente's BPM Converter
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=110780
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.0.6
--]]

--[[
 * Changelog:
 * v1.0 (2015-05-13)
	# Now in Lua
	+ Works on multiple selected items (BPM detection based on first selected item)
	# user input "cancel" corrected
--]]

-- ------------------------------------------

------ functionine variables and functions ----------------------------------------------------------------------------------------------------------------------------------------
numItems = reaper.CountSelectedMediaItems(0)
selItem = reaper.GetSelectedMediaItem(0, 0)

function msg(m)					-- functionine function: console output alias for debugging
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

end	--reaper.ShowConsoleMsg(str(bpm) + "\n")

function setTempo()

	master_tempo = math.floor(reaper.Master_GetTempo())

	functionaults = tostring(bpm)..","..tostring(master_tempo)
	retval, retvals_csv = reaper.GetUserInputs("BPM Converter", 2, "Original Tempo (BPM),Target Tempo (BPM)", functionaults) 

	if retval == true then
		
		-- PARSE THE STRING
		answer1, answer2 = retvals_csv:match("([^,]+),([^,]+)")
		answer1 = tonumber(answer1)
		answer2 = tonumber(answer2)

		if answer1 > 20 and answer1 < 299 and answer2 > 20 and answer2 < 299 then

			if answer2 > answer1 then

				bpm_rate = (answer2 / answer1) -1
				for i = 0, numItems - 1 do
					item = reaper.GetSelectedMediaItem(0, i)
					take = reaper.GetActiveTake(item)
					currentrate = reaper.GetMediaItemTakeInfo_Value(take, "D_PLAYRATE")
					reaper.SetMediaItemTakeInfo_Value(take, "D_PLAYRATE", currentrate + bpm_rate)
				end
			
			elseif answer2 < answer1 then

				bpm_rate = (answer2 / answer1)
				bpm_calc = (1 - bpm_rate)
				for i = 0, numItems - 1 do
					item = reaper.GetSelectedMediaItem(0, i)
					take = reaper.GetActiveTake(item)
					currentrate = reaper.GetMediaItemTakeInfo_Value(take, "D_PLAYRATE")
					reaper.SetMediaItemTakeInfo_Value(take, "D_PLAYRATE", currentrate - bpm_calc)
				end
			
			end
			
			reaper.Main_OnCommand(40612,0) -- Fix item length

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