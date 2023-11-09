--[[
 * ReaScript Name: Swap selected items fades
 * About: Select items. Run.
 * Screenshot: https://i.imgur.com/Hd0BhnU.gifv
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Script: Scripts: Item Fades (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1538659
 * REAPER: 5.0 pre 36
 * Version: 1.2
--]]

--[[
 * Changelog:
 * v1.2 (2023-11-10)
  # Change name (Invert to Swap)
 * v1.1 (2023-11-10)
  # Fix shapes and curve (thx reaperblog)
 * v1.0 (2017-09-06)
  + Initial Release
--]]

function Main()

  -- LOOP THROUGH SELECTED ITEMS
  selected_items_count = reaper.CountSelectedMediaItems(0)

  -- INITIALIZE loop through selected items
  for i = 0, selected_items_count-1  do

    -- GET ITEMS
    item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i
    
    -- Get current fade parameters
    fadeInLen = reaper.GetMediaItemInfo_Value(item, "D_FADEINLEN")
    fadeOutLen = reaper.GetMediaItemInfo_Value(item, "D_FADEOUTLEN")
    fadeInCurvature = reaper.GetMediaItemInfo_Value(item, "D_FADEINDIR")
    fadeOutCurvature = reaper.GetMediaItemInfo_Value(item, "D_FADEOUTDIR")
    fadeInShape = reaper.GetMediaItemInfo_Value(item, "C_FADEINSHAPE")
    fadeOutShape = reaper.GetMediaItemInfo_Value(item, "C_FADEOUTSHAPE")
    
    -- Swap fade lengths
    reaper.SetMediaItemInfo_Value(item, "D_FADEINLEN", fadeOutLen)
    reaper.SetMediaItemInfo_Value(item, "D_FADEOUTLEN", fadeInLen)
    
    -- Swap fade shapes
    reaper.SetMediaItemInfo_Value(item, "C_FADEINSHAPE", fadeOutShape)
    reaper.SetMediaItemInfo_Value(item, "C_FADEOUTSHAPE", fadeInShape)
    
    -- Swap fade curvatures
    reaper.SetMediaItemInfo_Value(item, "D_FADEINDIR", -fadeOutCurvature)
    reaper.SetMediaItemInfo_Value(item, "D_FADEOUTDIR", -fadeInCurvature)

  end -- ENDLOOP through selected items

end

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

Main() -- Execute your main function

reaper.Undo_EndBlock("Swap selected items fades", -1) -- End of the undo block. Leave it at the bottom of your main function.

reaper.UpdateArrange() -- Update the arrangement (often needed)

reaper.PreventUIRefresh(-1)  -- Restore UI Refresh. Uncomment it only if the script works.
