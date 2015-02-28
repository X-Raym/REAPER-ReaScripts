--[[
 * ReaScript Name: Create text items on selected track from selected takes
 * Description: Create text items on selected track from selected takes
 * Instructions:  Select items. Select a destination track. Execute the script. Text items will be colored depending on original take color, or track color from item if no take color is set. The text note will came from the original take name.
 * Author: X-Raym
 * Author URl: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URl: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URl: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script: Script name
 * Forum Thread URl: http://forum.cockos.com/***.html
 * Version: 0.9
 * Version Date: 2015-02-28
 * REAPER: 5.0 pre 15
 * Extensions: SWS/S&M 2.6.0 (optional)
 --]]
 
--[[
 * Changelog:
 * v1.0 (2015-02-28)
	+ Initial Release
 --]]

-- ----- DEBUGGING ====>
function get_script_path()
  if reaper.GetOS() == "Win32" or reaper.GetOS() == "Win64" then
    return debug.getinfo(1,'S').source:match("(.*".."\\"..")"):sub(2) -- remove "@"
  end
    return debug.getinfo(1,'S').source:match("(.*".."/"..")"):sub(2)
end

package.path = package.path .. ";" .. get_script_path() .. "?.lua"
require("X-Raym_Functions - console debug messages")

debug = 1 -- 0 => No console. 1 => Display console messages for debugging.
clean = 1 -- 0 => No console cleaning before every script execution. 1 => Console cleaning before every script execution.

msg_clean()
-- <==== DEBUGGING -----

-- From Heda's HeDa_SRT to text items.lua ====>

dbug_flag = 0 -- set to 0 for no debugging messages, 1 to get them
function dbug (text) 
	if dbug_flag==1 then  
		if text then
			reaper.ShowConsoleMsg(text .. '\n')
		else
			reaper.ShowConsoleMsg("nil")
		end
	end
end

function CreateTextItem(starttime, endtime, notetext, color) 
	--ref: Lua: number startOut retval, number endOut reaper.GetSet_LoopTimeRange(boolean isSet, boolean isLoop, number startOut, number endOut, boolean allowautoseek)
	reaper.GetSet_LoopTimeRange(1,0,starttime,endtime,0) -- define the time range for the empty item
	--ref: Lua: reaper.Main_OnCommand(integer command, integer flag)
	reaper.Main_OnCommand(40142,0) -- insert empty item
	--ref: Lua: MediaItem reaper.GetSelectedMediaItem(ReaProject proj, integer selitem)
	item = reaper.GetSelectedMediaItem(0,0) -- get the selected item
	reaper.SetMediaItemInfo_Value(item, "I_CUSTOMCOLOR", color)
	reaper.GetMediaItemTakeInfo_Value(take, "I_CUSTOMCOLOR", color)

	HeDaSetNote(item, notetext) -- set the note add | character to the beginning of each line. only 1 line for now.
	reaper.SetEditCurPos(endtime, 1, 0) -- moves cursor for next item
end

function HeDaSetNote(item,newnote)  -- HeDa - SetNote v1.0
	--ref: Lua: boolean retval, string str reaper.GetSetItemState(MediaItem item, string str)
	retval, s = reaper.GetSetItemState(item, "")	-- get the current item's chunk
	--dbug("\nChunk=" .. s .. "\n")
	has_notes = s:find("<NOTES")  -- has notes?
	if has_notes then
		-- there are notes already
		chunk, note, chunk2 = s:match("(.*<NOTES\n)(.*)(\n>\nIMGRESOURCEFLAGS.*)")
		newchunk = chunk .. newnote .. chunk2
		dbug(newchunk .. "\n")
		
	else
		--there are still no notes
		chunk,chunk2 = s:match("(.*IID%s%d+)(.*)")
		newchunk = chunk .. "\n<NOTES\n" .. newnote .. "\n>\nIMGRESOURCEFLAGS 0" .. chunk2
		dbug(newchunk .. "\n")
	end
	reaper.GetSetItemState(item, newchunk)	-- set the new chunk with the note
end

-- <==== From Heda's HeDa_SRT to text items.lua

-- TABLE INIT
local setSelectedMediaItem = {}

-- MAIN
function main()

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	selected_track = reaper.GetSelectedTrack(0,0)

	-- COUNT SELECTED ITEMS
	selected_items_count = reaper.CountSelectedMediaItems(0)

	-- SAVE TAKES SELECTION
	for j = 0, selected_items_count-1  do
		setSelectedMediaItem[j] = reaper.GetSelectedMediaItem(0, j)
	end

	-- LOOP THROUGH TAKE SELECTION
	for i = 0, selected_items_count-1  do
		-- GET ITEMS AND TAKES AND PARENT TRACK
		item = setSelectedMediaItem[i] -- Get selected item i
		take = reaper.GetActiveTake(item) -- Get the active take
		track = reaper.GetMediaItemTake_Track(take)
		
		-- GET INFOS

		-- NAME
		take_name = reaper.GetTakeName(take)
		
		-- COLOR
		take_color = reaper.GetMediaItemTakeInfo_Value(take, "I_CUSTOMCOLOR")
		if take_color == 0 then -- if the item has no color...
			take_color = reaper.GetTrackColor(track) -- ... then take the track color
		end
			
		-- TIMES
		item_start = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
		item_duration = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
		item_end = item_start + item_duration

		-- DEBUG
		msg_s("itemName")
		msg_s(take_name)
		msg_s("item_start")
		msg_f(item_start)
		msg_s("item_end")
		msg_f(item_end)

		-- ACTION
		CreateTextItem(item_start, item_end, take_name, take_color)

	end -- ENDLOOP through selected items

	reaper.Undo_EndBlock("Create text items on selected track from selected takes", 0) -- End of the undo block. Leave it at the bottom of your main function.

end

msg_start() -- Display characters in the console to show you the begining of the script execution.

--reaper.Main_OnCommand(NamedCommandLookup("_WOL_SAVEVIEWS5"), 0)
--reaper.Main_OnCommand(NamedCommandLookup("_SWS_RESTLOOP5"), 0)
reaper.PreventUIRefresh(1)

main() -- Execute your main function

reaper.PreventUIRefresh(-1)
--reaper.Main_OnCommand(NamedCommandLookup("_WOL_RESTOREVIEWS5"), 0)
--reaper.Main_OnCommand(NamedCommandLookup("_SWS_RESTLOOP5"), 0)

reaper.UpdateArrange() -- Update the arrangement (often needed)

msg_end() -- Display characters in the console to show you the end of the script execution.

--[[
TO DO:
1. color text item
3. text from take name
4. if no item selected
5. if no track selected
]]