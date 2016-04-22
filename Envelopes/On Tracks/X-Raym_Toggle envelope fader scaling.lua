--[[
 * ReaScript Name: Toggle envelope fader scaling
 * Description: See title.
 * Instructions: Select tracks with visible and armed envelopes. Execute the script. Note that if there is an envelope selected, it will work only for it.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI:
 * Licence: GPL v3
 * Forum Thread: Scripts (Lua): Multiple Tracks and Multiple Envelope Operations
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=157483
 * REAPER: 5.0
 * Extensions: SWS 2.8.0 #0
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2015-09-10)
	+ Initial release
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
]]-- <==== DEBUGGING -----

function Msg(val)
	reaper.ShowConsoleMsg(tostring(val).."\n")
end

function Action(env)
	
	-- GET THE ENVELOPE
	br_env = reaper.BR_EnvAlloc(env, false)

	active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, type, faderScaling = reaper.BR_EnvGetProperties(br_env, true, true, true, true, 0, 0, 0, 0, 0, 0, true)

	-- IF ENVELOPE IS A CANDIDATE
	if type == 0 or type == 1 then -- is volume
		if faderScaling == true then
		
			-- reaper.BR_EnvSetProperties(br_env, active_out, visible_out, armed_out, inLane, laneHeight, defaultShape, faderScaling)
			reaper.BR_EnvSetProperties(br_env, active, visible, armed, inLane, laneHeight, defaultShape, false)
		
		else
		
			reaper.BR_EnvSetProperties(br_env, active, visible, armed, inLane, laneHeight, defaultShape, true)
		
		end
	end
	
	reaper.BR_EnvFree(br_env, 1)

end

function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
	
	edit_pos = reaper.GetCursorPosition()
	
	-- LOOP TRHOUGH SELECTED TRACKS
	env = reaper.GetSelectedEnvelope(0)

	if env == nil then

		selected_tracks_count = reaper.CountSelectedTracks(0)
		
		-- if selected_tracks_count > 0 and UserInput() then
		if selected_tracks_count > 0 then
			for i = 0, selected_tracks_count-1  do
				
				-- GET THE TRACK
				track = reaper.GetSelectedTrack(0, i) -- Get selected track i

				-- LOOP THROUGH ENVELOPES
				env_count = reaper.CountTrackEnvelopes(track)
				for j = 0, env_count-1 do

					-- GET THE ENVELOPE
					env = reaper.GetTrackEnvelope(track, j)

					Action(env)

				end -- ENDLOOP through envelopes

			end -- ENDLOOP through selected tracks
			
		end

	else

		Action(env)
	
	end -- endif sel envelope

	reaper.Undo_EndBlock("Toggle envelope fader scaling", -1) -- End of the undo block. Leave it at the bottom of your main function.

end -- end main()

--msg_start() -- Display characters in the console to show you the begining of the script execution.

reaper.PreventUIRefresh(1)-- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)

--msg_end() -- Display characters in the console to show you the end of the script execution.

-- Update the TCP envelope value at edit cursor position
function HedaRedrawHack()
	reaper.PreventUIRefresh(1)

	track=reaper.GetTrack(0,0)

	trackparam=reaper.GetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT")	
	if trackparam==0 then
		reaper.SetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT", 1)
	else
		reaper.SetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT", 0)
	end
	reaper.SetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT", trackparam)

	reaper.PreventUIRefresh(-1)
	
end
HedaRedrawHack()
