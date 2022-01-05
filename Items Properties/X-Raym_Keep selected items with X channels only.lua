--[[
 * ReaScript Name: Keep selected items with X channels only
 * Instructions: Select items. Run.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Items selection (Various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=163321
 * REAPER: 5.0 pre 15
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2015-06-25)
  + Initial Release
--]]

function main(output)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.


  -- GET SELECTED NOTES (from 0 index)
  for i = 0, count_sel_items-1 do

    item = reaper.GetSelectedMediaItem(0, count_sel_items-1-i)
    take = reaper.GetActiveTake(item)

    if take ~= nil then

      if reaper.TakeIsMIDI(take) == false then

        take_pcm = reaper.GetMediaItemTake_Source(take)

        take_pcm_chan = reaper.GetMediaSourceNumChannels(take_pcm)
        take_chan_mod = reaper.GetMediaItemTakeInfo_Value(take, "I_CHANMODE")

        select = 0

        if output == 1 and ((take_chan_mod > 1 and take_chan_mod < 67) or take_pcm_chan == 1) then
          select = 1
        end

        if output == 2 and (take_chan_mod > 66 or (take_chan_mod <= 1 and take_pcm_chan == output)) then
          select = 1
        end

        if output > 1 and take_chan_mod <= 1 and take_pcm_chan == output then
          select = 1
        end

        if select == 0 then reaper.SetMediaItemSelected(item, false) end

      else
        reaper.SetMediaItemSelected(item, false)
      end

    else
      reaper.SetMediaItemSelected(item, false)
    end

  end

  reaper.Undo_EndBlock("Keep selected items with X channels only", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

count_sel_items = reaper.CountSelectedMediaItems(0)

retval, output = reaper.GetUserInputs("Keep selected items with X channels only", 1, "Number of channel", "2")

if retval and count_sel_items > 0 and output ~= "" then

  reaper.PreventUIRefresh(1)

  output = tonumber(output)

  if output ~= nil then
    main(output) -- Execute your main function
  end

  reaper.UpdateArrange() -- Update the arrangement (often needed)

  reaper.PreventUIRefresh(-1)

end