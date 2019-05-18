--[[
 * ReaScript Name: Apply selected active takes volume to their items volume
 * Instructions: Select items. Run.
 * Screenshot: https://i.imgur.com/gwrg8Ls.gifv
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * Forum Thread: Nudge selected items volume
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=152009
 * REAPER: 5.0
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2019-05-18)
	+ Initial Release
--]]

function dBFromVal(val) return 20*math.log(val, 10) end
function ValFromdB(dB_val) return 10^(dB_val/20) end

function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
	
	for i = 0, count_sel_items - 1 do
	
		item = reaper.GetSelectedMediaItem(0, i)

		take = reaper.GetActiveTake( item )

		if take then
		
			take_vol = reaper.GetMediaItemTakeInfo_Value( take, "D_VOL" )

			if take_vol ~= 1 then

				take_vol_db = dBFromVal( take_vol )
				item_vol_db = dBFromVal( reaper.GetMediaItemInfo_Value(item, "D_VOL") )
				
				reaper.SetMediaItemTakeInfo_Value(take, "D_VOL", 1)
				reaper.SetMediaItemInfo_Value(item, "D_VOL", ValFromdB( item_vol_db + take_vol_db ) )
			
			end

		end
	
		
	end
	
	reaper.Undo_EndBlock("Apply selected active takes volume to their items volume", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

count_sel_items = reaper.CountSelectedMediaItems(0)
if count_sel_items > 0 then
	reaper.PreventUIRefresh(1)

	main() -- Execute your main function

	reaper.UpdateArrange() -- Update the arrangement (often needed)

	reaper.PreventUIRefresh(-1)
end
