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
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2024-11-20)
  + Initial Release
--]]

reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)
reaper.Main_OnCommand( 42398, 0 ) -- Item: Paste items/tracks
if reaper.GetToggleCommandState(1157) and reaper.CountSelectedMediaItems(0) > 0 then
  reaper.Main_OnCommand( reaper.NamedCommandLookup( "_SWS_QUANTITESTART2"), 0 ) -- SWS: Quantize item's start to grid (keep length)
end
reaper.Undo_EndBlock( "Item: Paste items/tracks", -1 )
reaper.PreventUIRefresh(1)