--[[
 * ReaScript Name: Shift selected takes source audio content position randomly
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Screenshot: https://i.imgur.com/o7IlmwY.gifv
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Editing (various)
 * Forum Thread URI: https://forum.cockos.com/showthread.php?t=163363
 * REAPER: 5.0
 * Version: 1.1
--]]
 
--[[
 * Changelog:
 * v1.1 (2018-12-07)
  # Quantify snap offset if snap active
 * v1.0 (2018-12-06)
  + Initial Release
--]]

--------------------------------------------------------- END OF UTILITIES

-- https://stackoverflow.com/questions/11548062/how-to-generate-random-float-in-lua
function randomFloat(lower, greater)
    return lower + math.random()  * (greater - lower);
end

-- Main function
function main()

  snap = reaper.GetToggleCommandState(1157)

  for i = 0, reaper.CountSelectedMediaItems(0)-1 do
    local item = reaper.GetSelectedMediaItem(0, i)
    local take = reaper.GetActiveTake( item )
    if take and not reaper.TakeIsMIDI( take ) then

      local source = reaper.GetMediaItemTake_Source( take )
      local retval, lengthIsQN = reaper.GetMediaSourceLength( source )
      local value = randomFloat( 0, retval - reaper.GetMediaItemInfo_Value( item, "D_LENGTH") )
      if snap == 1 then -- if Snap on 
        -- NOTE: only for fix grid
        -- Quantize the offset
        offset = reaper.GetMediaItemTakeInfo_Value( take, "D_STARTOFFS" )
        offset_quantized = reaper.SnapToGrid( 0, offset ) -- NOTE: Not friendly with variable grid size
        grid_offset = offset - offset_quantized
        value = reaper.SnapToGrid( 0, value ) + grid_offset
        if value > retval then
          value = reaper.BR_GetPrevGridDivision( value ) -- quantize left
        end
        if value < 0 then
          value = reaper.BR_GetNextGridDivision( value ) -- quantize left
        end
      end
      reaper.SetMediaItemTakeInfo_Value( take, "D_STARTOFFS", value )
      
    end
  end

end


-- INIT

-- See if there is items selected
count_sel_items = reaper.CountSelectedMediaItems(0)

if count_sel_items > 0 then

  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  main()

  reaper.Undo_EndBlock("Shift selected takes source audio content position randomly", -1) -- End of the undo block. Leave it at the bottom of your main function.

  reaper.UpdateArrange()

  reaper.PreventUIRefresh(-1)
  
end
