--[[
 * ReaScript Name: Bypass inactive take FX of selected items
 * About: this will help to free some RAM, as inactive take FX consumes RAM (but not CPU)
 * Screenshot: https://i.imgur.com/p69W7Vk.gifv
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
 * v1.0 (2018-06-08)
  + Initial release
--]]

-- For Vijay @The AudioVille

-- USER CONFIG AREA -----------------------------------------------------------

console = false -- true/false: display debug messages in the console

------------------------------------------------------- END OF USER CONFIG AREA

-- UTILITIES -------------------------------------------------------------

local reaper = reaper

-- Display a message in the console for debugging
function Msg(value)
  if console then
    reaper.ShowConsoleMsg(tostring(value) .. "\n")
  end
end

--------------------------------------------------------- END OF UTILITIES

-- Main function
function Main()

  for i = 0, count_selected_items - 1 do

    local item = reaper.GetSelectedMediaItem( 0, i )
    local count_takes = reaper.CountTakes( item )
    if count_takes > 0 then
      local active_take = reaper.GetActiveTake( item )
      for j = 0, count_takes - 1 do
        local take = reaper.GetTake(item, j)
        if take ~= active_take then
          local count_fx = reaper.BR_GetTakeFXCount( take )
          for z = 0, count_fx - 1 do
            reaper.TakeFX_SetEnabled( take, z, false )
          end
        end
      end
    end

  end

end

-- INIT

-- See if there is items selected
count_selected_items = reaper.CountSelectedMediaItems(0)

if count_selected_items > 0 then

  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  Main()

  reaper.Undo_EndBlock("Bypass inactive take FX of selected items", -1) -- End of the undo block. Leave it at the bottom of your main function.

  reaper.UpdateArrange()

  reaper.PreventUIRefresh(-1)

end
