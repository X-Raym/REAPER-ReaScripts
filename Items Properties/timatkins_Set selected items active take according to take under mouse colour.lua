--[[
 * ReaScript Name: Set selected items active take according to take under mouse colour 
 * Description: Gets colour of take under mouse cursor, then makes any takes of the same colour in all selected items the selected take, or first take if multiples of same colour in an item. Disable console message by changing if console == true to false. 
 * Instructions: Select all items, hover mouse over take of colour required, 
 * Author: timatkins & X-Raym
 * Author URI: http://www.iamtimatkins.com and http://extremraym.com
 * Repository: 
 * Repository URI: 
 * File URI:
 * Licence: GPL v3
 * Forum Thread: Show takes of a set colour
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=166143
 * REAPER: 5.11 
 * Extensions: SWS/S&M 2.8.2 #0
 * Version: 1.0
]]
 
--[[
 * Changelog:
 * v1.0 (2016-01-04)
  + Initial Release
]]




console = false -- true/false: display the messages in the console

function Msg(param)
  if console == true then
      reaper.ShowConsoleMsg (tostring(param).."\n")
    end
end

function Select_Alt_Takes ()

  -- get take under mouse
  item_take, item_pos = reaper.BR_TakeAtMouseCursor ()
  
  -- if there is a take under mouse, get its color and do the next part of the scriot
  if item_take ~= nil then 
    
    reaper.PreventUIRefresh(1)
    reaper.Undo_BeginBlock()
    
    reaper.SetActiveTake(item_take)
    
    item_mouse = reaper.GetMediaItemTake_Item(item_take)
    
    reaper.SetMediaItemSelected(item_mouse, true)

    mouse_item_col = reaper.GetMediaItemTakeInfo_Value (item_take, "I_CUSTOMCOLOR")
    
    --count selected media items
    count_sel_item = reaper.CountSelectedMediaItems (0)

    -- for each seleceted items do
    for i = 0, count_sel_item -1 do

      item = reaper.GetSelectedMediaItem (0,i)

      -- count its number of takes
      take_count = reaper.CountTakes (item)

      -- for each takes, compare its color with color of take undermouse
      for i = 0, take_count - 1 do

        take = reaper.GetMediaItemTake (item, i)

        take_col = reaper.GetMediaItemTakeInfo_Value (take, "I_CUSTOMCOLOR")

        -- if matchs, then set as active take and break take loop
        if take_col == mouse_item_col then

          reaper.SetActiveTake (take) 
          
          break

        end
      end

    end

    reaper.Undo_EndBlock("Set selected items active take according to take under mouse colour", -1)
    -- update arrange
    reaper.UpdateArrange ()
    reaper.PreventUIRefresh(-1)

  else
      Msg ("No item selected.")

  end

end

-- INIT
if console == true then
  reaper.ClearConsole()
end
 
Select_Alt_Takes()
