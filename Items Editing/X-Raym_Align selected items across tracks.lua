--[[
 * ReaScript Name: Align selected items across tracks
 * Description: A way to align items across tracks, with their snap offset. Useful for layering in sound design.
 * Instructions Select two items minimum on two different tracks minimum. Run. Items that don't have pairs will not be moved.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script (Lua): Shuffle Items
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=159961
 * REAPER: 5.0 pre 15
 * Extensions: SWS/S&M 2.7.1
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2015-05-19)
	+ Initial Release
 --]]

-- ----- DEBUGGING ====>
--[[
local info = debug.getinfo(1,'S');

local full_script_path = info.source

local script_path = full_script_path:sub(2,-5) -- remove "@" and "file extension" from file name

if reaper.GetOS() == "Win64" or reaper.GetOS() == "Win32" then
  package.path = package.path .. ";" .. script_path:match("(.*".."\\"..")") .. "..\\Functions\\?.lua"
else
  package.path = package.path .. ";" .. script_path:match("(.*".."/"..")") .. "../Functions/?.lua"
end

require("X-Raym_Functions - console debug messages")


debug = 1 -- 0 => No console. 1 => Display console messages for debugging.
clean = 1 -- 0 => No console cleaning before every script execution. 1 => Console cleaning before every script execution.

msg_clean()
]]
-- <==== DEBUGGING -----

function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
	
	reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_SELTRKWITEM"), 0) -- Select only track with selected items
	
	selected_tracks = reaper.CountSelectedTracks(0)
	
	if selected_tracks >= 2 then
		
		-- Get the first selected track and save item selected
		first_sel_track = reaper.GetSelectedTrack(0, 0)
		first_snap_abs = {}
		
		for i = 0, reaper.CountTrackMediaItems(first_sel_track)-1 do
		
			item = reaper.GetTrackMediaItem(first_sel_track, i)
			
			if reaper.IsMediaItemSelected(item) == true then
				
				snap_abs = reaper.GetMediaItemInfo_Value(item, "D_POSITION") + reaper.GetMediaItemInfo_Value(item, "D_SNAPOFFSET")
				table.insert(first_snap_abs, snap_abs)
			
			end -- end if item on first track is selected
		
		end -- loop through item on first track
		
		-- LOOP ON SELECTED TRACKS +1
		for i = 1, selected_tracks - 1 do
			
			track = reaper.GetSelectedTrack(0, i)
			sel_items = {} -- init table of selected items on track
			
			for j = 0, reaper.CountTrackMediaItems(track)-1 do
		
				item = reaper.GetTrackMediaItem(track, j)
			
				if reaper.IsMediaItemSelected(item) == true then
					
					table.insert(sel_items, item)
			
				end -- end if item on first track is selected
		
			end -- loop through item on first track
			
			-- LOOP THROUGH SAVE ITEMS ON TRACKS
			for k = 1, #first_snap_abs do
				
				item = sel_items[k]
				
				if item ~= nil then
					reaper.SetMediaItemInfo_Value(sel_items[k], "D_POSITION", first_snap_abs[k] - reaper.GetMediaItemInfo_Value(sel_items[k], "D_SNAPOFFSET"))
				end
			
			end
		
		end -- loop tracks with selected items
		
	end -- more than two tracks selected

	reaper.Undo_EndBlock("Align selected items across tracks", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

--[[ ----- INITIAL SAVE AND RESTORE ====> ]]

-- TRACKS
-- UNSELECT ALL TRACKS
function UnselectAllTracks()
	first_track = reaper.GetTrack(0, 0)
	reaper.SetOnlyTrackSelected(first_track)
	reaper.SetTrackSelected(first_track, false)
end

-- SAVE INITIAL TRACKS SELECTION
init_sel_tracks = {}
local function SaveSelectedTracks (table)
	for i = 0, reaper.CountSelectedTracks(0)-1 do
		table[i+1] = reaper.GetSelectedTrack(0, i)
	end
end

-- RESTORE INITIAL TRACKS SELECTION
local function RestoreSelectedTracks (table)
	UnselectAllTracks()
	for _, track in ipairs(table) do
		reaper.SetTrackSelected(track, true)
	end
end

--[[ <==== INITIAL SAVE AND RESTORE ----- ]]




--msg_start() -- Display characters in the console to show you the begining of the script execution.

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

SaveSelectedTracks(init_sel_tracks)

main() -- Execute your main function

RestoreSelectedTracks(init_sel_tracks)

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)

--msg_end() -- Display characters in the console to show you the end of the script execution.
