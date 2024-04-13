--[[
 * ReaScript Name: Take FX list (ReaImGui)
 * Screenshot: https://i.imgur.com/RCLyEnM.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Licence: GPL v3
 * Version: 1.1.2
--]]

--[[
 * Changelog
 * v1.1.2 (2024-04-13)
  # Force reaimgui version
 * v1.1 (2023-02-23)
  # Column layout
  # Colors
 * v1.1 (2023-02-22)
  + Offline state
 * v1.0 (2023-02-22)
  + Initial release
--]]

----------------------------------------------------------------------
-- USER CONFIG AREA --
----------------------------------------------------------------------

console = true -- Display debug messages in the console
reaimgui_force_version = "0.8.7.6" -- false or string like "0.8.4"
bypass_color = "#FF0000"
offline_color = "888888"

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

function HexToRGB( value )

  local hex = value:gsub( "#", "" )
  local R = tonumber( "0x"..hex:sub( 1,2 ) ) or 0
  local G = tonumber( "0x"..hex:sub( 3,4 ) ) or 0
  local B = tonumber( "0x"..hex:sub( 5,6 ) ) or 0

  return R, G, B

end

function HexToIntReaImGUI( value, a )
  local r, g, b = HexToRGB( value )
  return reaper.ImGui_ColorConvertDouble4ToU32( r/255, g/255, b/255, a or 1 )
end

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

  if reaper.ImGui_BeginTable(ctx, '##table_output', 2,  reaper.ImGui_TableFlags_SizingFixedFit() ) then
    reaper.ImGui_TableHeadersRow(ctx)
    reaper.ImGui_TableSetColumnIndex(ctx, 0)
    reaper.ImGui_TableHeader( ctx, "FX" )
    reaper.ImGui_TableSetColumnIndex(ctx, 1)
    reaper.ImGui_TableHeader( ctx, "Online" )

    -- One row per FX
    for i = 0, count_fx - 1 do
      local retval, take_fx_name = reaper.TakeFX_GetFXName( take, i )

      local take_fx_enable = reaper.TakeFX_GetEnabled( take, i )
      local take_fx_offline = reaper.TakeFX_GetOffline( take, i )

      if take_fx_offline then
        reaper.ImGui_PushStyleColor(ctx,  reaper.ImGui_Col_Text(), offline_color_int)
      elseif not take_fx_enable then
        reaper.ImGui_PushStyleColor(ctx,  reaper.ImGui_Col_Text(), bypass_color_int)
      end

      reaper.ImGui_TableNextRow(ctx)

      reaper.ImGui_TableSetColumnIndex(ctx, 0)

      local retval, retval_enable = reaper.ImGui_Checkbox( ctx, take_fx_name, take_fx_enable )
      if retval then
        reaper.TakeFX_SetEnabled( take, i, retval_enable )
      end

      reaper.ImGui_TableSetColumnIndex(ctx, 1)

      local retval, retval_offline = reaper.ImGui_Checkbox( ctx, "##offline" .. i, not take_fx_offline )
      if retval then
        reaper.TakeFX_SetOffline( take, i, not retval_offline )
      end

      if take_fx_offline or not take_fx_enable then
        reaper.ImGui_PopStyleColor(ctx, 1)
      end

    end

    reaper.ImGui_EndTable(ctx)
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

  offline_color_int = HexToIntReaImGUI(offline_color)
  bypass_color_int = HexToIntReaImGUI(bypass_color)

  Run()
end

if not preset_file_init then
  Init()
end

