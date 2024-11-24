--[[
 * ReaScript Name: Paste items-tracks and snap items if selected and snap enabled
 * About: Workarround REAPER paste MIDI item timing bug
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: BUG: MIDI items not pasted correctly to grid
 * Forum Thread URI: https://forum.cockos.com/showthread.php?t=286926
 * REAPER: 7.0
 * Version: 1.1
--]]

--[[
 * Changelog:
 * v1.1 (2024-11-24)
  # Only snap MIDI items
 * v1.0 (2024-11-20)
  + Initial Release
--]]

-- Save item selection
function SaveSelectedItems(t)
  local t = t or {}
  for i = 0, reaper.CountSelectedMediaItems(0)-1 do
    t[i+1] = reaper.GetSelectedMediaItem(0, i)
  end
  return t
end

function RestoreSelectedItems( items )
  reaper.SelectAllMediaItems(0, false)
  for i, item in ipairs( items ) do
    reaper.SetMediaItemSelected( item, true )
  end
end

reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)
reaper.Main_OnCommand( 42398, 0 ) -- Item: Paste items/tracks
if reaper.GetToggleCommandState(1157) and reaper.CountSelectedMediaItems(0) > 0 then
  init_sel_items = SaveSelectedItems()
  for i, item in ipairs( init_sel_items ) do
    local take = reaper.GetActiveTake(item)
    if not take or not reaper.TakeIsMIDI(take) then
      reaper.SetMediaItemSelected(item, false)
    end
  end
  reaper.Main_OnCommand( reaper.NamedCommandLookup( "_SWS_QUANTITESTART2"), 0 ) -- SWS: Quantize item's start to grid (keep length)
  RestoreSelectedItems( init_sel_items )
end
reaper.Undo_EndBlock( "Item: Paste items/tracks", -1 )
reaper.PreventUIRefresh(1)