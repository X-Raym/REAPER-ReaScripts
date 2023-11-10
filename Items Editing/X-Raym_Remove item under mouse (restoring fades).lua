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
 * Version: 1.1
--]]

--[[
 * Changelog:
 * v1.1 (2023-11-03)
  + Restore fades based on crossfades
  + Call Script: X-Raym_Remove item under mouse (restoring fades).lua in ripple state if avalaible
  + No SWS
 * v1.0 (2019-10-01)
  + Initial Release
--]]


-- USER CONFIG AREA -----------------------------------------------------------

ripple_action = "_RS88ecaa7021f5d9e9a7edb638dec3d452e6311b33" -- ID string or number
console = true -- true/false: display debug messages in the console

------------------------------------------------------- END OF USER CONFIG AREA

ripple_action = reaper.NamedCommandLookup( ripple_action )
ripple_action = ripple_action > 0 and ripple_action or 40006 -- 40006 is no ripple

-- UTILITIES -------------------------------------------------------------


-- Display a message in the console for debugging
function Msg(value)
  if console then
    reaper.ShowConsoleMsg(tostring(value) .. "\n")
  end
end

--------------------------------------------------------- END OF UTILITIES

function IsInTime( s, start_time, end_time )
  if s >= start_time and s <= end_time then return true end
  return false
end

-- Main function
function Main()
  reaper.Main_OnCommand(40289 ,0) -- Item: Unselect all items
  reaper.Main_OnCommand(40528, 0) -- Item: Select item under mouse cursor
  mouse_item = reaper.GetSelectedMediaItem(0,0)
  if not mouse_item then return false end

  mouse_item_pos = reaper.GetMediaItemInfo_Value( mouse_item, "D_POSITION" )
  mouse_item_len = reaper.GetMediaItemInfo_Value( mouse_item, "D_LENGTH" )
  mouse_item_end = mouse_item_pos + mouse_item_len

  mouse_track = reaper.GetMediaItemTrack( mouse_item )
  count_items_track = reaper.CountTrackMediaItems( mouse_track )

  for i = 0, count_items_track - 1 do
    local item = reaper.GetTrackMediaItem( mouse_track, i )
    local item_pos = reaper.GetMediaItemInfo_Value( item, "D_POSITION" )
    local item_len = reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )
    local item_end = item_pos + item_len

    if item_pos > mouse_item_end then break end

    -- Right Fade
    if not IsInTime( item_pos, mouse_item_pos, mouse_item_end ) and IsInTime( item_end, mouse_item_pos, mouse_item_end ) then
      local item_fade = reaper.GetMediaItemInfo_Value( item, "D_FADEOUTLEN_AUTO" )
      reaper.SetMediaItemInfo_Value( item, "D_FADEOUTLEN", item_fade )
    end

    -- Left Fade
    if IsInTime( item_pos, mouse_item_pos, mouse_item_end ) and not IsInTime( item_end, mouse_item_pos, mouse_item_end ) then
      local item_fade = reaper.GetMediaItemInfo_Value( item, "D_FADEINLEN_AUTO" )
      reaper.SetMediaItemInfo_Value( item, "D_FADEINLEN", item_fade )
    end
  end

  if init_ripple > 0 then
    -- reaper.Main_OnCommand( reaper.NamedCommandLookup( "_RSeae17866577002490d8a62b72bbe7f939970eb70" ), 0 ) -- Script: X-Raym_Delete selected items and ripple edit adjacent items.lua
    reaper.Main_OnCommand( ripple_action, 0 ) -- Script: X-Raym_Delete selected items preserving crossfades and conditionally ripple by min item pos to max item end fade-out duration.lua
  else
    reaper.Main_OnCommand(40006, 0) -- Item: Remove items
  end
end


-- INIT
reaper.PreventUIRefresh(1)

reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

-- init_ripple = reaper.SNM_GetIntConfigVar( "projripedit", -666 )
init_ripple = reaper.GetToggleCommandState( 1155 ) -- Options: Cycle ripple editing mode

Main()

reaper.Undo_EndBlock("Remove item under mouse (restoring fades)", -1) -- End of the undo block. Leave it at the bottom of your main function.

reaper.UpdateArrange()

reaper.PreventUIRefresh(-1)


