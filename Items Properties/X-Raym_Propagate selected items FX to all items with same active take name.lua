--[[
 * ReaScript Name: Propagate selected items FX to all items with same active take name
 * About: Move group of selected items to next item end on all visible tracks, according to max end of items in selection.
 * Instructions: Select items. Run.
 * Screenshot: https://i.imgur.com/pVX9uGN.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Properties (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1574697#post1574697
 * REAPER: 5.0
 * Extensions: SWS 2.8.0
 * Version: 2.0
--]]

--[[
 * Changelog:
 * v2.0 (2022-11-08)
   # New core (better performance)
   + Propagate no FX
 * v1.0.1 (2020-11-12)
   # empty item fix
 * v1.0 (2015-09-22)
  + Initial Release
--]]

-- ---------- DEBUG =========>
function Msg(variable)
  reaper.ShowConsoleMsg(tostring(variable).."\n")
end
-- <------------- END OF DEBUG


function CountItem( all )
  if all then
    return reaper.CountMediaItems(0)
  else
    return reaper.CountSelectedMediaItems(0)
  end
end

function GetItem( i, all )
  if all then
    return reaper.GetMediaItem(0, i)
  else
    return reaper.GetSelectedMediaItem(0, i)
  end
end

-- ---------- INIT ITEMS SELECTION =========>
function SaveItemsTakeByName( all )

  local take_names = {}
  local items = {}
  local count_items = CountItem( all )
  
  for i = 0, count_items - 1 do

    local item = GetItem( i, all )
    
    if not all or (all and not reaper.IsMediaItemSelected( item )) then -- All Items are in fact Unselected items
      
      table.insert(items, item)
      
      local take = reaper.GetActiveTake(item)
      if take then
        local take_name = reaper.GetTakeName( take )
        if not take_names[take_name] then take_names[take_name] = {} end
        table.insert( take_names[take_name], item )
      end
      
    end

  end
  
  return take_names, items
end

-- RESTORE
function RestoreSelItems()
  reaper.SelectAllMediaItems(0, false) -- unselect all items
  for i, sel_item in ipairs(sel_items) do
    reaper.SetMediaItemSelected(sel_item, true)
  end
end

-- <-------------- END OF SAVE INIT ITEM SELECTION

-- ---------- MAIN FUNCTION =========>
function Main()

  sel_take_names, sel_items = SaveItemsTakeByName()
  all_take_names, all_items = SaveItemsTakeByName( true )  -- All Items are in fact Unselected items

  -- LOOP IN ALL ITEMS
  for name, name_sel_items in pairs(sel_take_names) do
  
    if all_take_names[name] then -- if there is at least

      reaper.SelectAllMediaItems(0, false) -- unselect all items
      reaper.SetMediaItemSelected(name_sel_items[1], true) -- Select only one item
      
      local sel_take = reaper.GetActiveTake( name_sel_items[1] )
      local count_take_fx = reaper.TakeFX_GetCount( sel_take )
      
      if count_take_fx > 0 then
        reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_COPYFXCHAIN1"), 0) -- Copy FX chain from selected item
      end
      reaper.SelectAllMediaItems(0, false) -- unselect all items
      
      -- LOOP IN ALL ITEMS
      for i, item in ipairs( all_take_names[name] ) do
        reaper.SetMediaItemSelected(item, true) -- Select items
      end
      
      if count_take_fx > 0 then
        reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_COPYFXCHAIN3"), 0) -- SWS/S&M: Paste (replace) FX chain to selected items
      else
        reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_CLRFXCHAIN1"), 0) -- SWS/S&M: Clear FX chain for selected items
      end
                
    end

  end -- LOOP IN INIT SEL ITEMS

end
-- <---------------------- END OF MAIN

-- ---------- COUNT SEL ITEMS =========>
count_sel_items = reaper.CountSelectedMediaItems(0)
if count_sel_items > 0 then -- IF item selected

  reaper.PreventUIRefresh(1)
  
  reaper.Undo_BeginBlock()

  Main() -- Run
  
  RestoreSelItems()
  
  reaper.Undo_EndBlock("Propagate selected items FX to all items with same active take name", -1)

  reaper.UpdateArrange()
  reaper.PreventUIRefresh(-1)

end
