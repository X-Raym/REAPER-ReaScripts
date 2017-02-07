--[[
 * ReaScript Name: Replace similar MIDI Takes by pools
 * Description: Check selected items active takes MIDI content, and see if there is similar content. If yes, then replace by a pool instance. Very handy when you import and split guitar tabs or any instrument score, and you already split your midi items by riffs-patterns.
 * Instructions: Select MIDI items. Run.
 * Screenshot: http://i.imgur.com/N2fcs9k.gifv
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > ReaScripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: MIDI ( Various )
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=187555
 * REAPER: 5.32
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 ( 2017-02-07 )
	+ Initial Release
--]]


-- USER CONFIG AREA -----------------------------------------------------------

console = true -- true/false: display debug messages in the console

------------------------------------------------------- END OF USER CONFIG AREA

-- TODO: Maybe check Pool first to prevent duplication of Items already in the same pool
-- NOTE: It duplicates first item of a group. It doesn't preserve alternative takes of other similart items. It also copy FX and envelopes attached to it.

-- UTILITIES -------------------------------------------------------------

-- Performance
local reaper = reaper
local string = string

-- Save item selection, and get midi infos right away
function SaveSelectedMIDITakes ( array )
	for i = 0, reaper.CountSelectedMediaItems( 0 )-1 do
		local item = reaper.GetSelectedMediaItem( 0, i )
		local take = reaper.GetActiveTake( item )
		if take then
			if reaper.TakeIsMIDI( take ) then
				local retval, take_midi = reaper.MIDI_GetAllEvts( take, "" )
				if take_midi:len() > 0 then
					local take_midi_decode = MIDI_Decode( take_midi )
					new_entry = {}
					new_entry['midi'] = take_midi_decode
					new_entry['take'] = take
					new_entry['item'] = item
					table.insert( array, new_entry )
				end
			end
		end
	end
end

function RestoreSelectedItems ( table )
	reaper.Main_OnCommand( 40289 , 0 ) -- Unselect all items
	for _, item in ipairs( table ) do
		reaper.SetMediaItemSelected( item, true )
	end
end

-- Display a message in the console for debugging
function Msg( value )
	if console then
		reaper.ShowConsoleMsg( tostring( value ) .. "\n" )
	end
end

function is_in_array( tab, val )
	for index, value in ipairs ( tab ) do
		if value == val then
			return true
		end
	end

	return false
end

function SetOnlyItemSelected( item )
	reaper.Main_OnCommand( 40289 , 0 ) -- Unselect all items
	reaper.SetMediaItemSelected( item, true )
end

-- TRACKS
-- SAVE INITIAL TRACKS SELECTION
function SaveSelectedTracks ( table )
	for i = 0, reaper.CountSelectedTracks( 0 )-1 do
		table[i+1] = reaper.GetSelectedTrack( 0, i )
	end
end
-- RESTORE INITIAL TRACKS SELECTION
function RestoreSelectedTracks ( table )
	reaper.Main_OnCommand( 40297, 0 ) -- Track: Unselect all tracks
	for _, track in ipairs( table ) do
		reaper.SetTrackSelected( track, true )
	end
end

-- VIEW
-- SAVE INITIAL VIEW
function SaveView()
	start_time_view, end_time_view = reaper.BR_GetArrangeView( 0 )
end
-- RESTORE INITIAL VIEW
function RestoreView()
	reaper.BR_SetArrangeView( 0, start_time_view, end_time_view )
end

--------------------------------------------------------- END OF UTILITIES


-- Main function
function Main()

	similar = {}
	duplicates = {}

	-- For each takes
	for i = 1, #midi_takes do

		-- If it has not already be marked as a duplicate of another take
		if not is_in_array( duplicates, i ) then

			take_A = midi_takes[i].take
			take_A_midi = midi_takes[i].midi

			-- For all other midi takes after it
			for j = i +1, #midi_takes do

				take_B = midi_takes[j].take
				take_B_midi = midi_takes[j].midi

				console = false

				Msg( "Compare " .. i .. " with " .. j )

				-- If a similarity is found between the two takes
				if take_A_midi == take_B_midi then

					Msg( "--------->Similar\n" )

					if not similar[i] then similar[i] = {} end

					table.insert( duplicates, j )

					table.insert( similar[i], j )

				end

				console = true

			end -- is take MIDI

		end

	end -- loops of items

	-- COMPARE DUPLICATES
	sel_items = {}
	pools_count = 0
	items_count = 0

	-- For each similarity groups
	for z, index in pairs( similar ) do
		items_count = items_count + 1
		out = ""

		-- Get reference take and items
		source_take = midi_takes[z].take
		source_item = midi_takes[z].item
		SetOnlyItemSelected( source_item )
		reaper.Main_OnCommand( 40698 , 0 ) -- Copy

		-- For the other items in the similarity groups
		for w, double in ipairs( index ) do
			items_count = items_count + 1
			out = out .. double .. ","
			dest_take = midi_takes[double].take
			dest_item = midi_takes[double].item

			dest_track = reaper.GetMediaItemTake_Track( dest_take )

			reaper.SetOnlyTrackSelected( dest_track )

			reaper.Main_OnCommand( 40914, 0 ) -- Track: Set first selected track as last touched track

			dest_pos = reaper.GetMediaItemInfo_Value( dest_item, "D_POSITION" ) -- No need to take about SnapOffset : handles by native action

			reaper.SetEditCurPos( dest_pos, false, false )

			reaper.Main_OnCommand( 41072 , 0 ) -- Paste Pool

			reaper.DeleteTrackMediaItem( dest_track, dest_item )
		end

		table.insert( sel_items, source_item )
		Msg( "Takes " .. z ..', ' .. out .." had similar MIDI.\n" )
		pools_count = pools_count + 1

	end

	Msg( pools_count .. ' MIDI pools were created from ' .. items_count .. ' media items.')

end

-- MIDI Get All Evts to String, based on schwa code snippet
function MIDI_Decode( midi )
	local pos=1
	local midi_string = ""
	while pos <= midi:len() do

	local offs,flag,msg=string.unpack( "IBs4",midi,pos )
	local adv=4+1+4+msg:len() -- int+char+int+msg

	local out="+"..offs.."\t"


	for j=1,msg:len() do
		out=out..string.format( "%02X ",msg:byte( j ))
	end
		if flag ~= 0 then out=out.."\t" end
		if flag&1 == 1 then out=out.."sel " end
		if flag&2 == 2 then out=out.."mute " end
		midi_string = midi_string .. out.."\n"

		pos=pos+adv

	end

	return midi_string
end


-- INIT

-- See if there is items selected
count_sel_items = reaper.CountSelectedMediaItems( 0 )

if count_sel_items > 0 then

	reaper.PreventUIRefresh( 1 )

	reaper.ClearConsole()

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	SaveView()

	init_sel_tracks = {}
	SaveSelectedTracks ( init_sel_tracks )

	midi_takes = {}
	SaveSelectedMIDITakes( midi_takes )

	Main()

	RestoreSelectedTracks( init_sel_tracks )

	RestoreSelectedItems( sel_items )

	RestoreView()

	reaper.Undo_EndBlock( "Replace similar MIDI takes by pools", -1 ) -- End of the undo block. Leave it at the bottom of your main function.

	reaper.UpdateArrange()

	reaper.PreventUIRefresh(-1 )

end
