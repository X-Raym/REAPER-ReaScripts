--[[
 * ReaScript Name: Move edit cursor to next frame
 * Description: 
 * Instructions: Run
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: 
 * Forum Thread: 	Scripts: Transport (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1601342
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2016-01-04)
	+ Initial Release
 --]]

function RoundToX(number, interval)
	round = math.floor((number+(interval/2))/interval) * interval
	
	--msg_f(interval)
	--msg_f(number)
	--msg_f(round)
	
	return round
end

function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
	
	frameRate, dropFrameOut = reaper.TimeMap_curFrameRate(0)
	
	frame_duration = 1/frameRate
	
	cur_pos = reaper.GetCursorPosition()

	-- MODIFY INFOS
	pos_quantized = RoundToX(cur_pos, frame_duration)
	
	if pos_quantized <= cur_pos then
	
		reaper.SetEditCurPos(pos_quantized + frame_duration, true, true)
	
	else
	
		reaper.SetEditCurPos(pos_quantized, true, true)
	
	end
	
	reaper.Undo_EndBlock("Move edit cursor to next frame", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

reaper.PreventUIRefresh(-1)

reaper.UpdateArrange() -- Update the arrangement (often needed)