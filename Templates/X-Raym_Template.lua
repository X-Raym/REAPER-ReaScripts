--[[
 * ReaScript Name: Template Title (match file name without extension and author)
 * Description: A template script for REAPER ReaScript.
 * Instructions: Here is how to use it. (optional)
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script: Script name
 * Forum Thread URI: http://forum.cockos.com/***.html
 * REAPER: 5.0 pre 15
 * Extensions: SWS/S&M 2.7.1 (optional)
 * Version: 1.9
--]]
 
--[[
 * Changelog:
 * v1.9 (2015-06-12)
 	+ performance checker
 * v1.8 (2015-05-11)
 	# No more call to standards actions (better for undos).
 * v1.7 (2015-05-08)
 	+ Save/Restore view without calling the SWS "slot" functions.
 * v1.6 (2015-04-15)
 	+ Save/Restore functions without calling the SWS "slot" functions.
 	# thanks to heda for the edit cursor restore
 * v1.5 (2015-03-03)
 	+ Call Functions file from relative parent subfolder
 * v1.4.1 (2015-03-03)
 	# EnumProjectMarkers3 for regions loop
 * v1.4 (2015-03-02)
 	+ Infos for track, take and items values
 	+ Restore view, loop, edit cursor and UI
 * v1.3.1 (2015-02-27)
 	# loops takes bug fix
 	# thanks benf and heda for help with looping through regions!
 	# thanks to Heda for the function that embed external lua files!
 * v1.0 (2015-02-27)
	+ Initial Release
 --]]

-- ----- DEBUGGING ====>
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
-- <==== DEBUGGING -----

