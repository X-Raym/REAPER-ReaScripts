--[[
 * ReaScript Name: Run in background and perform actions if mouse enter time selection
 * Description: 
 * Instructions: 
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI:
 * Licence: GPL v3
 * Forum Thread: 
 * Forum Thread URI: 
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2015-12-02)
	+ Initial Release
 --]]

function Msg(val)
	reaper.ShowConsoleMsg(tostring(val).."\n")
end

 -- Set ToolBar Button ON
function SetButtonON()
  is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  state = reaper.GetToggleCommandStateEx( sec, cmd )
  reaper.SetToggleCommandState( sec, cmd, 1 ) -- Set ON
  reaper.RefreshToolbar2( sec, cmd )
end

-- Set ToolBar Button OFF
function SetButtonOFF()
  is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  state = reaper.GetToggleCommandStateEx( sec, cmd )
  reaper.SetToggleCommandState( sec, cmd, 0 ) -- Set OFF
  reaper.RefreshToolbar2( sec, cmd )
end



function main()
	
	mouse_pos = reaper.BR_PositionAtMouseCursor(false)
	start_time, end_time =  reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
	
	if mouse_pos > start_time and mouse_pos < end_time then
		
		if in_time == false then
		
			in_time = true
		
			if in_time == true then

				reaper.PreventUIRefresh(1)
				reaper.Undo_BeginBlock() -- Have to be tested

				-- DO YOUR STUFF HERE
				
				reaper.Undo_EndBlock("Your action", -1)
				reaper.UpdateArrange()
				reaper.PreventUIRefresh(-1)

			end
		
		end
	
	else
	
		in_time = false
	
	end
	
	reaper.defer(main)
end

in_time = false
SetButtonON()

main()

reaper.atexit( SetButtonOFF )
