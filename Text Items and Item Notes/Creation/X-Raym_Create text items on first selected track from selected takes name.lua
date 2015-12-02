--[[
 * ReaScript Name: Create text items on first selected track from selected takes name
 * Description: X-Raym_Create text items on first selected track from selected takes name.lua
 * Instructions:  Select items. Select a destination track. Execute the script. Text items will be colored depending on original take color, or track color from item if no take color is set. The text note will came from the original take name.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script: Scripts (LUA): Create Text Items Actions (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=156763
 * REAPER: 5.0 pre 29
 * Extensions: SWS/S&M 2.7.1 #0
 --]]
 
--[[
 * Changelog:
 * v1.3 (2015-07-29)
	# Better Set notes
 * v1.2 (2015-05-08)
	# Better view restoration
 * v1.1.2 (2015-03-11)
	# Better item selection restoration
	# First selected track as last touched
 * v1.1.1 (2015-03-07)
	# bug-fix
 * v1.1 (2015-03-06)
	+ Multiple lines support
	+ Dialog box if no track selected
 * v1.0 (2015-02-28)
	+ Initial Release
 --]]

--[[ ----- DEBUGGING ====>
function get_script_path()
  if reaper.GetOS() == "Win32" or reaper.GetOS() == "Win64" then
    return debug.getinfo(1,'S').source:match("(.*".."\\"..")"):sub(2) -- remove "@"
  end
    return debug.getinfo(1,'S').source:match("(.*".."/"..")"):sub(2)
end

package.path = package.path .. ";" .. get_script_path() .. "?.lua"
require("X-Raym_Functions - console debug messages")

debug = 0 -- 0 => No console. 1 => Display console messages for debugging.
clean = 0 -- 0 => No console cleaning before every script execution. 1 => Console cleaning before every script execution.

msg_clean()
]]-- <==== DEBUGGING -----

-- From Heda's HeDa_SRT to text items.lua ====>

function CreateTextItem(starttime, endtime, notetext, color) 
	--ref: Lua: number startOut retval, number endOut reaper.GetSet_LoopTimeRange(boolean isSet, boolean isLoop, number startOut, number endOut, boolean allowautoseek)
	reaper.GetSet_LoopTimeRange(1,0,starttime,endtime,0) -- define the time range for the empty item
	--ref: Lua: reaper.Main_OnCommand(integer command, integer flag)
	reaper.Main_OnCommand(40142,0) -- insert empty item
	--ref: Lua: MediaItem reaper.GetSelectedMediaItem(ReaProject proj, integer selitem)
	local item = reaper.GetSelectedMediaItem(0,0) -- get the selected item
	reaper.SetMediaItemInfo_Value(item, "I_CUSTOMCOLOR", color)

	reaper.ULT_SetMediaItemNote(item, notetext)
	
	reaper.SetEditCurPos(endtime, 1, 0) -- moves cursor for next item
end

-- <==== From Heda's HeDa_SRT to text items.lua

-- TABLE INIT
local setSelectedMediaItem = {}

-- MAIN
function main()

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	local selected_tracks_count = reaper.CountSelectedTracks(0)

	if selected_tracks_count > 0 then

		-- DEFINE TRACK DESTINATION
		local selected_track = reaper.GetSelectedTrack(0,0)

		-- COUNT SELECTED ITEMS
		local selected_items_count = reaper.CountSelectedMediaItems(0)

		if selected_items_count > 0 then

			-- SAVE TAKES SELECTION
			for j = 0, selected_items_count-1  do
				setSelectedMediaItem[j] = reaper.GetSelectedMediaItem(0, j)
			end

			-- LOOP THROUGH TAKE SELECTION
			for i = 0, selected_items_count-1  do
				-- GET ITEMS AND TAKES AND PARENT TRACK
				local item = setSelectedMediaItem[i] -- Get selected item i
				local track = reaper.GetMediaItem_Track(item)
				
				-- GET INFOS
				local item_color = reaper.GetDisplayedMediaItemColor(item)
					
				-- TIMES
				local item_start = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
				local item_duration = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
				local item_end = item_start + item_duration

				local take = reaper.GetActiveTake(item)
				
				-- NAME
				local take = reaper.GetActiveTake(item) -- Get the active take !! BUG WITH EMPTY ITEM SELECTED
				if take ~= nil then
					local text = reaper.GetTakeName(take)
					CreateTextItem(item_start, item_end, text, item_color)
				--[[else
					text = reaper.ULT_GetMediaItemNote(item)]]
				end
			end -- ENDLOOP through selected items
			reaper.Main_OnCommand(40421, 0)
			reaper.Undo_EndBlock("Create text items on selected track from selected takes", 0) -- End of the undo block. Leave it at the bottom of your main function.
		else -- no selected item
			reaper.ShowMessageBox("Select at least one item","Please",0)
		end -- if select item
	else -- no selected track
		reaper.ShowMessageBox("Select a destination track before running the script","Please",0)
	end -- if selected track
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

--msg_start() -- Display characters in the console to show you the begining of the script execution.

reaper.PreventUIRefresh(1)
SaveView()
SaveLoopTimesel()

reaper.Main_OnCommand(40914, 0) -- Select first track as last touched
main() -- Execute your main function

RestoreView()
RestoreLoopTimesel()

reaper.UpdateArrange() -- Update the arrangement (often needed)

reaper.PreventUIRefresh(-1)

--msg_end() -- Display characters in the console to show you the end of the script execution.