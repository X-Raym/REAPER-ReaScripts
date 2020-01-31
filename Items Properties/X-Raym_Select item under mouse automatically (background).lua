--[[
 * ReaScript Name: Select item under mouse automatically (background)
 * Screenshot: https://i.imgur.com/2140P7M.gifv
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Items selection (Various)
 * Forum Thread URI: https://forum.cockos.com/showthread.php?t=163321
 * REAPER: 5.0
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2019-12-12)
  + Initial Release
--]]
 
 -- Set ToolBar Button State
function SetButtonState( set )
  if not set then set = 0 end
  local is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  local state = reaper.GetToggleCommandStateEx( sec, cmd )
  reaper.SetToggleCommandState( sec, cmd, set ) -- Set ON
  reaper.RefreshToolbar2( sec, cmd )
end


-- Main Function (which loop in background)
function main()

  local item, position = reaper.BR_ItemAtMouseCursor()
  
  if item and last_item ~= item then
    reaper.SelectAllMediaItems( 0, false )
    reaper.SetMediaItemSelected( item, true )
    reaper.UpdateItemInProject( item )
    reaper.UpdateArrange()
    last_item = item
    --reaper.Main_OnCommand(reaper.NamedCommandLookup('_BR_FOCUS_ARRANGE_WND'), 1)
    --reaper.Main_OnCommand(reaper.NamedCommandLookup('_S&M_MOUSE_L_CLICK'), 1)
    
    --reaper.Main_OnCommand(reaper.NamedCommandLookup('_S&M_TRACKNOTES'), 1)
    --reaper.Main_OnCommand(reaper.NamedCommandLookup('_S&M_ITEMNOTES'), 1) -- this refresh ssws notes window with new selected items.
    --reaper.Main_OnCommand(reaper.NamedCommandLookup('_RS50b4176339e550745b43cffc901b567b908521f8'), 1)

  end
  
  reaper.defer( main )
  
end

last_item = ""

-- RUN
SetButtonState( 1 )
main()
reaper.atexit( SetButtonState )
