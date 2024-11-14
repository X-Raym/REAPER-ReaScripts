--[[
 * ReaScript Name: Toggle Sonarworks SoundID monitor FX instance Speakers and Headphones presets
 * About:
     This works with REAPER presets named Speakers and Headphones.
     Off state of button toolbar will be Speakers, so better place an Headphones icon on the button label.
     Wrap it in a custom action wit hX-Raym_Set SWS global startup action extstate value to On.lua and Off version, so toolbar button reflects it state at reaper startup.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts/
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2024-11-14)
  + Initial Release
--]]

-- USER CONFIG AREA ---------------------
fx_name = "VST3: SoundID Reference Plugin (Sonarworks) (16ch)"
presets = {}
presets[1] = "Speakers"
presets[2] = "Headphones"

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

  retval, presetname = reaper.TrackFX_GetPreset( master_track, fx_id )

  new_presetname = presetname == presets[1] and presets[2] or presets[1]

  if is_sws_startup ~= "true" then -- Toggle if it isn't a reaper startup check
    reaper.TrackFX_SetPreset( master_track, fx_id, new_presetname )
    mouse_x, mouse_y = reaper.GetMousePosition()
    reaper.TrackCtl_SetToolTip("SoundID Preset set to " .. new_presetname, mouse_x + 17, mouse_y + 17, true)
    presetname = new_presetname
  end

  SetButtonState( presetname == presets[2] and 1 or 0 )
end

reaper.ClearConsole()

if not preset_file_init then
  Main()
end
