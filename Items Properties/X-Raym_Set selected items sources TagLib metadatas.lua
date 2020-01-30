--[[
 * ReaScript Name: Set selected items sources TagLib metadatas
 * Description: Select Items. Run. DOn't forget to unselect the source items in media explorer.'
 * Instructions: Don't use ",". Two commands /del and /keep and /name and /notes. Note that if selected share same sources, the last item of the selection will erase the metadatas written for the other. COnsider Glueing items idependently (cf Breeder Advanced Glue scripts).
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script: Scripts: TagLib (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1534071
 * REAPER: 5.0 pre 15
 * Extensions: SWS
 * Version: 1.1
--]]
 
--[[
 * Changelog:
 * v1.1 (2020-01-30)
	+ track number support
 * v1.0 (2015-06-13)
	+ Initial Release
--]]

function msg(var)
	reaper.ShowConsoleMsg(tostring(var).."\n")
end

function main(number) -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
	
	reaper.Main_OnCommand(40100, 0) -- set all media offline
	
	output_csv = output_csv:gsub(", ", "Ĥ¤")
	
	-- PARSE THE STRING
	tag_title, tag_artist, tag_album, tag_year, tag_genre, tag_comment, tag_number = output_csv:match("([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)")
	
	if tag_title ~= nil then tag_title = tag_title:gsub("Ĥ¤", ", ") end
	if tag_artist ~= nil then tag_artist = tag_artist:gsub("Ĥ¤", ", ") end
	if tag_album ~= nil then tag_album = tag_album:gsub("Ĥ¤", ", ") end
	if tag_year ~= nil then tag_year = tag_year:gsub("Ĥ¤", ", ") end
	if tag_genre ~= nil then tag_genre = tag_genre:gsub("Ĥ¤", ", ") end
	if tag_comment ~= nil then tag_comment = tag_comment:gsub("Ĥ¤", ", ") end
	if tag_number ~= nil then tag_number = tag_number:gsub("Ĥ¤", ", ") end

	for i = 0, sel_items_count-1  do
		
		item = reaper.GetSelectedMediaItem(0, i)
	
		take = reaper.GetActiveTake(item)
    
		if take ~= nil and reaper.TakeIsMIDI(take) == false then

			src = reaper.GetMediaItemTake_Source(take)
			fn = reaper.GetMediaSourceFileName(src, "")
			
			retval, take_name = reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", "", false)
			
			notes = reaper.ULT_GetMediaItemNote(item)
			
			if tag_title == "/del" then tag_title = "" end
			if tag_artist == "/del" then tag_artist = "" end
			if tag_album == "/del" then tag_album = "" end
			if tag_year == "/del" then tag_year = "" end
			if tag_genre == "/del" then tag_genre = "" end
			if tag_comment == "/del" then tag_comment = "" end
			if tag_number == "/del" then tag_number = "" end
			
			if tag_title == "/notes" then tag_title = item_notes end
			if tag_artist == "/notes" then tag_artist = item_notes end
			if tag_album == "/notes" then tag_album = item_notes end
			if tag_year == "/notes" then tag_year = item_notes end
			if tag_genre == "/notes" then tag_genre = item_notes end
			if tag_comment == "/notes" then tag_comment = item_notes end
			
			if tag_title == "/name" then tag_title = take_name end
			if tag_artist == "/name" then tag_artist = take_name end
			if tag_album == "/name" then tag_album = take_name end
			if tag_year == "/name" then tag_year = take_name end
			if tag_genre == "/name" then tag_genre = take_name end
			if tag_comment == "/name" then tag_comment = take_name end
			
			if tag_title == nil or tag_title == "/keep" then retval_title, tag_title = reaper.SNM_ReadMediaFileTag(fn, "title", "") end
			if tag_artist == nil or tag_artist == "/keep" then retval_artist, tag_artist = reaper.SNM_ReadMediaFileTag(fn, "artist", "") end
			if tag_album == nil or tag_album == "/keep" then retval_album, tag_album = reaper.SNM_ReadMediaFileTag(fn, "album", "") end
			if tag_year == nil or tag_year == "/keep" then retval_year, tag_year = reaper.SNM_ReadMediaFileTag(fn, "year", "") end
			if tag_genre == nil or tag_genre == "/keep" then retval_genre, tag_genre = reaper.SNM_ReadMediaFileTag(fn, "genre", "") end
			if tag_comment == nil or tag_comment == "/keep" then retval_comment, tag_comment = reaper.SNM_ReadMediaFileTag(fn, "comment", "") end
			if tag_number == nil or tag_number == "/keep" then retval_number, tag_number = reaper.SNM_ReadMediaFileTag(fn, "track", "") end
			
			--SET INFOS
			reaper.Main_OnCommand(40440, 0) -- set offline
			reaper.SNM_TagMediaFile(fn, "title", tag_title)
			reaper.SNM_TagMediaFile(fn, "artist", tag_artist)
			reaper.SNM_TagMediaFile(fn, "album", tag_album)
			reaper.SNM_TagMediaFile(fn, "year", tag_year)
			reaper.SNM_TagMediaFile(fn, "year", tag_year)
			reaper.SNM_TagMediaFile(fn, "genre", tag_genre)
			reaper.SNM_TagMediaFile(fn, "comment", tag_comment)
			reaper.SNM_TagMediaFile(fn, "track", tag_number)
			reaper.Main_OnCommand(40439, 0) -- set online
			reaper.Main_OnCommand(40441, 0) -- rebuild peak
			
		end
		
	end -- ENDLOOP through selected tracks
	
	reaper.Main_OnCommand(40101, 0)-- sel all items online

	reaper.Undo_EndBlock("Set selected items sources TagLib metadatas", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

sel_items_count = reaper.CountSelectedMediaItems(0)

if sel_items_count > 0 then
	
	retval, output_csv = reaper.GetUserInputs("Set TagLib Metadatas", 7, "Title: (/del for deletion),Artist: (/name for take name),Album: (/notes for item notes),Year: (/keep for keeping original),Genre:,Comment:,Number:", "/keep,/keep,/keep,/keep,/keep,/keep,/keep") 

	if retval and output ~= "" then

		reaper.PreventUIRefresh(1)

		main(output_csv) -- Execute your main function

		reaper.UpdateArrange() -- Update the arrangement (often needed)

		reaper.PreventUIRefresh(-1)
		
		reaper.UpdateArrange() -- Update the arrangement (often needed)
		
	end
	
end
