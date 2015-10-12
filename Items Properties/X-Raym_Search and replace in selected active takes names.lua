--[[
 * ReaScript Name: Search and replace in selected active takes names
 * Description: Search and replace in selected items names
 * Instructions: Select items. Run.
 * Screenshot: http://i.giphy.com/3oEdv3tKb0CpB7VCtq.gif
 * Author: X-Raym
 * Author URl: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URl: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URl: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Properties (various)
 * Forum Thread URl: http://forum.cockos.com/showthread.php?p=1574814#post1574814
 * REAPER: 5.0
 * Extensions: SWS/S&M 2.8.1
 --]]
 
--[[
 * Changelog:
 * v1.0 (2015-10-08)
  + Initial Release
 --]]

function main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  
  -- INITIALIZE loop through selected items
  for i = 0, sel_items_count-1  do
    -- GET ITEMS
    item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i
	
	take = reaper.GetActiveTake(item)
	
	if take ~= nil then

		-- GET NAMES
		take_name = reaper.GetTakeName(take)
		track = reaper.GetMediaItem_Track(item)
		retval, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
		

		-- MODIFY NAMES
		replace = replace:gsub("/T", track_name)
		take_name = take_name:gsub(search, replace)
		
		truncate_start = tonumber(truncate_start)
		truncate_end = tonumber(truncate_end)
		if truncate_start > 0 and truncate_start ~= nil then take_name = take_name:sub(truncate_start+1) end
		if truncate_end > 0 and truncate_end ~= nil then
			take_name_len = take_name:len()
			take_name = take_name:sub(0, take_name_len-truncate_end)
		end
		ins_start = ins_start_in:gsub("/E", tostring(i + 1))
		ins_end = ins_end_in:gsub("/E", tostring(i + 1))
		ins_start = ins_start_in:gsub("/T", track_name)
		ins_end = ins_end_in:gsub("/T", track_name)
		

		-- SETNAMES
		reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", ins_start..take_name..ins_end, true)
		
		end

  end -- ENDLOOP through selected items
  
  reaper.Undo_EndBlock("Search and replace in selected active takes names", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

-- START
sel_items_count = reaper.CountSelectedMediaItems(0)

if sel_items_count > 0 then

	defaultvals_csv = "0,0,0,0,/no,/no"

	retval, retvals_csv = reaper.GetUserInputs("Search & Replace", 6, "Search (% for escape char),Replace (/del for deletion),Truncate from start,Truncate from end,Insert at start (/E = Sel Num),Insert at end (/T = track name)", defaultvals_csv) 
		  
	if retval then -- if user complete the fields
	  
	  search, replace, truncate_start, truncate_end, ins_start_in, ins_end_in = retvals_csv:match("([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)")
	  
	  if replace == "/del" then replace = "" end
	  if ins_start_in == "/no" then ins_start_in = "" end
	  if ins_end_in == "/no" then ins_end_in = "" end

	  if search ~= nil then
		
		reaper.PreventUIRefresh(1)

		main() -- Execute your main function

		reaper.PreventUIRefresh(-1)

		reaper.UpdateArrange() -- Update the arrangement (often needed)
	  end

	end
	
end