function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	-- YOUR CODE BELOW

	-- LOOP THROUGH SELECTED ITEMS
	--[[
	selected_items_count = reaper.CountSelectedMediaItems(0)
	
	-- INITIALIZE loop through selected items
	for i = 0, selected_items_count-1  do
		-- GET ITEMS
		item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i

		-- GET INFOS
		value_get = reaper.GetMediaItemInfo_Value(item, "D_VOL") -- Get the value of a the parameter
		--[[
		B_MUTE : bool * to muted state
		B_LOOPSRC : bool * to loop source
		B_ALLTAKESPLAY : bool * to all takes play
		B_UISEL : bool * to ui selected
		C_BEATATTACHMODE : char * to one char of beat attached mode, -1=def, 0=time, 1=allbeats, 2=beatsosonly
		C_LOCK : char * to one char of lock flags (&1 is locked, currently)
		D_VOL : double * of item volume (volume bar)
		D_POSITION : double * of item position (seconds)
		D_LENGTH : double * of item length (seconds)
		D_SNAPOFFSET : double * of item snap offset (seconds)
		D_FADEINLEN : double * of item fade in length (manual, seconds)
		D_FADEOUTLEN : double * of item fade out length (manual, seconds)
		D_FADEINLEN_AUTO : double * of item autofade in length (seconds, -1 for no autofade set)
		D_FADEOUTLEN_AUTO : double * of item autofade out length (seconds, -1 for no autofade set)
		C_FADEINSHAPE : int * to fadein shape, 0=linear, ...
		C_FADEOUTSHAPE : int * to fadeout shape
		I_GROUPID : int * to group ID (0 = no group)
		I_LASTY : int * to last y position in track (readonly)
		I_LASTH : int * to last height in track (readonly)
		I_CUSTOMCOLOR : int * : custom color, windows standard color order (i.e. RGB(r,g,b)|0x100000). if you do not |0x100000, then it will not be used (though will store the color anyway)
		I_CURTAKE : int * to active take
		IP_ITEMNUMBER : int, item number within the track (read-only, returns the item number directly)
		F_FREEMODE_Y : float * to free mode y position (0..1)
		F_FREEMODE_H : float * to free mode height (0..1)
		]]
		--[[
		
		-- MODIFY INFOS
		value_set = value_get -- Prepare value output
		
		-- SET INFOS
		reaper.SetMediaItemInfo_Value(item, "D_VOL", value_set) -- Set the value to the parameter
	end -- ENDLOOP through selected items
	--]]

	-- LOOP THROUGH SELECTED TAKES
	--[[
	selected_items_count = reaper.CountSelectedMediaItems(0)

	for i = 0, selected_items_count-1  do
		-- GET ITEMS
		item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i

		take = reaper.GetActiveTake(item) -- Get the active take

		if take ~= nil then -- if ==, it will work on "empty"/text items only
			-- GET INFOS
			value_get = reaper.GetMediaItemTakeInfo_Value(take, "D_VOL") -- Get the value of a the parameter
			--[[
			D_STARTOFFS : double *, start offset in take of item
			D_VOL : double *, take volume
			D_PAN : double *, take pan
			D_PANLAW : double *, take pan law (-1.0=default, 0.5=-6dB, 1.0=+0dB, etc)
			D_PLAYRATE : double *, take playrate (1.0=normal, 2.0=doublespeed, etc)
			D_PITCH : double *, take pitch adjust (in semitones, 0.0=normal, +12 = one octave up, etc)
			B_PPITCH, bool *, preserve pitch when changing rate
			I_CHANMODE, int *, channel mode (0=normal, 1=revstereo, 2=downmix, 3=l, 4=r)
			I_PITCHMODE, int *, pitch shifter mode, -1=proj default, otherwise high word=shifter low word = parameter
			I_CUSTOMCOLOR : int *, custom color, windows standard color order (i.e. RGB(r,g,b)|0x100000). if you do not |0x100000, then it will not be used (though will store the color anyway)
			IP_TAKENUMBER : int, take number within the item (read-only, returns the take number directly)
			]]
			--[[

			-- MODIFY INFOS
			value_set = value_get -- Prepare value output
			-- SET INFOS
			reaper.SetMediaItemTakeInfo_Value(take, "D_VOL", value_set) -- Set the value to the parameter
		end -- ENDIF active take
	end -- ENDLOOP through selected items
	--]]

	-- LOOP TRHOUGH SELECTED TRACKS
	--[[
	selected_tracks_count = reaper.CountSelectedTracks(0)

	for i = 0, selected_tracks_count-1  do
		-- GET THE TRACK
		track = reaper.GetSelectedTrack(0, i) -- Get selected track i

		--GET INFOS
		value_get = reaper.GetMediaTrackInfo_Value(track, "B_MUTE")
		--[[
		B_MUTE : bool * : mute flag
		B_PHASE : bool * : invert track phase
		IP_TRACKNUMBER : int : track number (returns zero if not found, -1 for master track) (read-only, returns the int directly)
		I_SOLO : int * : 0=not soloed, 1=solo, 2=soloed in place
		I_FXEN : int * : 0=fx bypassed, nonzero = fx active
		I_RECARM : int * : 0=not record armed, 1=record armed
		I_RECINPUT : int * : record input. <0 = no input, 0..n = mono hardware input, 512+n = rearoute input, 1024 set for stereo input pair. 4096 set for MIDI input, if set, then low 5 bits represent channel (0=all, 1-16=only chan), then next 5 bits represent physical input (31=all, 30=VKB)
		I_RECMODE : int * : record mode (0=input, 1=stereo out, 2=none, 3=stereo out w/latcomp, 4=midi output, 5=mono out, 6=mono out w/ lat comp, 7=midi overdub, 8=midi replace
		I_RECMON : int * : record monitor (0=off, 1=normal, 2=not when playing (tapestyle))
		I_RECMONITEMS : int * : monitor items while recording (0=off, 1=on)
		I_AUTOMODE : int * : track automation mode (0=trim/off, 1=read, 2=touch, 3=write, 4=latch
		I_NCHAN : int * : number of track channels, must be 2-64, even
		I_SELECTED : int * : track selected? 0 or 1
		I_WNDH : int * : current TCP window height (Read-only)
		I_FOLDERDEPTH : int * : folder depth change (0=normal, 1=track is a folder parent, -1=track is the last in the innermost folder, -2=track is the last in the innermost and next-innermost folders, etc
		I_FOLDERCOMPACT : int * : folder compacting (only valid on folders), 0=normal, 1=small, 2=tiny children
		I_MIDIHWOUT : int * : track midi hardware output index (<0 for disabled, low 5 bits are which channels (0=all, 1-16), next 5 bits are output device index (0-31))
		I_PERFFLAGS : int * : track perf flags (&1=no media buffering, &2=no anticipative FX)
		I_CUSTOMCOLOR : int * : custom color, windows standard color order (i.e. RGB(r,g,b)|0x100000). if you do not |0x100000, then it will not be used (though will store the color anyway)
		I_HEIGHTOVERRIDE : int * : custom height override for TCP window. 0 for none, otherwise size in pixels
		D_VOL : double * : trim volume of track (0 (-inf)..1 (+0dB) .. 2 (+6dB) etc ..)
		D_PAN : double * : trim pan of track (-1..1)
		D_WIDTH : double * : width of track (-1..1)
		D_DUALPANL : double * : dualpan position 1 (-1..1), only if I_PANMODE==6
		D_DUALPANR : double * : dualpan position 2 (-1..1), only if I_PANMODE==6
		I_PANMODE : int * : pan mode (0 = classic 3.x, 3=new balance, 5=stereo pan, 6 = dual pan)
		D_PANLAW : double * : pan law of track. <0 for project default, 1.0 for +0dB, etc
		P_ENV : read only, returns TrackEnvelope *, setNewValue= B_SHOWINMIXER : bool * : show track panel in mixer -- do not use on master
		B_SHOWINTCP : bool * : show track panel in tcp -- do not use on master
		B_MAINSEND : bool * : track sends audio to parent
		B_FREEMODE : bool * : track free-mode enabled (requires UpdateTimeline() after changing etc)
		C_BEATATTACHMODE : char * : char * to one char of beat attached mode, -1=def, 0=time, 1=allbeats, 2=beatsposonly
		F_MCP_FXSEND_SCALE : float * : scale of fx+send area in MCP (0.0=smallest allowed, 1=max allowed)
		F_MCP_SENDRGN_SCALE : float * : scale of send area as proportion of the fx+send total area (0=min allow, 1=max)
		]]
		--[[
		-- ACTIONS
	end -- ENDLOOP through selected tracks
	--]]
	--]]

	-- LOOP THROUGH REGIONS
	--[[
	i=0
	repeat
		iRetval, bIsrgnOut, iPosOut, iRgnendOut, sNameOut, iMarkrgnindexnumberOut, iColorOur = reaper.EnumProjectMarkers3(0,i)
		if iRetval >= 1 then
			if bIsrgnOut == true then
				-- ACTION ON REGIONS HERE
			end
			i = i+1
		end
	until iRetval == 0
	--]]
	--]]

	-- LOOP TRHOUGH FX - by HeDa
	--[[
	tracks_count = reaper.CountTracks(0)

	for i = 0, tracks_count-1  do -- loop for all tracks
			
		track = reaper.GetTrack(0, i)	-- which track
		track_FX_count = reaper.TrackFX_GetCount(tracki) -- count number of FX instances on the track
		
		for i = 0, track_FX_count-1  do,	-- loop for all FX instances on each track
			-- ACTIONS
					
		end -- ENDLOOP FX loop
	end -- ENDLOOP tracks loop
	--]]
	--]]
	
	-- YOUR CODE ABOVE

	reaper.Undo_EndBlock("My action", -1) -- End of the undo block. Leave it at the bottom of your main function.

end


-- The following functions may be passed as global if needed
--[[ ----- INITIAL SAVE AND RESTORE ====> ]]

-- ITEMS
--[[ UNSELECT ALL ITEMS
function UnselectAllItems()
	for  i = 0, reaper.CountMediaItems(0) do
		reaper.SetMediaItemSelected(reaper.GetMediaItem(0, i), false)
	end
end

-- SAVE INITIAL SELECTED ITEMS
init_sel_items = {}
local function SaveSelectedItems (table)
	for i = 0, reaper.CountSelectedMediaItems(0)-1 do
		table[i+1] = reaper.GetSelectedMediaItem(0, i)
	end
end

-- RESTORE INITIAL SELECTED ITEMS
local function RestoreSelectedItems (table)
	UnselectAllItems() -- Unselect all items
	for _, item in ipairs(table) do
		reaper.SetMediaItemSelected(item, true)
	end
end]]

-- TRACKS
--[[ UNSELECT ALL TRACKS
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

-- LOOP AND TIME SELECTION
--[[ SAVE INITIAL LOOP AND TIME SELECTION
function SaveLoopTimesel()
	init_start_timesel, init_end_timesel = reaper.GetSet_LoopTimeRange(0, 0, 0, 0, 0)
	init_start_loop, init_end_loop = reaper.GetSet_LoopTimeRange(0, 1, 0, 0, 0)
end

-- RESTORE INITIAL LOOP AND TIME SELECTION
function RestoreLoopTimesel()
	reaper.GetSet_LoopTimeRange(1, 0, init_start_timesel, init_end_timesel, 0)
	reaper.GetSet_LoopTimeRange(1, 1, init_start_loop, init_end_loop, 0)
end]]

-- CURSOR
--[[ SAVE INITIAL CURSOR POS
function SaveCursorPos()
	init_cursor_pos = reaper.GetCursorPosition()
end

-- RESTORE INITIAL CURSOR POS
function RestoreCursorPos()
	reaper.SetEditCurPos(init_cursor_pos, false, false)
end]]

-- VIEW
--[[ SAVE INITIAL VIEW
function SaveView()
	start_time_view, end_time_view = reaper.BR_GetArrangeView(0)
end


-- RESTORE INITIAL VIEW
function RestoreView()
	reaper.BR_SetArrangeView(0, start_time_view, end_time_view)
end]]

--[[ <==== INITIAL SAVE AND RESTORE ----- ]]




--msg_start() -- Display characters in the console to show you the begining of the script execution.

--[[ reaper.PreventUIRefresh(1) ]]-- Prevent UI refreshing. Uncomment it only if the script works.

--SaveView()
--SaveCursorPos()
--SaveLoopTimesel()
--SaveSelectedItems(init_sel_items)
--SaveSelectedTracks(init_sel_tracks)

main() -- Execute your main function

--RestoreCursorPos()
--RestoreLoopTimesel()
--RestoreSelectedItems(init_sel_items)
--RestoreSelectedTracks(init_sel_tracks)
--RestoreView()

--[[ reaper.PreventUIRefresh(-1) ]] -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)

--msg_end() -- Display characters in the console to show you the end of the script execution.

-- reaper.ShowMessageBox("Script executed in (s): "..tostring(reaper.time_precise() - time_os), "", 0)