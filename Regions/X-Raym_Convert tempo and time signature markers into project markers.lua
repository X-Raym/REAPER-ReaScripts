--[[
 * ReaScript Name: Convert tempo and time signature markers into project markers
 * Description:
 * Instructions: Run.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script: Script name
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1564860
 * REAPER: 5.0 pre 15
 * Extensions: None
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2015-07-12)
	+ Initial Release
 --]]

--[[ ----- DEBUGGING ====>
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

time_os = reaper.time_precise()

msg_clean()
]]-- <==== DEBUGGING -----

color = "#FF0000"

function HexToInt(value)
	hex = value:gsub("#", "")
	R = tonumber("0x"..hex:sub(1,2))
	G = tonumber("0x"..hex:sub(3,4))
	B = tonumber("0x"..hex:sub(5,6))
	
	color_int = (R + 256 * G + 65536 * B)|16777216
	
	return color_int
	
end

function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	count_tempo_markers = reaper.CountTempoTimeSigMarkers(0)
	
	if count_tempo_markers > 0 then
	
		for i = 0, count_tempo_markers - 1 do
		
		retval, pos, measure_pos, beat_pos, bpm, timesig_num, timesig_denom, lineartempoOut = reaper.GetTempoTimeSigMarker(0, i)
		
		bpm = tostring(bpm)
		x, y = string.find(bpm, ".0")
		if y ==  string.len(bpm) - 2 then
			bpm = string.sub(bpm, 0, -3)
		end
		
		if timesig_num == 0 then timesig_num = 4 end
		if timesig_denom == 0 then timesig_denom = 4 end
		
		name = tostring(bpm).." BPM - "..tostring(timesig_num).."/"..tostring(timesig_denom)
		
		color_int = HexToInt(color)
		
		reaper.AddProjectMarker2(0, false, pos, 0, name, -1, color_int)
		
		end
	
	end
	
	reaper.Undo_EndBlock("Convert tempo and time signature markers into project markers", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

--reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

--RestoreCursorPos()
--RestoreLoopTimesel()
--RestoreSelectedItems(init_sel_items)
--RestoreSelectedTracks(init_sel_tracks)
--RestoreView()

-- reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)