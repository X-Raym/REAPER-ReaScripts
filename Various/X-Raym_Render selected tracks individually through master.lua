--[[
 * ReaScript Name: Render selected tracks individually through master
 * Description: A way to render tracks to master chain.
 * Instructions: Select tracks. Set render settings to source = master tracks, time selection, or custom time range.
 * Screenshot: https://i.imgur.com/v3UKS68.gifv
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-Scripts
 * File URI:
 * Licence: GPL v3
 * Forum Thread: Render Stems (selected tracks) through master FX?
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1652366
 * REAPER: 5.0
 * Version: 2.1
--]]

--[[
 * Changelog:
 * v2.1 (2019-04-29)
	# $tracknumber $parenttrack support
 * v2.0.1 (2019-04-29)
	# Added sceenshot
 * v2.0 (2019-04-29)
	# New core: now works without regions. REAPER > v5.954 required.
 * v1.2 (2018-07-04)
	# Better instructions
 * v1.1.1 (2018-03-15)
	# Region index fix
 * v1.1 (2016-11-01)
	+ Region engine
 * v1.0 (2016-03-16)
	+ Initial Release
--]]


-- USER CONFIG AREA -----------------------------------------------------------

add_queue = false -- Toggle to render right away
render = true -- true/false: Toggle to render the queue is queue has been chosen

-- Render action for the instant render
render_action = 42230 -- -- File: Render project, using the most recent render settings, auto-close render dialog

console = true -- display console messages

-- Add Leading Zeros to A Number
function AddZeros(number, zeros)
	number = tostring(number)
	number = string.format('%0' .. zeros .. 'd', number)
	return number
end

------------------------------------------------------- END OF USER CONFIG AREA

function main()

	retval, pattern = reaper.GetSetProjectInfo_String( 0, "RENDER_PATTERN", "", false )
	
	count_tracks = reaper.CountTracks(0)
	zeros = string.len(tostring(count_tracks))

	-- LOOP TRHOUGH SELECTED TRACKS
	local total = 0
	for i, track in ipairs(init_sel_tracks) do
		reaper.SetOnlyTrackSelected(track)
		reaper.Main_OnCommand(40340, 0) -- Unsolo all tracks
		reaper.Main_OnCommand(40728, 0) -- Solo track

		local retval, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false) -- Get track info
		local track_id = reaper.GetMediaTrackInfo_Value( track, "IP_TRACKNUMBER" )
		
		local new_pattern = pattern:gsub("$tracknumber", AddZeros(track_id, zeros))
		
		parent_track = reaper.GetParentTrack( track )
		parent_track_name = ""
		if parent_track then
			retval, parent_track_name = reaper.GetSetMediaTrackInfo_String(parent_track, "P_NAME", "", false) -- Get track info
		end
		new_pattern = new_pattern:gsub("$parenttrack", parent_track_name)
		
		new_pattern = new_pattern:gsub("$track", track_name)          

		reaper.GetSetProjectInfo_String( 0, "RENDER_PATTERN", new_pattern, true )
		
		if add_queue then
			reaper.Main_OnCommand(41823, 0) -- Add to render queue               
		else
			reaper.Main_OnCommand( render_action, 0)
		end

		total = total + 1

	end
	
	retval, pattern = reaper.GetSetProjectInfo_String( 0, "RENDER_PATTERN", pattern, true ) -- Restore initial pattern

	reaper.Main_OnCommand(40340, 0) -- Unsolo all tracks

end


-- UTILITIES -------------------------------------------------------------

-- Display a message in the console for debugging
function Msg(value)
	if console then
		reaper.ShowConsoleMsg(tostring(value) .. "\n")
	end
end


-- UNSELECT ALL TRACKS
function UnselectAllTracks()
	first_track = reaper.GetTrack(0, 0)
	reaper.SetOnlyTrackSelected(first_track)
	reaper.SetTrackSelected(first_track, false)
end

-- SAVE INITIAL TRACKS SELECTION
function SaveSelectedTracks(table)
	for i = 0, reaper.CountSelectedTracks(0)-1 do
		table[i+1] = reaper.GetSelectedTrack(0, i)
	end
end

-- RESTORE INITIAL TRACKS SELECTION
function RestoreSelectedTracks(table)
	UnselectAllTracks()
	for _, track in ipairs(table) do
		reaper.SetTrackSelected(track, true)
	end
end

--------------------------------------------------------- END OF UTILITIES

-- INIT

sel_tracks_count = reaper.CountSelectedTracks(0)

if sel_tracks_count > 0 then

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	reaper.PreventUIRefresh(1)

	reaper.ClearConsole()

	init_sel_tracks = {}
	SaveSelectedTracks(init_sel_tracks)

	main() -- Execute your main function

	if render then
		reaper.Main_OnCommand(41207, 0)
	end

	RestoreSelectedTracks(init_sel_tracks)

	reaper.UpdateArrange() -- Update the arrangement (often needed)

	reaper.PreventUIRefresh(-1)

	reaper.Undo_EndBlock("Render selected tracks individually through master", -1) -- End of the undo block. Leave it at the bottom of your main function.

end
