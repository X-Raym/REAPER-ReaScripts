--[[
 * ReaScript Name: Move edit cursor to previous frame
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Forum Thread:  Scripts: Transport (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1601342
 * REAPER: 5.0
 * Version: 1.1
--]]

--[[
 * Changelog:
 * v1.1 (2022-08-23)
  # Fix rounding issue
 * v1.0 (2016-01-04)
  + Initial Release
--]]

function RoundToX(number, interval)
  return math.ceil(number/interval) * interval
end

function main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  frameRate, dropFrameOut = reaper.TimeMap_curFrameRate(0)

  frame_duration = 1/frameRate

  cur_pos = reaper.GetCursorPosition()

  -- MODIFY INFOS
  pos_quantized = RoundToX(cur_pos - frame_duration - 0.000000000001, frame_duration)

  reaper.SetEditCurPos(pos_quantized, true, true)

  reaper.Undo_EndBlock("Move edit cursor to previous frame", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

reaper.PreventUIRefresh(-1)

reaper.UpdateArrange() -- Update the arrangement (often needed)
