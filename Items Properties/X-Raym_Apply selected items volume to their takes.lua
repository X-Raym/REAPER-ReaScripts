--[[
 * ReaScript Name: Apply selected items volume to their takes
 * Instructions: Select items. Run.
 * Screenshot: https://i.imgur.com/VfyPoq7.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Nudge selected items volume
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=152009
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2023-11-20)
  + Initial Release
--]]

function dBFromVal(val) return 20*math.log(val, 10) end
function ValFromdB(dB_val) return 10^(dB_val/20) end

function main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  for i = 0, count_sel_items - 1 do

    item = reaper.GetSelectedMediaItem(0, i)

    count_takes = reaper.CountTakes( item )

    for j = 0, count_takes - 1 do
      
      take = reaper.GetTake( item, j )
      take_vol = reaper.GetMediaItemTakeInfo_Value( take, "D_VOL" )
      item_vol = reaper.GetMediaItemInfo_Value(item, "D_VOL")

      if item_vol ~= 1 then

        take_vol_db = dBFromVal( take_vol )
        item_vol_db = dBFromVal( item_vol )

        reaper.SetMediaItemTakeInfo_Value(take, "D_VOL", ValFromdB( item_vol_db + take_vol_db ) )
        reaper.SetMediaItemInfo_Value(item, "D_VOL", 1 )

      end

    end


  end

  reaper.Undo_EndBlock("Apply selected items volume to their takes", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

count_sel_items = reaper.CountSelectedMediaItems(0)
if count_sel_items > 0 then
  reaper.PreventUIRefresh(1)

  main() -- Execute your main function

  reaper.UpdateArrange() -- Update the arrangement (often needed)

  reaper.PreventUIRefresh(-1)
end
