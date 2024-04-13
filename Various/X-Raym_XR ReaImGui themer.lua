--[[
 * ReaScript Name: XR ReaImGui themer
 * About: This stripped down version of ReaImGui Demo script Style section is for quick experimentation on ReaImGui colors. May become in the long term a way to style XR scripts.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Licence: GPL v3
 * Version: 0.1.1
--]]

--[[
 * Changelog:
 * v0.1.1 (2024-04-13)
  # Force reaimgui version
 * v0.1 (2023-11-13)
  + Initial release
--]]

----------------------------------------------------------------------
-- USER CONFIG AREA --
----------------------------------------------------------------------

-- Use Preset Script for safe moding or to create a new action with your own values
-- https://github.com/X-Raym/REAPER-ReaScripts/tree/master/Templates/Script%20Preset

console = true -- Display debug messages in the console
reaimgui_force_version = "0.8.7.6"-- false or string like "0.8.4"

----------------------------------------------------------------------
                                         -- END OF USER CONFIG AREA --
----------------------------------------------------------------------

----------------------------------------------------------------------
-- GLOBALS --
----------------------------------------------------------------------

input_title = "XR - ReaImGui themer"

local theme_colors = {
  WindowBg          = 0x292929ff, -- Window
  Border            = 0x2a2a2aff, -- Border
  Button            = 0x454545ff, -- Button
  ButtonActive      = 0x404040ff, -- Button and Top resize
  ButtonHovered     = 0x606060ff,
  FrameBg           = 0x454545ff, -- Input text BG
  FrameBgHovered    = 0x606060ff,
  TitleBg           = 0x292929ff, -- Title
  TitleBgActive     = 0x000000ff,
  Header            = 0x323232ff, -- Selected rows
  HeaderHovered     = 0x323232ff,
  HeaderActive      = 0x05050587,
  ResizeGrip        = 0x323232ff, -- Resize
  ResizeGripHovered = 0x323232ff,
  ResizeGripActive  = 0x05050587,
  TextSelectedBg    = 0x05050587, -- Search Field Selected Text
}

------------------------------------------------------------
-- DEPENDENCIES --
------------------------------------------------------------

if not reaper.ImGui_CreateContext then
  reaper.MB("Missing dependency: ReaImGui extension.\nDownload it via Reapack ReaTeam extension repository.", "Error", 0)
  return false
end

reaimgui_shim_file_path = reaper.GetResourcePath() .. '/Scripts/ReaTeam Extensions/API/imgui.lua'
if reaper.file_exists( reaimgui_shim_file_path ) and reaimgui_force_version then
  dofile( reaimgui_shim_file_path )(reaimgui_force_version)
end

------------------------------------------------------------
-- END OF DEPENDENCIES --
------------------------------------------------------------

----------------------------------------------------------------------
-- DEBUG --
----------------------------------------------------------------------

-- Multi Message function
function Msg( ... )
  if not console then return end
  local args = {...}
  for i, v in ipairs( args ) do
    args[i] = tostring( v )
  end
  reaper.ShowConsoleMsg( table.concat( args ) .. '\n')
end

------------------------------------------------------------
                                          -- DEBUG --
------------------------------------------------------------

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
-- TABLE --
----------------------------------------------------------------------

function GetTableOfSortedKeys( t )
  local keys = {}
  for k, v in pairs( t ) do
    table.insert( keys, k )
  end
  table.sort( keys )
  return keys
end

----------------------------------------------------------------------
                                                    -- END OF TABLE --
----------------------------------------------------------------------

----------------------------------------------------------------------
-- OTHER --
----------------------------------------------------------------------

function spairs(t, order) -- Iterate in associative table by value order
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end

end

function rgbaToHex(r, g, b, a, prefix)
  prefix = prefix or "#"
  return prefix .. string.format("%0.2X%0.2X%0.2X%0.2X", r, g, b, a)
end

----------------------------------------------------------------------
                                                    -- END OF OTHER --
----------------------------------------------------------------------

----------------------------------------------------------------------
-- IMGUI --
----------------------------------------------------------------------

-- From cfillion
function about()
  local owner = reaper.ReaPack_GetOwner(({reaper.get_action_context()})[2])

  if not owner then
    reaper.MB(string.format(
      'This feature is unavailable because "%s" was not installed using ReaPack.',
      "Warning"), "Warning", 0)
    return
  end

  reaper.ReaPack_AboutInstalledPackage(owner)
  reaper.ReaPack_FreeEntry(owner)
end

