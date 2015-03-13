--[[
 * ReaScript Name: Export selection as SRT subtitles with offset
 * Description: Export item's note selection (or on selected track) as offset by edit cursor time SRT subtitles
 * Instructions: Select at least one item or one track with items that you want to export. You can select items accross multiple tracks. Note that the initial cursor position is very important 
 * Authors: X-Raym
 * Author URl: http://extremraym.com
 * Version: 1.0
 * Repository: X-Raym/REAPER-ReaScripts
 * Repository URl: https://github.com/X-Raym/REAPER-ReaScripts
 * File URl: 
 * License: GPL v3
 * Forum Thread: Lua Script: Export/Import subtitles SubRip SRT format
 * Forum Thread URl: http://forum.cockos.com/showthread.php?p=1495841#post1495841
 * Version: 1.0
 * Version Date: 2015-03-13
 * REAPER: 5.0 pre 9
 * Extensions: None
]]

--[[
 * Change log:
 * v1.0 (2015-03-06), by X-Raym
 	+ Multitrack export support -> every selected track can would be exported
	+ Selected items on non selected track will also be exported
	+ If no track selected, selected items notes can be exported anyway
	+ Better track and item selection restoration
 * v0.5 (2015-03-05), by X-Raym
 	# default name is track name - thanks to spk77 for split at comma
 	# default folder is project folder
 	# if empty fields, back to default values
 * v0.4 (2015-03-05), by X-Raym
	# contextual os-based separator
	+ negative first (selected) item pos fix (consider first (selected) item start as time = 0 if cursor pos is after)
	+ no item selected => export all items on first selected track as subtitles
	+ item selected => export only selected items as subtitles
 * v0.3 (2015-03-04), by X-Raym
	+ default folder based on OS
	+ user area
 * v0.2 (2015-02-28)
	+ initial cursor position offset
 * v0.1 (2015-02-27)
	+ initial version

]]
------------------- USER AREA --------------------------------
if reaper.GetOS() == "Win32" or reaper.GetOS() == "Win64" then
	-- user_folder = buf --"C:\\Users\\[username]" -- need to be test
	separator = "\\"
else
	-- user_folder = "/USERS/[username]" -- Mac OS. Not tested on Linux.
	separator = "/"
end
--------------------------------------------- End of User Area

------------------- OPTIONS ----------------------------------
-- this script has no options


----------------------------------------------- End of Options



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


	function HeDaGetNote(item) 
		retval, s = reaper.GetSetItemState(item, "")	-- get the current item's chunk
		if retval then
			--dbug("\nChunk=" .. s .. "\n")
			note = s:match(".*<NOTES\n(.*)>\nIMGRESOURCEFLAGS.*");
			if note then note = string.gsub(note, "|", ""); end;	-- remove all the | characters
		end
		
		return note;
	end


	function selected_items_on_tracks(track) -- local (i, j, item, take, track)
	-- from X-Raym's Add all items on selected track into item selection
		item_num = reaper.CountTrackMediaItems(track)

		for j = 0, item_num-1 do
			item = reaper.GetTrackMediaItem(track, j)
			reaper.SetMediaItemSelected(item, 1)
		end
	end
	
	

	
----------------------------------------------------------------------


function tosrtformat(position)
	hour = math.floor(position/3600)
	minute = math.floor((position - 3600*math.floor(position/3600)) / 60)
	second = math.floor(position - 3600*math.floor(position/3600) - 60*math.floor((position-3600*math.floor(position/3600))/60))
	millisecond = math.floor(1000*(position-math.floor(position)) )
	
	return string.format("%02d:%02d:%02d,%03d", hour, minute, second, millisecond)
end

