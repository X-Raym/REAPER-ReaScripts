--[[
 * ReaScript Name: Offset selected items volume by their track fader value
 * Screenshot: https://i.imgur.com/OwhWpbn.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2021-30-04)
  + Initial Release
--]]

function dBFromVal(val) return 20*math.log(val, 10) end
function ValFromdB(dB_val) return 10^(dB_val/20) end

function Main()

  for i = 0, count_sel_items - 1 do

    local item = reaper.GetSelectedMediaItem(0, i)
    local take = reaper.GetActiveTake(item)

    if take and not reaper.TakeIsMIDI(take) then

      local track = reaper.GetMediaItemTrack ( item )
      local track_vol = reaper.GetMediaTrackInfo_Value(track, "D_VOL")
      local item_vol = reaper.GetMediaItemInfo_Value(item, "D_VOL")

      local new_val = ValFromdB(dBFromVal(track_vol) + dBFromVal(item_vol))

      reaper.SetMediaItemInfo_Value(item, "D_VOL", new_val)

    end


  end

end

count_sel_items = reaper.CountSelectedMediaItems(0)
if count_sel_items > 0 then
  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  Main() -- Execute your main function

  reaper.Undo_EndBlock("Offset selected items volume by their track fader value", -1) -- End of the undo block. Leave it at the bottom of your main function.

  reaper.UpdateArrange() -- Update the arrangement (often needed)

  reaper.PreventUIRefresh(-1)
end