function contextMenu()
  local dock_id = reaper.ImGui_GetWindowDockID(ctx)
  if not reaper.ImGui_BeginPopupContextWindow(ctx, nil, reaper.ImGui_PopupFlags_MouseButtonRight() | reaper.ImGui_PopupFlags_NoOpenOverItems()) then return end
  if reaper.ImGui_BeginMenu(ctx, 'Dock window') then
    if reaper.ImGui_MenuItem(ctx, 'Floating', nil, dock_id == 0) then
      set_dock_id = 0
    end
    for i = 0, 15 do
      if reaper.ImGui_MenuItem(ctx, ('Docker %d'):format(i + 1), nil, dock_id == ~i) then
        set_dock_id = ~i
      end
    end
    reaper.ImGui_EndMenu(ctx)
  end
  reaper.ImGui_Separator(ctx)
  if reaper.ImGui_MenuItem(ctx, 'About/help', 'F1', false, reaper.ReaPack_GetOwner ~= nil) then
    about()
  end
  if reaper.ImGui_MenuItem(ctx, 'Close', 'Escape') then
    exit = true
  end
  reaper.ImGui_EndPopup(ctx)
end

----------------------------------------------------------------------
                                                    -- END OF IMGUI --
----------------------------------------------------------------------

----------------------------------------------------------------------
-- MAIN --
----------------------------------------------------------------------

function SetThemeColors()
  local count_theme_colors = 0
  for k, color in pairs( theme_colors ) do
    local color_str = reaper.GetExtState( "XR_ImGui_Col", k )
    if color_str ~= "" then
      color = tonumber( color_str, 16 )
    end
    reaper.ImGui_PushStyleColor(ctx, reaper[ "ImGui_Col_" .. k ](), color )
    count_theme_colors = count_theme_colors + 1
  end
  return count_theme_colors
end

function Main()
  for i, k in ipairs( GetTableOfSortedKeys(theme_colors) ) do
    local color = theme_colors[ k ]
    local retval, col_rgba = reaper.ImGui_ColorEdit4( ctx, k, color, flagsIn )
    if retval then
      reaper.ImGui_PopStyleColor( ctx, 1 )
      reaper.ImGui_PushStyleColor(ctx, reaper[ "ImGui_Col_" .. k ](), col_rgba  )
      theme_colors[k] = col_rgba
    end
  end

  reaper.ImGui_Dummy( ctx, 0, 20 )
  reaper.ImGui_Separator( ctx )
  reaper.ImGui_Dummy( ctx, 0, 20 )

  if reaper.ImGui_Button( ctx, "Copy to Clipboard" ) then
    --TODO: Print to ExtState
    local t = { "local theme_colors = {" }
    for k, v in spairs( theme_colors ) do
      local r, g, b, a = reaper.ImGui_ColorConvertU32ToDouble4( v )
      table.insert( t, "  " .. k .. " = " .. rgbaToHex( math.floor(r * 255), math.floor(g*255), math.floor(b*255), math.floor(a*255), "0x" ) .. "," )
    end
    table.insert( t, "}" )
    local str = table.concat( t, "\n" )
    reaper.CF_SetClipboard( str )
  end
end

----------------------------------------------------------------------
                                                     -- END OF MAIN --
----------------------------------------------------------------------

----------------------------------------------------------------------
-- RUN --
----------------------------------------------------------------------

function Run()

  reaper.ImGui_SetNextWindowBgAlpha( ctx, 1 )

  count_theme_colors = SetThemeColors()
  reaper.ImGui_PushFont(ctx, font)

  reaper.ImGui_SetNextWindowSize(ctx, 800, 200, reaper.ImGui_Cond_FirstUseEver())

  if set_dock_id then
    reaper.ImGui_SetNextWindowDockID(ctx, set_dock_id)
    set_dock_id = nil
  end

  local imgui_visible, imgui_open = reaper.ImGui_Begin(ctx, input_title, true, reaper.ImGui_WindowFlags_NoCollapse())

  if imgui_visible then

    contextMenu()

    imgui_width, imgui_height = reaper.ImGui_GetWindowSize( ctx )

    Main()

    reaper.ImGui_End(ctx)
  end

  reaper.ImGui_PopFont(ctx)
  reaper.ImGui_PopStyleColor( ctx, count_theme_colors )

  if imgui_open and not reaper.ImGui_IsKeyPressed(ctx, reaper.ImGui_Key_Escape()) and not process then
    reaper.defer(Run)
  end

end -- END DEFER

----------------------------------------------------------------------
                                                      -- END OF RUN --
----------------------------------------------------------------------

----------------------------------------------------------------------
-- INIT --
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

