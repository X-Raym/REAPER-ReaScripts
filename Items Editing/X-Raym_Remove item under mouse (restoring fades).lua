--[[
 * ReaScript Name: Remove item under mouse (restoring fades)
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Screenshot: https://i.imgur.com/JKg1ExJ.gifv
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Editing (various)
 * Forum Thread URI: https://forum.cockos.com/showthread.php?t=163363
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2019-10-01)
  + Initial Release
--]]


-- USER CONFIG AREA -----------------------------------------------------------

console = true -- true/false: display debug messages in the console

------------------------------------------------------- END OF USER CONFIG AREA


-- UTILITIES -------------------------------------------------------------

-- Save item selection
function SaveSelectedItems (table)
  for i = 0, reaper.CountSelectedMediaItems(0)-1 do
    table[i+1] = reaper.GetSelectedMediaItem(0, i)
  end
end

function RestoreSelectedItems (table)
  reaper.Main_OnCommand(40289 ,0)
  for _, item in ipairs(table) do
    if reaper.ValidatePtr(item, "MediaItem*") then
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
function main()
  reaper.Main_OnCommand(40289 ,0) -- Item: Unselect all items
  reaper.Main_OnCommand(40528, 0) -- Item: Select item under mouse cursor
  init_ripple = reaper.SNM_GetIntConfigVar( "projripedit", -666 )
  init_env_attach = reaper.SNM_GetIntConfigVar( "envattach", -666 )
  reaper.SNM_SetIntConfigVar( "projripedit", 0 )
  reaper.SNM_SetIntConfigVar( "envattach", 0 )
  reaper.Main_OnCommand(40006, 0) -- Item: Remove items
  reaper.SNM_SetIntConfigVar( "projripedit", init_ripple )
  reaper.SNM_SetIntConfigVar( "envattach", init_env_attach )
end


-- INIT

-- See if there is items selected
count_sel_items = reaper.CountSelectedMediaItems(0)



  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
  
  init_sel_items =  {}
  SaveSelectedItems(init_sel_items)

  main()
  
  RestoreSelectedItems (init_sel_items)

  reaper.Undo_EndBlock("Remove item under mouse (restoring fades)", -1) -- End of the undo block. Leave it at the bottom of your main function.

  reaper.UpdateArrange()

  reaper.PreventUIRefresh(-1)
  

