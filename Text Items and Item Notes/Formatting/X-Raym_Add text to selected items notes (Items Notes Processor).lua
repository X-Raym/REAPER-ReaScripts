--[[
 * ReaScript Name: Add text to selected items notes (Items Notes Processor)
 * Description: Equivalent to SWS label processor, but for items notes
 * Instructions: Select items. Run. See below for customization and wildcards references.
 * Screenshot: http://i.giphy.com/l41lPYdijt9494V5S.gif
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Scripts (LUA): Text Items Formatting Actions (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=156757
 * REAPER: 5.0
 * Extensions: SWS/S&M 2.8.1
 * Version: 1.1
--]]
 
--[[
 * Changelog:
 * v1.1 (2015-10-07)
	+ Replace
	+ User config area
	+ Shortcut (B for Before, A for After, R for Replace)
	# bug fixes
 * v1.0 (2015-05-06)
	+ Initial Release
 --]]

--[[ ------ TEXT WILDCARDS REFERENCES ---------------------
/E -- enumerate in selection
/I -- inverse enumerate in selection
/T -- Track name
/t -- Track number
--]] -----------------------------------------------------
 
 
-- ------ USER CONFIG AREA -----------------------------
default_action = "After" -- "Before", "After", "Replace"
default_text = "" -- "Text"
--------------------------------------------------------
 
 
function main(csv) -- local (i, j, item, take, track)
	
	csv = csv:gsub(", ", "¤¤¤")
	
	-- PARSE THE STRING
	before_after, text = csv:match("([^,]+),([^,]+)")
	
	if text ~= nil then
	
		text = text:gsub("¤¤¤", ", ")
		
		if (before_after == "Before" or before_after == "After" or before_after == "Replace" or before_after == "b" or before_after == "a" or before_after == "r" or before_after == "before" or before_after == "after" or before_after == "replace") and text ~= nil then
		
			reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the 
		
			-- INITIALIZE loop through selected items
			for i = 0, selected_items_count-1  do
				-- GET ITEMS
				item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i
				
				track = reaper.GetMediaItemTrack(item)
				track_id = reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
				track_name_retval, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
				
				-- /D -- Duration
				-- /E[digits, first] -- enumerate in selection
				-- /e[digits, first] -- enumerate in selection on track
				-- /I[digits, first] -- inverse enumerate in selection
				-- /i[digits, first] -- inverse enumerate in selection on track
				-- /T[offset, length] -- Track name
				-- /t[digits] -- Track number
				input = text:gsub("/E", tostring(i + 1))
				input = input:gsub("/I", tostring(selected_items_count - i))
				input = input:gsub("/T", track_name)
				input = input:gsub("/t", tostring(track_id))
				
				notes = reaper.ULT_GetMediaItemNote(item)
				
				if notes == nil or notes == "" then
					reaper.ULT_SetMediaItemNote(item, text)
				else
					
					if before_after == "Before" or before_after == "before" or before_after == "b"then -- before
						notes = input .. "\n" .. notes
						reaper.ULT_SetMediaItemNote(item, notes)
					end
					
					if before_after == "After" or before_after == "after" or before_after == "a"then -- after
						notes = notes .. "\n" .. input
						reaper.ULT_SetMediaItemNote(item, notes)
					end
					
					if before_after == "Replace" or before_after == "replace" or before_after == "r" then -- after
						notes = input
						reaper.ULT_SetMediaItemNote(item, notes)
					end
					
				end
			
			end -- end of items loop
		
		reaper.Undo_EndBlock("Add text to selected items notes (Items Notes Processor)", -1) -- End of the undo block. Leave it at the bottom of your main function.
		
		end -- end of it there is before after
	
	end -- end of if there is text

end -- end of function

reaper.PreventUIRefresh(1)

selected_items_count = reaper.CountSelectedMediaItems(0)

if selected_items_count > 0 then
	
	default_csv = default_action .. "," .. default_text
	
	retval, output_csv = reaper.GetUserInputs("Item Notes Processor", 2, "Before/After/Replace:,Text:", default_csv) 

	if retval then
	
		main(output_csv) -- Execute your main function
	
	end

end
reaper.PreventUIRefresh(-1)

reaper.UpdateArrange() -- Update the arrangement (often needed)