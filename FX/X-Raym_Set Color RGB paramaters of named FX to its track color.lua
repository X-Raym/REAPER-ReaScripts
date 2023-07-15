--[[
 * ReaScript Name: Set Color RGB paramaters of named FX to its track color
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: https://github.com/X-Raym/REAPER-Scripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0.2
--]]

--[[
 * Changelog:
 * v1.0.2 (2023-07-15)
  + New name
 * v1.0.1 (2023-07-14)
  + Change FX name
 * v1.0 (2022-08-27)
  + Initial release
--]]

-- USER CONFIG AREA -----------------------------------------------------------

name = "JS: JSH Inline Input Viewer (MCP embedded) [Manwë_Inline Input Viewer (MCP embedded).jsfx]"
default_r = 255
default_g = 255
default_b = 255

undo_text = "Set Color RGB paramaters of named FX to its track color"

------------------------------------------------------- END OF USER CONFIG AREA

function Main()
  local count_tracks  = reaper.CountTracks()
  for i = 0, count_tracks - 1 do
    local track = reaper.GetTrack( 0, i )
    local count_fx = reaper.TrackFX_GetCount( track )
    for fx_id = 0, count_fx - 1 do
      local retval, fx_name = reaper.TrackFX_GetFXName( track, fx_id )
      if fx_name == name then
        local track_color = reaper.GetMediaTrackInfo_Value( track, "I_CUSTOMCOLOR" )
        local r, g, b
        if track_color == 0 then
          r, g, b = default_r, default_g, default_b
        else
          r, g, b = reaper.ColorFromNative( track_color )
        end
        local count_param = reaper.TrackFX_GetNumParams( track, fx_id, param_id )
        local all_done = 0
        for param_id = 0, count_param - 1 do
          local retval, param_name = reaper.TrackFX_GetParamName( track, fx_id, param_id )
          if param_name == "Color R" then
            reaper.TrackFX_SetParam( track, fx_id, param_id, r )
            all_done = all_done + 1
          end
          if param_name == "Color G" then
            reaper.TrackFX_SetParam( track, fx_id, param_id, g )
            all_done = all_done + 1
          end
          if param_name == "Color B" then
            reaper.TrackFX_SetParam( track, fx_id, param_id, b )
            all_done = all_done + 1
          end
          if all_done == 3 then break end
        end
      end
    end
  end
end

function Init()
  reaper.Undo_BeginBlock()

  Main()

  reaper.Undo_BeginBlock(undo_text,-1)
end

if not preset_file_init then
  Init()
end
