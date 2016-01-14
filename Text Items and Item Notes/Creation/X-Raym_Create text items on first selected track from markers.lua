--[[
 * ReaScript Name: Create text items on first selected track from markers
 * Description: Create text items on first selected track from markers
 * Instructions: Select a destination track. Execute the script. Text items will be colored depending on original region color. The text note will came from the original region name.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script: Scripts (LUA): Create Text Items Actions (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=156763
 * REAPER: 5.0
 * Extensions: SWS/S&M 2.8.3
 * Version: 1.0
--]]
 
--[[
 * Changelog:
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


function CreateTextItem(starttime, endtime, notetext, color) 
	--ref: Lua: number startOut retval, number endOut reaper.GetSet_LoopTimeRange(boolean isSet, boolean isLoop, number startOut, number endOut, boolean allowautoseek)
	reaper.GetSet_LoopTimeRange(1,0,starttime,endtime,0) -- define the time range for the empty item
	--ref: Lua: reaper.Main_OnCommand(integer command, integer flag)
	reaper.Main_OnCommand(40142,0) -- insert empty item
	--ref: Lua: MediaItem reaper.GetSelectedMediaItem(ReaProject proj, integer selitem)
	item = reaper.GetSelectedMediaItem(0,0) -- get the selected item
	
	reaper.SetMediaItemInfo_Value(item, "I_CUSTOMCOLOR", color)

	reaper.ULT_SetMediaItemNote(item, notetext)
	
	Msg(starttime .. "->" .. endtime)
	
end
-- <==== From Heda's HeDa_SRT to text items.lua


function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	track = reaper.GetSelectedTrack(0, 0) -- Get selected track i

	-- IF THERE IS A TRACK SELECTED
	if track ~= nil then
	
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
					CreateTextItem(iPosOut, end_time, sNameOut, iColorOut)
				end
				i = i+1
			end
		until iRetval == 0
		reaper.Undo_EndBlock("Create text items on first selected track from markers", -1) -- End of the undo block. Leave it at the bottom of your main function.
	else -- no selected track
		reaper.ShowMessageBox("Select a destination track before running the script","Please",0)
	end

end

--[[ ----- INITIAL SAVE AND RESTORE ====> ]]

-- LOOP AND TIME SELECTION
-- SAVE INITIAL LOOP AND TIME SELECTION
function SaveLoopTimesel()
	init_start_timesel, init_end_timesel = reaper.GetSet_LoopTimeRange(0, 0, 0, 0, 0)
	init_start_loop, init_end_loop = reaper.GetSet_LoopTimeRange(0, 1, 0, 0, 0)
end

-- RESTORE INITIAL LOOP AND TIME SELECTION
function RestoreLoopTimesel()
	reaper.GetSet_LoopTimeRange(1, 0, init_start_timesel, init_end_timesel, 0)
	reaper.GetSet_LoopTimeRange(1, 1, init_start_loop, init_end_loop, 0)
end

-- CURSOR
-- SAVE INITIAL CURSOR POS
function SaveCursorPos()
	init_cursor_pos = reaper.GetCursorPosition()
end

-- RESTORE INITIAL CURSOR POS
function RestoreCursorPos()
	reaper.Main_OnCommand(40042, 0) -- Go to start of the project
	reaper.MoveEditCursor(init_cursor_pos, false)
end

-- VIEW
-- SAVE INITIAL VIEW
function SaveView()
	start_time_view, end_time_view = reaper.BR_GetArrangeView(0)
end


-- RESTORE INITIAL VIEW
function RestoreView()
	reaper.BR_SetArrangeView(0, start_time_view, end_time_view)
end
--[[ <==== INITIAL SAVE AND RESTORE ----- ]]

----------------------------------------------
-- INIT

if prompt == true then
  retval, length = reaper.GetUserInputs("Items Length", 1, "Item Length (s)", length)
end

if retval or prompt == false then -- if user complete the fields

  length = tonumber(length)

  if length ~= nil then
  
	reaper.PreventUIRefresh(1)
	SaveView()
	SaveCursorPos()
	SaveLoopTimesel()

    length = math.abs(length)
	
	reaper.Main_OnCommand(40914, 0) -- Select first track as last touched

    main() -- Execute your main function

	RestoreView()
	RestoreLoopTimesel()
	RestoreCursorPos()

	reaper.UpdateArrange() -- Update the arrangement (often needed)

	reaper.PreventUIRefresh(-1)

  end

end

--msg_end() -- Display characters in the console to show you the end of the script execution.
