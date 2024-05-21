--[[
 * ReaScript Name: Set selected tracks record input to X
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0.1
 * MetaPackage: true
 * Provides:
 *   [main] . > X-Raym_Set selected tracks record input to audio mono 1.lua
 *   [main] . > X-Raym_Set selected tracks record input to audio mono 2.lua
 *   [main] . > X-Raym_Set selected tracks record input to audio mono 3.lua
 *   [main] . > X-Raym_Set selected tracks record input to audio mono 4.lua
 *   [main] . > X-Raym_Set selected tracks record input to audio mono 5.lua
 *   [main] . > X-Raym_Set selected tracks record input to audio mono 6.lua
 *   [main] . > X-Raym_Set selected tracks record input to audio mono 7.lua
 *   [main] . > X-Raym_Set selected tracks record input to audio mono 8.lua
 *   [main] . > X-Raym_Set selected tracks record input to audio stereo 1-2.lua
 *   [main] . > X-Raym_Set selected tracks record input to audio stereo 3-4.lua
 *   [main] . > X-Raym_Set selected tracks record input to audio stereo 5-6.lua
 *   [main] . > X-Raym_Set selected tracks record input to audio stereo 7-8.lua
 *   [main] . > X-Raym_Set selected tracks record input to all MIDI all channel.lua
--]]

--[[
 * Changelog:
 * v1.0.1 (2024-05-21)
  # Stereo pairs 1-2, 3-4, 5-6, 7-8
  # All channels for the MIDI version
  # 8 Mono versions
 * v1.0 (2024-02-06)
  + Initial release
--]]

-- USER CONFIG AREA -----------------------------

-- Use Preset Script for safe moding or to create a new action with your own values
-- https://github.com/X-Raym/REAPER-ReaScripts/tree/master/Templates/Script%20Preset

input_fallback = 4096+(63<<5) -- 4096+(63<<5) for All MIDI All Channel Fallback
force_script_name = nil -- Override script name. For debugging.

-------------------------------------------------

function Main()
  script_name = force_script_name or ({reaper.get_action_context()})[2]:match("([^/\\_]+)%.lua$")
  --script_name = "X-Raym_Set selected tracks record input to audio mono 1.lua"
  
  input_num = script_name:match("(%d+)")
  if input_num then
    if script_name:find("stereo") then
      offset = 1024
    end
    set_track_input = (offset or 0) + math.max( tonumber( input_num ), 0) - 1 -- 0 based
  else
    set_track_input = input_fallback
  end
  
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
