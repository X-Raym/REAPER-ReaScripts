--[[
 * ReaScript Name: Create text items on first selected track from selected takes name
 * Description: X-Raym_Create text items on first selected track from selected takes name.lua
 * Instructions:  Select items. Select a destination track. Execute the script. Text items will be colored depending on original take color, or track color from item if no take color is set. The text note will came from the original take name.
 * Author: X-Raym
 * Author URl: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URl: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URl: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script: Scripts (LUA): Create Text Items Actions (various)
 * Forum Thread URl: http://forum.cockos.com/showthread.php?t=156763
 * Version: 1.1.2
 * Version Date: 2015-03-11
 * REAPER: 5.0 pre 15
 * Extensions: SWS/S&M 2.6.2
 --]]
 
--[[
 * Changelog:
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

--[[dbug_flag = 0 -- set to 0 for no debugging messages, 1 to get them
function dbug (text) 
	if dbug_flag==1 then  
		if text then
			reaper.ShowConsoleMsg(text .. '\n')
		else
			reaper.ShowConsoleMsg("nil")
		end
	end
end]]

function CreateTextItem(starttime, endtime, notetext, color) 
	--ref: Lua: number startOut retval, number endOut reaper.GetSet_LoopTimeRange(boolean isSet, boolean isLoop, number startOut, number endOut, boolean allowautoseek)
	reaper.GetSet_LoopTimeRange(1,0,starttime,endtime,0) -- define the time range for the empty item
	--ref: Lua: reaper.Main_OnCommand(integer command, integer flag)
	reaper.Main_OnCommand(40142,0) -- insert empty item
	--ref: Lua: MediaItem reaper.GetSelectedMediaItem(ReaProject proj, integer selitem)
	item = reaper.GetSelectedMediaItem(0,0) -- get the selected item
	reaper.SetMediaItemInfo_Value(item, "I_CUSTOMCOLOR", color)

	HeDaSetNote(item, "|" .. notetext) -- set the note add | character to the beginning of each line. only 1 line for now.
	reaper.SetEditCurPos(endtime, 1, 0) -- moves cursor for next item
end

function rtrim(s)
	local n = #s
	while n > 0 and s:find("^|", n) do n = n - 1 end
	return s:sub(1, n)
end

function string.ends(String,End)
	return End=='' or string.sub(String,-string.len(End))==End
end

function HeDaSetNote(item,newnote)  -- HeDa - SetNote v1.0
	-- X-Raym: prevent multiple lines note break and trim any trailing last empty line
	newnote = newnote:gsub("\n", "\n|")
	last_char = string.sub(newnote, -1)
	if last_char == "|" then
		newnote = rtrim(newnote)
	end
	
	--ref: Lua: boolean retval, string str reaper.GetSetItemState(MediaItem item, string str)
	retval, s = reaper.GetSetItemState(item, "")	-- get the current item's chunk
	--dbug("\nChunk=" .. s .. "\n")
	has_notes = s:find("<NOTES")  -- has notes?
	if has_notes then
		-- there are notes already
		chunk, note, chunk2 = s:match("(.*<NOTES\n)(.*)(\n>\nIMGRESOURCEFLAGS.*)")
		newchunk = chunk .. newnote .. chunk2
		--dbug(newchunk .. "\n")
		
	else
		--there are still no notes
		chunk,chunk2 = s:match("(.*IID%s%d+)(.*)")
		newchunk = chunk .. "\n<NOTES\n" .. newnote .. "\n>\nIMGRESOURCEFLAGS 0" .. chunk2
		--dbug(newchunk .. "\n")
	end
	reaper.GetSetItemState(item, newchunk)	-- set the new chunk with the note
end

-- <==== From Heda's HeDa_SRT to text items.lua

-- TABLE INIT
local setSelectedMediaItem = {}

-- MAIN
function main()

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	selected_tracks_count = reaper.CountSelectedTracks(0)

	if selected_tracks_count > 0 then

		-- DEFINE TRACK DESTINATION
		selected_track = reaper.GetSelectedTrack(0,0)

		-- COUNT SELECTED ITEMS
		selected_items_count = reaper.CountSelectedMediaItems(0)

		if selected_items_count > 0 then

			-- SAVE TAKES SELECTION
			for j = 0, selected_items_count-1  do
				setSelectedMediaItem[j] = reaper.GetSelectedMediaItem(0, j)
			end

			-- LOOP THROUGH TAKE SELECTION
			for i = 0, selected_items_count-1  do
				-- GET ITEMS AND TAKES AND PARENT TRACK
				item = setSelectedMediaItem[i] -- Get selected item i
				track = reaper.GetMediaItem_Track(item)
				
				-- GET INFOS
				item_color = reaper.GetDisplayedMediaItemColor(item)
					
				-- TIMES
				item_start = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
				item_duration = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
				item_end = item_start + item_duration

				take = reaper.GetActiveTake(item)
				
				-- NAME
				take = reaper.GetActiveTake(item) -- Get the active take !! BUG WITH EMPTY ITEM SELECTED
				if take ~= nil then
					text = reaper.GetTakeName(take)
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

--msg_start() -- Display characters in the console to show you the begining of the script execution.
reaper.PreventUIRefresh(1)
reaper.Main_OnCommand(reaper.NamedCommandLookup("_WOL_SAVEVIEWS5"), 0)
reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_SAVELOOP5"), 0)

reaper.Main_OnCommand(40914, 0) -- Select first track as last touched
main() -- Execute your main function


reaper.Main_OnCommand(reaper.NamedCommandLookup("_WOL_RESTOREVIEWS5"), 0)
reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_RESTLOOP5"), 0)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange() -- Update the arrangement (often needed)

--msg_end() -- Display characters in the console to show you the end of the script execution.