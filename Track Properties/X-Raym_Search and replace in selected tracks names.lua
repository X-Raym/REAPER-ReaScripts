--[[
 * ReaScript Name: Search and replace in selected tracks names
 * Description: Search and replace in selected tracks names
 * Instructions: Select tracks. Run.
 * Screenshot: http://i.giphy.com/3o85xuFcHQ27K06TdK.gif
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Scripts: Tracks Names (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=167300
 * REAPER: 5.0
 * Extensions: SWS/S&M 2.8.1
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2015-10-08)
  + Initial Release
 --]]

function main() -- local (i, j, item, take, track)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  
  -- INITIALIZE loop through selected items
  for i = 0, sel_tracks_count-1  do
    -- GET ITEMS
    track = reaper.GetSelectedTrack(0, i) -- Get selected item i

    -- GET NAMES
    retval, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)

    -- MODIFY NAMES
    track_name = track_name:gsub(search, replace)
	
	truncate_start = tonumber(truncate_start)
	truncate_end = tonumber(truncate_end)
	if truncate_start > 0 and truncate_start ~= nil then track_name = track_name:sub(truncate_start+1) end
	if truncate_end > 0 and truncate_end ~= nil then
		track_name_len = track_name:len()
		track_name = track_name:sub(0, track_name_len-truncate_end)
	end
	ins_start = ins_start_in:gsub("/E", tostring(i + 1))
	ins_end = ins_end_in:gsub("/E", tostring(i + 1))

    -- SETNAMES
    reaper.GetSetMediaTrackInfo_String(track, "P_NAME", ins_start..track_name..ins_end, true)

  end -- ENDLOOP through selected items
  
  reaper.Undo_EndBlock("Search and replace in selected tracks names", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

-- START
sel_tracks_count = reaper.CountSelectedTracks(0)

if sel_tracks_count > 0 then

	defaultvals_csv = "0,0,0,0,/no,/no"

	retval, retvals_csv = reaper.GetUserInputs("Search & Replace", 6, "Search (% for escape char),Replace (/del for deletion),Truncate from start,Truncate from end,Insert at start (/E for Sel Num),Insert at end", defaultvals_csv) 
		  
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
