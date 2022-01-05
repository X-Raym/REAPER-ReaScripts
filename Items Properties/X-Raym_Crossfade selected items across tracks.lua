--[[
 * ReaScript Name: Crossfade selected items across tracks
 * Screenshot: https://i.imgur.com/4g2KFp1.gif
 * Instructions: Select items. Run
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Item Fades (various)
 * Forum Thread URI: https://forum.cockos.com/showthread.php?p=1538659
 * REAPER: 5.0
 * Version: 1.0.1
--]]

--[[
 * Changelog:
 * v1.0.1 (2020-08-17)
  + Fade in fix
 * v1.0 (2018-02-02)
  + Initial Release
--]]


-- UTILITIES -------------------------------------------------------------

-- Save item selection
function SaveSelectedItems (tab)
  for i = 0, reaper.CountSelectedMediaItems(0)-1 do
    local entry = {}
    entry.item = reaper.GetSelectedMediaItem(0, i)
    entry.track = reaper.GetMediaItemTrack(entry.item)

    entry.item_properties = {}
    entry.item_properties.D_FADEINDIR = reaper.GetMediaItemInfo_Value(entry.item, "D_FADEINDIR" )
    entry.item_properties.D_FADEOUTDIR = reaper.GetMediaItemInfo_Value(entry.item, "D_FADEOUTDIR" )
    entry.item_properties.C_FADEINSHAPE = reaper.GetMediaItemInfo_Value(entry.item, "C_FADEINSHAPE" )
    entry.item_properties.C_FADEOUTSHAPE = reaper.GetMediaItemInfo_Value(entry.item, "C_FADEOUTSHAPE" )

    table.insert(tab, entry)
  end
end

--------------------------------------------------------- END OF UcTILITIES


-- Main function
function main()

  reaper.Main_OnCommand(40644,0) -- Item: Implode items across tracks into items on one track
  reaper.Main_OnCommand(41059,0) -- Item: Crossfade any overlapping items


  --[[ fix 1.0.1. Why this code ?
  for i, entry in ipairs(init_sel_items) do
    local value = reaper.GetMediaItemInfo_Value(entry.item, "D_FADEINLEN_AUTO" )
    reaper.SetMediaItemInfo_Value( entry.item, "D_FADEINLEN", value )
  end
  ]]

  for i, entry in ipairs(init_sel_items) do
    reaper.MoveMediaItemToTrack( entry.item, entry.track )
    for key, value in pairs( entry.item_properties ) do
      reaper.SetMediaItemInfo_Value( entry.item, key, value )
    end
  end

end


-- INIT

-- See if there is items selected
count_sel_items = reaper.CountSelectedMediaItems(0)

if count_sel_items > 0 then

  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  init_sel_items =  {}
  SaveSelectedItems(init_sel_items)

  main()

  reaper.Undo_EndBlock("Crossfade selected items across tracks", -1) -- End of the undo block. Leave it at the bottom of your main function.

  reaper.UpdateArrange()

  reaper.PreventUIRefresh(-1)

end
