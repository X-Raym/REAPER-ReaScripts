--[[
 * ReaScript Name: Toggle Sonarworks SoundID monitor FX instance Calibration state
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts/
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.2
--]]

--[[
 * Changelog:
 * v1.2 (2024-11-14)
  # Remove defer
 * v1.1 (2021-12-05)
  + Works at startup with X-Raym_Toggle SWS global startup actions exstate value.lua
 * v1.0 (2021-12-05)
  + Initial Release
--]]

-- USER CONFIG AREA ---------------------
fx_name = "VST3: SoundID Reference Plugin (Sonarworks) (16ch)"
param_name = "Calibration state"

ext_name = "XR_SWSGlobalStartupAction"
ext_key = "IsRunning"
-----------------------------------------

function Msg( val )
  reaper.ShowConsoleMsg(tostring(val).."\n")
end

-- Set ToolBar Button State
function SetButtonState( set )
  local is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  reaper.SetToggleCommandState( sec, cmd, set or 0 )
  reaper.RefreshToolbar2( sec, cmd )
end

function Main()

  is_sws_startup = reaper.GetExtState(ext_name, ext_key)

  master_track = reaper.GetMasterTrack(0)
  fx_id = reaper.TrackFX_AddByName( master_track, fx_name, true, 0)

  if fx_id == -1 then return false end

  fx_id = fx_id|0x1000000

  count_param = reaper.TrackFX_GetNumParams(master_track, fx_id)

  for i = 0, count_param do
    local retval, fx_param_name = reaper.TrackFX_GetParamName(master_track, fx_id, i)
    if fx_param_name == param_name then
      param_val = reaper.TrackFX_GetParamNormalized(master_track, fx_id, i)
      if is_sws_startup ~= "true" then
        if param_val == 0 then param_val = 1 else param_val = 0 end
        reaper.TrackFX_SetParamNormalized(master_track, fx_id, i, param_val)
        mouse_x, mouse_y = reaper.GetMousePosition()
        reaper.TrackCtl_SetToolTip("SoundID Calibration set to " .. param_val, mouse_x + 17, mouse_y + 17, true)
      end
      SetButtonState( param_val )
      break
    end
  end

end

reaper.ClearConsole()

if not preset_file_init then
  Main()
end
