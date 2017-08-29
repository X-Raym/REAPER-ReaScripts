--[[
 * ReaScript Name: Set sequential mono channel modes on selected items
 * Description: It sets each to next number. So first item will be channel 1, next channel 2, etc
 * Instructions: Select items. Run.
 * Screenshot: http://i.imgur.com/KTapWKU.gif
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Properties (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1574814
 * REAPER: 5.0
 * Version: 1.0.1
--]]

--[[
 * Changelog:
 * v1.0.1 (2017-08-29)
	# Title
 * v1.0 (2017-08-29)
	+ Initial Release
--]]

reaper.PreventUIRefresh(1)

reaper.Undo_BeginBlock()

for i = 0, reaper.CountSelectedMediaItems(0) - 1 do
  local item = reaper.GetSelectedMediaItem(0,i)
  local take = reaper.GetActiveTake(item)
  if take then
    reaper.SetMediaItemTakeInfo_Value(take, "I_CHANMODE", i+3)
  end
end

reaper.Undo_EndBlock("Set sequential mono channel modes on selected items", -1)

reaper.UpdateArrange()

reaper.PreventUIRefresh(-1)