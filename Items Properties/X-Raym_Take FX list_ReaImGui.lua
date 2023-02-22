--[[
 * ReaScript Name: Take FX list (ReaImGui)
 * Screenshot: https://i.imgur.com/RCLyEnM.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: X-Raym Premium Scripts
 * Licence: GPL v3
 * Version: 1.0
--]]

--[[
 * Changelog
 * v1.0 (2023-02-22)
  + Initial release
--]]

----------------------------------------------------------------------
-- USER CONFIG AREA --
----------------------------------------------------------------------
console = true -- Display debug messages in the console
reaimgui_force_version = false -- false or string like "0.8.4"

----------------------------------------------------------------------
                                         -- END OF USER CONFIG AREA --
----------------------------------------------------------------------

----------------------------------------------------------------------
-- GLOBALS --
----------------------------------------------------------------------

input_title = "XR - Take FX List"

------------------------------------------------------------
-- DEPENDENCIES --
------------------------------------------------------------

if not reaper.ImGui_CreateContext then
  reaper.MB("Missing dependency: ReaImGui extension.\nDownload it via Reapack ReaTeam extension repository.", "Error", 0)
  return false
end

if reaimgui_force_version then
  reaimgui_shim_file_path = reaper.GetResourcePath() .. '/Scripts/ReaTeam Extensions/API/imgui.lua'
  if reaper.file_exists( reaimgui_shim_file_path ) then
    dofile( reaimgui_shim_file_path )(reaimgui_force_version)
  end
end

------------------------------------------------------------
-- END OF DEPENDENCIES --
------------------------------------------------------------

----------------------------------------------------------------------
-- DEBUG --
----------------------------------------------------------------------

function Msg( value )
  if console then
    reaper.ShowConsoleMsg( tostring( value ) .. "\n" )
  end
end

------------------------------------------------------------
-- DEFER --
------------------------------------------------------------

-- Set ToolBar Button State
function SetButtonState( set )
  local is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  reaper.SetToggleCommandState( sec, cmd, set or 0 )
  reaper.RefreshToolbar2( sec, cmd )
end

function Exit()
  SetButtonState()
end

----------------------------------------------------------------------
-- OTHER --
----------------------------------------------------------------------

----------------------------------------------------------------------
-- RUN --
----------------------------------------------------------------------
function Main()
  item = reaper.GetSelectedMediaItem( 0, 0 )
  if not item then return end
  take = reaper.GetActiveTake( item )
  if not take then return end
  take_name = reaper.GetTakeName( take )
  reaper.ImGui_Text( ctx, take_name )
  reaper.ImGui_Spacing( ctx )
  count_fx = reaper.TakeFX_GetCount( take )
  if count_fx == 0 then return end
  for i = 0, count_fx - 1 do
    local retval, take_fx_name = reaper.TakeFX_GetFXName( take, i )
    local take_fx_enable = reaper.TakeFX_GetEnabled( take, i )
    retval, retval_enable = reaper.ImGui_Checkbox( ctx, take_fx_name, take_fx_enable )
    if retval then
      reaper.TakeFX_SetEnabled( take, i, retval_enable )
    end
  end
end

function Run()

  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_WindowBg(), 0x0F0F0FFF) -- Black opaque background

  reaper.ImGui_PushFont(ctx, font)
  reaper.ImGui_SetNextWindowSize(ctx, 800, 200, reaper.ImGui_Cond_FirstUseEver())

  if set_dock_id then
    reaper.ImGui_SetNextWindowDockID(ctx, set_dock_id)
    set_dock_id = nil
  end

  local imgui_visible, imgui_open = reaper.ImGui_Begin(ctx, input_title, true, reaper.ImGui_WindowFlags_NoCollapse())

  if imgui_visible then

    imgui_width, imgui_height = reaper.ImGui_GetWindowSize( ctx )
    
    --------------------
    Main()

    reaper.ImGui_End(ctx)
  end

  reaper.ImGui_PopStyleColor(ctx) -- Remove black opack background
  reaper.ImGui_PopFont(ctx)

  if process or not imgui_open or reaper.ImGui_IsKeyPressed(ctx, 27) then -- 27 is escaped key
    reaper.ImGui_DestroyContext(ctx)
  else
    reaper.defer(Run)
  end

end -- END DEFER


----------------------------------------------------------------------
-- RUN --
----------------------------------------------------------------------

function Init()
  SetButtonState( 1 )
  reaper.atexit( Exit )

  ctx = reaper.ImGui_CreateContext(input_title,  reaper.ImGui_ConfigFlags_DockingEnable())
  font = reaper.ImGui_CreateFont('sans-serif', 16)
  reaper.ImGui_Attach(ctx, font)

  Run()
end

if not preset_file_init then
  Init()
end

