--[[
 * ReaScript Name: Add all items on selected track into item selection
 * Description: Add all items on selected track into item selection
 * Instructions: Select tracks. Use it.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: ReaScript: Select all items on selected tracks
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1489411
 * Version: 1.0
 * Version Date: 2015-02-27
 * REAPER: 5.0 pre 11
 * Extensions: None
--]]
 
--[[
 * Changelog:
 * v1.1 (2015-03-05)
	+ Rename
 * v1.0 (2015-02-27)
	+ Initial Release
--]]

-- ----- DEBUGGING ====>
--[[function get_script_path()
  if reaper.GetOS() == "Win32" or reaper.GetOS() == "Win64" then
    return debug.getinfo(1,'S').source:match("(.*".."\\"..")"):sub(2) -- remove "@"
  end
    return debug.getinfo(1,'S').source:match("(.*".."/"..")"):sub(2)
end

package.path = package.path .. ";" .. get_script_path() .. "?.lua"
require("X-Raym_Functions - console debug messages")

debug = 1 -- 0 => No console. 1 => Display console messages for debugging.
clean = 1 -- 0 => No console cleaning before every script execution. 1 => Console cleaning before every script execution.

msg_clean()]]
-- <==== DEBUGGING -----

function selected_items_on_tracks() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	-- LOOP TRHOUGH SELECTED TRACKS
	
	selected_tracks_count = reaper.CountSelectedTracks(0)

	for i = 0, selected_tracks_count-1  do
		-- GET THE TRACK
		track_sel = reaper.GetSelectedTrack(0, i) -- Get selected track i

		item_num = reaper.CountTrackMediaItems(track_sel)

		-- ACTIONS
		for j = 0, item_num-1 do
			item = reaper.GetTrackMediaItem(track_sel, j)
			reaper.SetMediaItemSelected(item, 1)
		end

	end -- ENDLOOP through selected tracks
	

	reaper.Undo_EndBlock("Select all items on selected tracks", 0) -- End of the undo block. Leave it at the bottom of your main function.

end

--msg_start() -- Display characters in the console to show you the begining of the script execution.

selected_items_on_tracks() -- Execute your main function

reaper.UpdateArrange() -- Update the arrangement (often needed)

--msg_end() -- Display characters in the console to show you the end of the script execution.
