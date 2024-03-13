--[[
 * ReaScript Name: Set selected tracks record input to X
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
 * MetaPackage: true
 * Provides:
 *   [main] . > X-Raym_Set selected tracks record input to audio mono 1.lua
 *   [main] . > X-Raym_Set selected tracks record input to audio mono 2.lua
 *   [main] . > X-Raym_Set selected tracks record input to audio mono 3.lua
 *   [main] . > X-Raym_Set selected tracks record input to audio mono 4.lua
 *   [main] . > X-Raym_Set selected tracks record input to all MIDI all channel.lua
--]]

--[[
 * Changelog:
 * v1.0 (2024-02-06)
  + Initial release
--]]

-- USER CONFIG AREA -----------------------------

-- Use Preset Script for safe moding or to create a new action with your own values
-- https://github.com/X-Raym/REAPER-ReaScripts/tree/master/Templates/Script%20Preset

force_input = 4096+(63<<5)+1 -- 4096+(63<<5)+1 for All MIDI All Channel Fallback

-------------------------------------------------

function Main()
  script_name = ({reaper.get_action_context()})[2]:match("([^/\\_]+)%.lua$")
  --script_name = "X-Raym_Set selected tracks record input to audio mono 1.lua"
  
  set_track_input = tonumber( script_name:match("(%d+)") ) or force_input
  set_track_input = math.max(set_track_input, 0) - 1 -- 0 based
  
  for i = 0, count_sel_tracks - 1 do
    local track = reaper.GetSelectedTrack( 0, i )
    local track_input = reaper.GetMediaTrackInfo_Value(track, "I_RECINPUT")
    if track_input ~= set_track_input then
      reaper.SetMediaTrackInfo_Value(track, "I_RECINPUT", set_track_input )
    end
  end
end

function Init()
  count_sel_tracks = reaper.CountSelectedTracks( 0 )
  if count_sel_tracks == 0 then return end
  
  reaper.PreventUIRefresh( 1 )
  
  reaper.Undo_BeginBlock()
  
  Main()
  
  reaper.TrackList_AdjustWindows( false )
  
  reaper.Undo_EndBlock( script_name, 0 )
  
  reaper.PreventUIRefresh( - 1 )
end

if not preset_file_init then
  Init()
end
