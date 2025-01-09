--[[
 * ReaScript Name: Take FX list (ReaImGui)
 * Screenshot: https://i.imgur.com/RCLyEnM.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Licence: GPL v3
 * Version: 1.1.5
--]]

--[[
 * Changelog:
 * v1.1.5 (2025-01-09)
  # Exit via context menu
 * v1.1.3 (2025-01-06)
  # Renamed with ReaImGui suffix
  # ReaImGui v0.9.3.2
  # Dark Theme
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
reaimgui_force_version = "0.9.3.2"
bypass_color = "#FF0000"
offline_color = "888888"

----------------------------------------------------------------------
                                         -- END OF USER CONFIG AREA --
----------------------------------------------------------------------

----------------------------------------------------------------------
-- GLOBALS --
----------------------------------------------------------------------

input_title = "XR - Take FX List"

local theme_colors = {
  WindowBg          = 0x292929ff, -- Window
  Border            = 0x2a2a2aff, -- Border
  Button            = 0x454545ff, -- Button
  ButtonActive      = 0x404040ff, -- Button and Top resize
  ButtonHovered     = 0x606060ff,
  FrameBg           = 0x454545ff, -- Input text BG
  FrameBgHovered    = 0x606060ff,
  FrameBgActive     = 0x404040ff,
  TitleBg           = 0x292929ff, -- Title
  TitleBgActive     = 0x000000ff,
  Header            = 0x323232ff, -- Selected rows
  HeaderHovered     = 0x323232ff,
  HeaderActive      = 0x05050587,
  ResizeGrip        = 0x323232ff, -- Resize
  ResizeGripHovered = 0x323232ff,
  ResizeGripActive  = 0x05050587,
  TextSelectedBg    = 0x05050587, -- Search Field Selected Text
  CheckMark         = 0xffffffff, -- CheckMark
}

------------------------------------------------------------
-- DEPENDENCIES --
------------------------------------------------------------

imgui_path = reaper.ImGui_GetBuiltinPath and ( reaper.ImGui_GetBuiltinPath() .. '/imgui.lua' )

if not imgui_path then
  reaper.MB("Missing dependency: ReaImGui extension.\nDownload it via Reapack ReaTeam extension repository.", "Error", 0)
  return false
end

local ImGui = dofile(imgui_path) (reaimgui_force_version)

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
  return ImGui.ColorConvertDouble4ToU32( r/255, g/255, b/255, a or 1 )
end

----------------------------------------------------------------------
-- IMGUI --
----------------------------------------------------------------------

function SetThemeColors(ctx)
  local count_theme_colors = 0
  for k, color in pairs( theme_colors ) do
    local color_str = reaper.GetExtState( "XR_ImGui_Col", k )
    if color_str ~= "" then
      color = tonumber( color_str, 16 )
    end
    ImGui.PushStyleColor(ctx, ImGui["Col_" .. k ], color )
    count_theme_colors = count_theme_colors + 1
  end
  return count_theme_colors
end

-- From cfillion
function about()
  local owner = reaper.ReaPack_GetOwner(({reaper.get_action_context()})[2])

  if not owner then
    reaper.MB(string.format(
      'This feature is unavailable because this script was not installed using ReaPack.',
      "Warning"), "Warning", 0)
    return
  end

  reaper.ReaPack_AboutInstalledPackage(owner)
  reaper.ReaPack_FreeEntry(owner)
end

function contextMenu()
  local dock_id = ImGui.GetWindowDockID(ctx)
  if not ImGui.BeginPopupContextWindow(ctx, nil, ImGui.PopupFlags_MouseButtonRight | ImGui.PopupFlags_NoOpenOverItems) then return end
  if ImGui.BeginMenu(ctx, 'Dock window') then
    if ImGui.MenuItem(ctx, 'Floating', nil, dock_id == 0) then
      set_dock_id = 0
    end
    for i = 0, 15 do
      if ImGui.MenuItem(ctx, ('Docker %d'):format(i + 1), nil, dock_id == ~i) then
        set_dock_id = ~i
      end
    end
    ImGui.EndMenu(ctx)
  end
  ImGui.Separator(ctx)
  if ImGui.MenuItem(ctx, 'About/help', 'F1', false, reaper.ReaPack_GetOwner ~= nil) then
    about()
  end
  if ImGui.MenuItem(ctx, 'Close', 'Escape') then
    exit = true
  end
  ImGui.EndPopup(ctx)
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
  ImGui.Text( ctx, take_name )
  ImGui.Spacing( ctx )
  count_fx = reaper.TakeFX_GetCount( take )
  if count_fx == 0 then return end

  if ImGui.BeginTable(ctx, '##table_output', 2,  ImGui.TableFlags_SizingFixedFit ) then
    ImGui.TableHeadersRow(ctx)
    ImGui.TableSetColumnIndex(ctx, 0)
    ImGui.TableHeader( ctx, "FX" )
    ImGui.TableSetColumnIndex(ctx, 1)
    ImGui.TableHeader( ctx, "Online" )

    -- One row per FX
    for i = 0, count_fx - 1 do
      local retval, take_fx_name = reaper.TakeFX_GetFXName( take, i )

      local take_fx_enable = reaper.TakeFX_GetEnabled( take, i )
      local take_fx_offline = reaper.TakeFX_GetOffline( take, i )

      if take_fx_offline then
        ImGui.PushStyleColor(ctx,  ImGui.Col_Text, offline_color_int)
      elseif not take_fx_enable then
        ImGui.PushStyleColor(ctx,  ImGui.Col_Text, bypass_color_int)
      end

      ImGui.TableNextRow(ctx)

      ImGui.TableSetColumnIndex(ctx, 0)

      local retval, retval_enable = ImGui.Checkbox( ctx, take_fx_name, take_fx_enable )
      if retval then
        reaper.TakeFX_SetEnabled( take, i, retval_enable )
      end

      ImGui.TableSetColumnIndex(ctx, 1)

      local retval, retval_offline = ImGui.Checkbox( ctx, "##offline" .. i, not take_fx_offline )
      if retval then
        reaper.TakeFX_SetOffline( take, i, not retval_offline )
      end

      if take_fx_offline or not take_fx_enable then
        ImGui.PopStyleColor(ctx, 1)
      end

    end

    ImGui.EndTable(ctx)
  end

end

function Run()

  ImGui.SetNextWindowBgAlpha( ctx, 1 )

  if set_dock_id then
    ImGui.SetNextWindowDockID(ctx, set_dock_id)
    set_dock_id = nil
  end

  count_theme_colors = SetThemeColors( ctx )

  ImGui.PushFont(ctx, font)
  ImGui.SetNextWindowSize(ctx, 800, 200, ImGui.Cond_FirstUseEver)

  local imgui_visible, imgui_open = ImGui.Begin(ctx, input_title, true, ImGui.WindowFlags_NoCollapse)

  if imgui_visible then

    contextMenu()

    imgui_width, imgui_height = ImGui.GetWindowSize( ctx )

    --------------------
    Main()

    ImGui.End(ctx)
  end

  ImGui.PopStyleColor(ctx, count_theme_colors)
  ImGui.PopFont(ctx)

  if imgui_open and not ImGui.IsKeyPressed(ctx, ImGui.Key_Escape) and not process and not exit then
    reaper.defer(Run)
  end

end -- END DEFER


----------------------------------------------------------------------
-- RUN --
----------------------------------------------------------------------

function Init()
  SetButtonState( 1 )
  reaper.atexit( Exit )

  ctx = ImGui.CreateContext( input_title, ImGui.ConfigFlags_DockingEnable | ImGui.ConfigFlags_NavEnableKeyboard )
  ImGui.SetConfigVar( ctx, ImGui.ConfigVar_DockingNoSplit, 1 )
  font = ImGui.CreateFont('sans-serif', 16)
  ImGui.Attach(ctx, font)

  offline_color_int = HexToIntReaImGUI(offline_color)
  bypass_color_int = HexToIntReaImGUI(bypass_color)

  Run()
end

if not preset_file_init then
  Init()
end
