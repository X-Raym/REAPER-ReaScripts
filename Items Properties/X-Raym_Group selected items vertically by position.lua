--[[
 * ReaScript Name: Group selected items vertically by position
 * Screenshot: https://i.imgur.com/3ckIcBh.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Properties (various)
 * Forum Thread URI: https://forum.cockos.com/showthread.php?t=166689
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2021-02-10)
  + Initial Release
--]]


-- USER CONFIG AREA -----------------------------------------------------------

console = true -- true/false: display debug messages in the console

------------------------------------------------------- END OF USER CONFIG AREA


-- UTILITIES -------------------------------------------------------------

-- Save item selection
function SaveSelectedItemsByPositions(tab)
  local count_sel_items = reaper.CountSelectedMediaItems(0)
  for i = 0, count_sel_items - 1 do
    local item = reaper.GetSelectedMediaItem(0, i)
    local pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    if not tab[pos] then tab[pos] = {} end
    table.insert( tab[pos], item )
  end
end

-- RESTORE INITIAL SELECTED ITEMS
local function RestoreSelectedItemsByKey(table)
  reaper.SelectAllMediaItems(0,false)
  for k, items in pairs( table ) do
    for i, item in ipairs(items) do
      reaper.SetMediaItemSelected(item, true)
    end
  end
end


-- Display a message in the console for debugging
function Msg(value)
  if console then
    reaper.ShowConsoleMsg(tostring(value) .. "\n")
  end
end

--------------------------------------------------------- END OF UTILITIES


-- Main function
function Main()

  for pos, items in pairs( init_sel_items ) do

    reaper.SelectAllMediaItems( 0, false )
    for i, item in ipairs( items ) do
      reaper.SetMediaItemSelected( item , true )
    end
    reaper.Main_OnCommand( 40032, 0 )-- Item grouping: Group items

  end

end


-- INIT

-- See if there is items selected
count_sel_items = reaper.CountSelectedMediaItems(0)

if count_sel_items > 0 then

  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  init_sel_items =  {}
  SaveSelectedItemsByPositions(init_sel_items)

  Main()

  RestoreSelectedItemsByKey(init_sel_items)

  reaper.Undo_EndBlock("Group selected items vertically by position", -1) -- End of the undo block. Leave it at the bottom of your main function.

  reaper.UpdateArrange()

  reaper.PreventUIRefresh(-1)

end
