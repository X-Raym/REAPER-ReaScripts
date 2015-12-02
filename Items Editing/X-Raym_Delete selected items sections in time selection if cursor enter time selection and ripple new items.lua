--[[
 * ReaScript Name: Delete selected items sections in time selection if cursor enter time selection and ripple new items
 * Description: See title
 * Instructions: Select items with take. Run.
 * Screenshot: http://i.giphy.com/3o8doN6hJOcw77QX8Q.gif
 * Author: X-Raym
 * Author URl: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URl: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URl:
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Editing (various)
 * Forum Thread URl: http://forum.cockos.com/showthread.php?t=163363
 * REAPER: 5.0
 * Extensions: None
 --]]
 
--[[
 * Changelog:
 * v1.0 (2015-12-02)
	+ Initial Release
 --]]

-- Requested by Vanhaze
-- Need X-Raym_Delete selected items and ripple edit adjacent items.lua

function Msg(val)
	reaper.ShowConsoleMsg(tostring(val).."\n")
end

 -- Set ToolBar Button ON
function SetButtonON()
  is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  state = reaper.GetToggleCommandStateEx( sec, cmd );
  reaper.SetToggleCommandState( sec, cmd, 1 ); -- Set ON
  reaper.RefreshToolbar2( sec, cmd );
end

-- Set ToolBar Button OFF
function SetButtonOFF()
  is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  state = reaper.GetToggleCommandStateEx( sec, cmd );
  reaper.SetToggleCommandState( sec, cmd, 0 ); -- Set OFF
  reaper.RefreshToolbar2( sec, cmd );
end


function main()
	
	mouse_pos = reaper.BR_PositionAtMouseCursor(false)
	start_time, end_time =  reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
	
	if mouse_pos > start_time and mouse_pos < end_time then
		
		if in_time == false then
		
			in_time = true
		
			if in_time == true then
				count_selected_items = reaper.CountSelectedMediaItems(0)
				if count_selected_items > 0 then
					reaper.PreventUIRefresh(1)
					reaper.Main_OnCommand(40061, 0) -- Split Items at Time Selection // This action performs on all tracks if no items selected
					reaper.Main_OnCommand( reaper.NamedCommandLookup( "_RSeae17866577002490d8a62b72bbe7f939970eb70" ), 0 ) -- Ripple Edit
					reaper.PreventUIRefresh(-1)
				end
			end
		
		end
	
	else
	
		in_time = false
	
	end
	
	reaper.defer(main)
end

SetButtonON()

in_time = false
main()

reaper.atexit( SetButtonOFF )