function export_txt(file)

	initialtime = reaper.GetCursorPosition()	-- store initial cursor position as time origin 00:00:00
	cursor_pos = initialtime

	local f = io.open(file, "w")
	io.output(file)

	first_item = reaper.GetSelectedMediaItem(0, 0)
	first_itemstart = reaper.GetMediaItemInfo_Value(first_item, "D_POSITION")
	loop_count = new_item_selection_count - 1
	
	if first_itemstart < initialtime then -- if first selected item start is before cursor
		initialtime = first_itemstart -- consider the first item start as pos O
	end

	for i=0, loop_count do
		
		item = reaper.GetSelectedMediaItem(0, i) -- loop through selected items

		--ref: number reaper.GetMediaItemInfo_Value(MediaItem item, string parmname)
		itemstart = reaper.GetMediaItemInfo_Value(item, "D_POSITION") - initialtime --get itemstart
		itemlength = reaper.GetMediaItemInfo_Value(item, "D_LENGTH") --get length
		itemend = itemstart + itemlength
		
		note = HeDaGetNote(item)  -- get the note text
		
		if note == nil then
			note = "" 
		end
		
		-- write item number 
		f:write(i+1 .. "\n")
		
		-- write start and end   00:04:22,670 --> 00:04:26,670
		str_start = tosrtformat(itemstart)
		str_end = tosrtformat(itemend)
		f:write(str_start .. " --> " ..  str_end .. "\n")

		-- write text
		f:write(note)

		-- write new line for next subtitle
		f:write("\n")
	end
	
	f:close() -- never forget to close the file
	
	reaper.Main_OnCommand(40029,0) -- Undo implode

	if no_selected_track == true then
		reaper.Main_OnCommand(40297,0)
	end
	
	--ref: reaper.SetEditCurPos(number time, boolean moveview, boolean seekplay)
	reaper.SetEditCurPos(cursor_pos, 1, 1) -- move cursor to original position before running script
	
	if initialtime > 0 then
		offsetmsg= "\n\nThe file has been exported with an offset time of " .. initialtime .." seconds, relative to cursor project time."
	else
		offsetmsg=""
	end
	
	if no_selected_track == false then
		reaper.ShowMessageBox("\"" .. track_label .. "\" track has been exported to: " .. file .. offsetmsg, "Information",0)
	else
		reaper.ShowMessageBox("Items have been exported to: " .. file .. offsetmsg, "Information",0)
	end
end




-- START -----------------------------------------------------
-- backup
reaper.PreventUIRefresh(-10) -- prevent refreshing
reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_SAVEALLSELITEMS1"), 0) -- Save current item selection
reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_SAVESEL"), 0) -- save track selection

-- the thing
selected_items_count = reaper.CountSelectedMediaItems(0)
selected_tracks_count = reaper.CountSelectedTracks(0)

if selected_tracks_count > 0 or selected_items_count > 0 then -- if there is a track selected or an item selected
	
	if selected_tracks_count > 0 then
		-- loop through all tracks
		for i = 0, selected_tracks_count-1 do
			track = reaper.GetSelectedTrack(0, i)
			selected_items_on_tracks(track)
		end -- end loop through all tracks
		track = reaper.GetSelectedTrack(0, 0)
	else
		item = reaper.GetSelectedMediaItem(0, 0)
		track = reaper.GetMediaItemTrack(item)
		no_selected_track = true
	end
	
	-- Move all selected items on a last temporary track
	--reaper.InsertTrackAtIndex(integer idx, boolean wantDefaults)
	reaper.Main_OnCommand(40914,0) -- Set first selected track as last touched track
	reaper.Main_OnCommand(40644,0) -- Implode selected items into one track

	new_item_selection_count = reaper.CountSelectedMediaItems(0) -- item selection count with all items to be export

	if new_item_selection_count > 0 then -- if there is something to export
		retval, track_label = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
		default_path = reaper.GetProjectPath("") -- default folder export is project path
		default_filename = track_label -- default file name is track name
		defaultvals_csv = default_path .."," .. default_filename --default values
		--ref: boolean retval, string retvals_csv reaper.GetUserInputs(string title, integer num_inputs, string captions_csv, string retvals_csv)
		retval, retvals_csv = reaper.GetUserInputs("Where to save the file?", 2, "Enter full path of the folder:, File Name", defaultvals_csv) 
			
		if retval then -- if user complete the fields
			--if track_label == "" then track_label="Exported subtitles" end
			path, filename = retvals_csv:match("([^,]+),([^,]+)")
			if filename == "" then filename = default_filename end
			if path == "" then path = default_path end
			filenamefull = path .. separator .. filename .. ".srt" -- contextual separator based on user inputs and regex can be nice	
			
			export_txt(filenamefull) -- export the file

		else -- user cancelled the dialog box
			--ref: Lua: integer reaper.ShowMessageBox(string msg, string title, integer type)
			-- type 0=OK,1=OKCANCEL,2=ABORTRETRYIGNORE,3=YESNOCANCEL,4=YESNO,5=RETRYCANCEL : ret 1=OK,2=CANCEL,3=ABORT,4=RETRY,5=IGNORE,6=YES,7=NO
			reaper.ShowMessageBox("Cancelled and nothing was exported","Don't worry",0)
		end -- enf if user completed the dialog box

	else -- if there is no item to export

		reaper.ShowMessageBox("No items to export", "Information",0)
	
	end -- if there is item to export

else -- there is no selected track

	reaper.ShowMessageBox("Select at least one track or one item","Please",0)

end -- end if there is selected track

-- restoration
reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_RESTALLSELITEMS1"), 0)  -- Restore previous item selection
reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_RESTORESEL"), 0) -- Restore track selection
reaper.PreventUIRefresh(10) -- can refresh again