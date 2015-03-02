--[[
 * ReaScript Name: X-Raym_Create one text item with dialog dash from selected items notes
 * Description: This was created as a "glue empty items concatenating their notes and adding dialog dash", but this version works with a destination track, all kind of items, and preserve original selection
 * Instructions: Select a destination track. Select items. Execute. You can use it in Custom Action with the Delete selected items action.
 * Author: X-Raym
 * Author URl: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URl: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URl: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script: Script name
 * Forum Thread URl: http://forum.cockos.com/***.html
 * Version: 1.0
 * Version Date: 2015-03-02
 * REAPER: 5.0 pre 15
 * Extensions: SWS/S&M 2.6.0 (optional)
 --]]
 
--[[
 * Changelog:
 * v1.0 (2015-03-02)
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

function CreateTextItem(starttime, endtime, notetext) 
	--ref: Lua: number startOut retval, number endOut reaper.GetSet_LoopTimeRange(boolean isSet, boolean isLoop, number startOut, number endOut, boolean allowautoseek)
	reaper.GetSet_LoopTimeRange(1,0,starttime,endtime,0) -- define the time range for the empty item
	--ref: Lua: reaper.Main_OnCommand(integer command, integer flag)
	reaper.Main_OnCommand(40142,0) -- insert empty item
	--ref: Lua: MediaItem reaper.GetSelectedMediaItem(ReaProject proj, integer selitem)
	item = reaper.GetSelectedMediaItem(0,0) -- get the selected item

	HeDaSetNote(item, "|" .. notetext) -- set the note add | character to the beginning of each line. only 1 line for now.
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

function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	text_output = ""
	
	--selected_tracks_count = reaper.CountSelectedTracks(0)

	--for i = 0, selected_tracks_count-1  do

		--track = reaper.GetSelectedTrack(0, i)

		-- THE THING
		selected_items_count = reaper.CountSelectedMediaItems(0) -- Get selected item on track
		
		first_item = reaper.GetSelectedMediaItem(0, 0)
		first_item_start = reaper.GetMediaItemInfo_Value(first_item, "D_POSITION")
		
		last_item = reaper.GetSelectedMediaItem(0, selected_items_count-1)
		last_item_duration = reaper.GetMediaItemInfo_Value(last_item, "D_LENGTH")
		last_item_start = reaper.GetMediaItemInfo_Value(last_item, "D_POSITION")
		last_item_end = last_item_start + last_item_duration

		-- LOOP THROUGH SELECTED ITEMS
		for i = 0, selected_items_count-1  do
			-- GET ITEMS
			loop_item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i
			loop_item_track = reaper.GetMediaItem_Track(loop_item)

			text_item = reaper.ULT_GetMediaItemNote(loop_item)
			if i == 0 then
				text_output = "— " .. text_item
			else
				text_output = text_output .. "\n|— " .. text_item
			end
				
		end -- ENDLOOP through selected items
		msg_stl("text_output", text_output, 1)

		--reaper.Main_OnCommand(40697, 0) -- DELETE all selected items

		CreateTextItem(first_item_start, last_item_end, text_output)

	--end
	reaper.Undo_EndBlock("Glue selected text items preserving notes", 0) -- End of the undo block. Leave it at the bottom of your main function.

end

msg_start() -- Display characters in the console to show you the begining of the script execution.

reaper.PreventUIRefresh(1)
reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_SAVELOOP5"), 0)
reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_SAVESELITEMS5"), 0)


main() -- Execute your main function

reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_RESTLOOP5"), 0)
reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_RESTSELITEMS5"), 0)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange() -- Update the arrangement (often needed)

msg_end() -- Display characters in the console to show you the end of the script execution.

--[[
IDEAS
 * Make it per track (loop through selected item on track and glue on tracks)
 * Make it works with track name if take is not a empty item
]]