--[[
 * ReaScript Name: Move edit cursor to first selected item snap offset
 * Description: Move edit or play cursor to next region. Move view and seek play.
 * Instructions: Place edit cursor inside a region. Use it.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Scripts: Transport (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1601342
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2015-12-14)
	+ Initial Release
--]]

-- USER CONFIG AREA -----
move_view = false -- false, true
-------------------------


function main()

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
	
	item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
	
	item_snap = reaper.GetMediaItemInfo_Value(item, "D_SNAPOFFSET")
	
	pos = item_pos + item_snap

	reaper.SetEditCurPos(pos, move_view, false)
		
	reaper.Undo_EndBlock("Move edit cursor to first selected item snap offset", -1) -- End of the undo block. Leave it at the bottom of your main function.
end

item = reaper.GetSelectedMediaItem(0, 0)

if item ~= nil then
	
	main() -- Execute your main function
	reaper.UpdateArrange() -- Update the arrangement (often needed)

end