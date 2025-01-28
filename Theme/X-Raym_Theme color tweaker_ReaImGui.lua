--[[
 * ReaScript Name: Theme color tweaker (ReaImGui)
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 0.7.5
--]]

--[[
 * Changelog:
 * v0.7.5 (2025-01-28)
  # Window resize border color
  # Moving window with click and drag titlebar only
 * v0.7.4 (2025-01-09)
  # Exit via context menu
 * v0.7.2 (2025-01-06)
  # Renamed with ReaImGui suffix
  # ReaImGui v0.9.3.2
  # Dark Theme
 * v0.7.1 (2023-04-03)
  # Nil error message
 * v0.7.0 (2023-03-22)
  # Fixed channel swap on MacOS and Linux
  + Quit with ESC
  # Restore initial theme button
  # Better export naming
  # Load new theme at export
  # Restore button on the left
 * v0.6.15 (2022-11-29)
  # ReaImGui v0.8 support
  # ReaImGui SHIM file call with v0.8
 * v0.6.14 (2022-07-18)
  # Fix export of ui_img_path if not present
  # Remove list of theme keys from script and work form updated version of amagalma list
 * v0.6.13 (2022-07-18)
  # Reload theme button
  # Added ui_img_path
  # Better reload
 * v0.6.12 (2022-07-12)
  # Color inversion MacOS fix
 * v0.6.11 (2022-07-11)
  # Color inversion fix
  # text variable fix (reuamguii v0.7)
 * v0.6.10 (2022-07-10)
  # Color inversion fix
 * v0.6.9 (2022-07-05)
  # ReaImGUI v0.7 color compatibility
 * v0.6.8 (2022-07-05)
  # ReaImGUI v0.7 compatibility
 * v0.6.7 (2021-08-05)
  # Fix MacOS export of modified colors
 * v0.6.6 (2021-07-03)
  # Compatibility with ReaImGUI v0.5
 * v0.6.5 (2021-05-05)
  # Fix 4th color byte (thx cfillion!)
 * v0.6.4 (2021-05-03)
  # Better filter
 * v0.6.3 (2021-04-04)
  # Add warning for missing dependencies
 * v0.6.2 (2021-03-30)
  + Fix MacOS paths
 * v0.6.1 (2021-03-30)
  + Warning for missing theme var files
 * v0.6 (2021-03-30)
  + Zip theme warning
 * v0.5 (2021-03-24)
  + First beta
 * v0.1 (2021-03-17)
  + First alpha
--]]

-- Known issues:
-- add blendmode without passing by SWS functions support: https://forum.cockos.com/showthread.php?t=251007
-- [REAPER] and blendmode for themezip
-- Integer color format in palette

-- TODO: Working from GetThemeColor function instead of parsing file allow working from zip, but needs update if new variables are added.

----------------------------------------------------------------------
-- USER CONFIG AREA --
----------------------------------------------------------------------

console = true
export_text = "Theme saved."

reaimgui_force_version = "0.9.3.2"-- false or string like "0.8.4"

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
  TextSelectedBg    = 0x404040ff, -- Search Field Selected Text
  SeparatorHovered  = 0x606060ff,
  SeparatorActive   = 0x404040ff,
  CheckMark         = 0xffffffff, -- CheckMark
}

input_title = "XR Theme Tweaker - Beta"

----------------------------------------------------------------------
------------------------------------------- END OF USER CONFIG AREA --
----------------------------------------------------------------------

----------------------------------------------------------------------
-- DEPENDENCIES --
----------------------------------------------------------------------

os_sep = package.config:sub(1,1)
path_resource = reaper.GetResourcePath()
local theme_var_desc_path = table.concat( {path_resource, "Scripts", "ReaTeam Scripts", "Development", "amagalma_Theme variable descriptions.lua"}, os_sep )
if reaper.file_exists( theme_var_desc_path ) then
  localize = true
  dofile( theme_var_desc_path )
  if not theme_var_descriptions_sorted then
    reaper.MB("Obsolete version of:\n" .. theme_var_desc_path .. "\nDownload it via Reapack ReaTeam ReaScripts repository.", "Error", 0)
    return false
  end
  all_tab = {}
  for i, entry in ipairs( theme_var_descriptions_sorted ) do
    table.insert( all_tab, entry.k )
  end
else
  reaper.MB("Missing script dependency:\n" .. theme_var_desc_path .. "\nDownload it via Reapack ReaTeam ReaScripts repository.", "Error", 0)
  return false
end

local color_functions_path = table.concat( {path_resource, "Scripts", "ReaTeam Scripts", "Development", "X-Raym_Color_functions.lua"}, os_sep )
if reaper.file_exists( color_functions_path ) then
  dofile( color_functions_path )
else
  reaper.MB("Missing script dependency:\n" .. color_functions_path .. "\nDownload it via Reapack ReaTeam ReaScripts repository.", "Error", 0)
  return false
end

imgui_path = reaper.ImGui_GetBuiltinPath and ( reaper.ImGui_GetBuiltinPath() .. '/imgui.lua' )

if not imgui_path then
  reaper.MB("Missing dependency: ReaImGui extension.\nDownload it via Reapack ReaTeam extension repository.", "Error", 0)
  return false
end

local ImGui = dofile(imgui_path) (reaimgui_force_version)

----------------------------------------------------------------------
-- STRINGS --
----------------------------------------------------------------------

function Msg( val )
  if console then
    reaper.ShowConsoleMsg( tostring(val) .. "\n" )
  end
end

function FindByWordsInSTR( str, words, or_mode )
  local out = true
  str = str:lower()
  for i, word in ipairs(words) do
    if or_mode then
      if str:find(word) then
        out = true
        break
      else
        out = false
      end
    else
      if not str:find(word) then
       out = false
       break
      end
    end
  end
  return out
end

function SplitSTR( str, char )
  local t = {}
  local i = 0
  for line in str:gmatch("[^" ..char .. "]*") do
      i = i + 1
      t[i] = line:lower()
  end
  return t
end

-- Split file name
function SplitFileName( strfilename )
  -- Returns the Path, Filename, and Extension as 3 values
  local path, file_name, extension = string.match( strfilename, "(.-)([^\\|/]-([^\\|/%.]+))$" )
  file_name = string.match( file_name, ('(.+)%.(.+)') )
  return path, file_name, extension
end

----------------------------------------------------------------------
-- TABLES  --
----------------------------------------------------------------------

function CopyTable( t )
  local out = {}
  for i, v in ipairs( t ) do
    out[i] = v
  end
  return out
end

function FilterTab( t, str, or_mode )
  if str == "" then return t end
  local words = SplitSTR(str, " ")
  local out, filtered_out = {}, {}
  for i, v in ipairs(t) do
    if (theme_var_descriptions and theme_var_descriptions[v] and FindByWordsInSTR(theme_var_descriptions[v], words, or_mode)) or FindByWordsInSTR(v, words, or_mode) then table.insert(out, v) else table.insert(filtered_out, v) end
  end
  return out, filtered_out
end

function FilterByTabValue( t, ref_tab,val )
  if not val then return t end
  local out, filtered_out = {}, {}
  for i, v in ipairs(t) do
    if ref_tab[v] == val then table.insert(out, v) else table.insert(filtered_out, v) end
  end
  return out, filtered_out
end

----------------------------------------------------------------------
-- LOAD --
----------------------------------------------------------------------

function LoadTheme( theme_path, reload )
  if reload then reaper.OpenColorThemeFile( theme_path ) end
  theme_is_zip =  not reaper.file_exists( theme_path )
  theme_folder, theme_name, theme_ext =  SplitFileName( theme_path )
  theme_prefix, theme_version_str= theme_name:match("(.+) %- Mod (%d+)" )
  theme_prefix = theme_prefix or theme_name
  theme_version_num = theme_version_str and tonumber( theme_version_str ) or 0
  theme_version_num = theme_version_num + 1
  theme_mod_name = theme_prefix .. " - Mod " .. theme_version_num

  modes_tab, items_tab = FilterTab( all_tab, "mode dm", true )

  colors, colors_backup = {}, {}
  for k, v in ipairs( items_tab ) do
    local col = reaper.GetThemeColor(v,0) -- NOTE: Flag doesn't seem to work (v6.78). Channel are swapped on MacOS and Linux.
    -- if os_sep == "/" then col = SwapINTrgba( col ) end -- in fact, better staus with channel swap cause at least it works
    colors[v] = col
    colors_backup[v] = col
  end

  modes = {}
  for k, v in ipairs( modes_tab ) do
    -- modes[v] = reaper.GetThemeColor(v,0) -- BUG: https://forum.cockos.com/showthread.php?t=251007
    retval, modes[v] = reaper.BR_Win32_GetPrivateProfileString( "color theme", v, -1, theme_path )
  end

  fonts_tab = {"lb_font", "lb_font2", "user_font0", "user_font1", "user_font2", "user_font3", "user_font4", "user_font5", "user_font6", "user_font7", "tl_font", "trans_font", "mi_font", "ui_img", "ui_img_path"}
  fonts = {}
  for k, v in ipairs( fonts_tab ) do
    retval, fonts[v] = reaper.BR_Win32_GetPrivateProfileString( "REAPER", v, -1, theme_path )
  end
end

----------------------------------------------------------------------
-- COLORS  --
----------------------------------------------------------------------

function ColorConvertHSVtoInt( h, s, v, a )
  local r, g, b = ImGui.ColorConvertHSVtoRGB( h, s, v, a )
  return ImGui.ColorConvertDouble4ToU32( r, g, b, a )
end

-- https://www.alanzucconi.com/2015/09/30/colour-sorting/
function step(r, g, b, repetitions)
  if not repetitions then repetitions = 1 end

  local lum = math.sqrt(0.241 * r + 0.691 * g + 0.068 * b)
  local h, s, v = rgbToHsv(r, g, b)

  local h2 = (h * repetitions)
  local lum2 = (lum * repetitions)
  local v2 = (v * repetitions)

  if h2 % 2 == 1 then -- this doesn't seem to do anything
    v2 = repetitions - v2
    lum = repetitions - lum
  end

  return h2, lum, v2
end

function SwapINTrgba( int )
  return (int >> 16 & 0x000000ff) |
         (int       & 0xff00ff00) |
         (int << 16 & 0x00ff0000)
end

----------------------------------------------------------------------
-- EXPORT  --
----------------------------------------------------------------------

function WriteFile( path, str )
  file = io.open ( path, 'w+' )
  file:write( str )
  file:close()
end

function GetExportThemeFileName()
  local theme_folder, theme_name, theme_ext =  SplitFileName( theme_path )
  local path = theme_folder .. theme_mod_name .. ".ReaperTheme"
  return path
end

function ExportTheme()
  local t = {"[color theme]"}
  for i, v in ipairs(all_tab) do
    local col
    if colors[v] then
      if os_sep == "\\" then
        col = colors[v]
      else
        col = SwapINTrgba( colors[v] )
      end
    end
    table.insert(t, v .. "=" .. ( col or modes[v]) )
  end
  table.insert(t, "[REAPER]")
  for i, v in ipairs(fonts_tab) do
    if tonumber(fonts[v]) ~= -1 then -- ui_img_path is not always present, and need to be filtered out if is not cause it overrides ui_img
      table.insert(t, v .. "=" .. (fonts[v] or "") )
    end
  end
  local str = table.concat(t, "\n")
  WriteFile( GetExportThemeFileName(), str)
end

-----------------------------------------------------------
-- IMGUI --
-----------------------------------------------------------
---
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

function loop()
  ImGui.SetNextWindowBgAlpha( ctx, 1 )

  if set_dock_id then
    ImGui.SetNextWindowDockID(ctx, set_dock_id)
    set_dock_id = nil
  end

  count_theme_colors = SetThemeColors( ctx )

  ImGui.PushFont(ctx, font)
  ImGui.SetNextWindowSize(ctx, 800, 200, ImGui.Cond_FirstUseEver)

  local imgui_visible, imgui_open = ImGui.Begin(ctx, 'XR Theme Tweaker', true, ImGui.WindowFlags_AlwaysVerticalScrollbar )
  if imgui_visible then

    contextMenu()

    ImGui.PushItemWidth(ctx,ImGui.GetWindowWidth( ctx ) - 85) -- Set max with of inputs
    ImGui.InputText(ctx, 'Theme', theme_name,  ImGui.InputTextFlags_ReadOnly )

    if ImGui.Button(ctx, 'Restore All', ImGui.GetWindowWidth( ctx )) then
      LoadTheme( theme_path, true )
    end

    if ImGui.Button(ctx, 'Export') then
      ExportTheme()
      ImGui.OpenPopup(ctx, 'Info')
    end

    ImGui.SameLine(ctx)

    ImGui.PushItemWidth(ctx,ImGui.GetWindowWidth( ctx )-172) -- Set max with of inputs
    retval_text, theme_mod_name = ImGui.InputText(ctx, 'File name', theme_mod_name)

    -- Popup
    local display_size = {ImGui.GetWindowSize(ctx)}
    local center = { display_size[1] * 0.5, display_size[2] * 0.5 }
    local x, y = ImGui.GetWindowPos( ctx )
    ImGui.SetNextWindowPos(ctx, x + center[1], y + center[2], ImGui.Cond_Appearing, 0.5, 0.5)

    if ImGui.BeginPopupModal(ctx, 'Info', nil, ImGui.WindowFlags_AlwaysAutoResize |  ImGui.WindowFlags_NoMove) then
      ImGui.Text(ctx, export_text)
      if fonts["lb_font"] == "-1" then
        ImGui.Text(ctx, "WARNING: ReaperThemeZip as theme source isn't well supported.")
        ImGui.Text(ctx, "[REAPER] section is missing, and blend modes are wrong.")
        ImGui.Text(ctx, "Better work from uncompressed ReaperThemeZip.")
      end
      ImGui.Separator(ctx)

      if ImGui.Button(ctx, 'OK', 120, 0) then
        ImGui.CloseCurrentPopup(ctx)
      end
      ImGui.SameLine( ctx )
      if ImGui.Button(ctx, 'Load New Theme', 120, 0) then
        local theme_mod_path = GetExportThemeFileName()
        LoadTheme( theme_mod_path, true )
        theme_path = theme_mod_path
        ImGui.CloseCurrentPopup(ctx)
      end
      ImGui.SetItemDefaultFocus(ctx)
      ImGui.EndPopup(ctx)
    end

    if theme_is_zip then
      ImGui.Spacing( ctx )
      ImGui.TextWrapped(ctx, "WARNING: Zipped Theme.\nUnzip theme to have working blend modes and font section in exported file.")
    end

    if ImGui.Button(ctx, 'Load Theme from Export Path') then
      local theme_mod_path = GetExportThemeFileName()
      LoadTheme( theme_mod_path, true )
      theme_path = theme_mod_path
    end

    ImGui.SameLine( ctx )
    if ImGui.Button(ctx, 'Restore Initial Theme') then
      LoadTheme( init_theme_path, true )
      theme_path = init_theme_path
    end

    ImGui.Spacing( ctx )
    ImGui.Spacing( ctx )
    ImGui.Separator(ctx)
    ImGui.Spacing( ctx )
    ImGui.Spacing( ctx )

    ImGui.PushItemWidth(ctx, 100 )
    if  theme_var_descriptions then
      local retval, color_descriptions_num_temp = ImGui.Combo(ctx, 'Labels', color_descriptions_num, "Text\0Variables\0")
      if retval then color_descriptions_num = color_descriptions_num_temp end
    else
      ImGui.TextWrapped(ctx, "WARNING: Missing theme labels description files.\nInstall ReaTeam ReaScripts repository via Reapack to have labels text.")
    end

    ImGui.PushItemWidth(ctx,ImGui.GetWindowWidth( ctx )-113) -- Set max with of inputs
    retval_text, text = ImGui.InputText(ctx, 'Filter name', text)
    tab = FilterTab( items_tab, text )

    -- PALETTE
    local palette_key = {}
    local palette = {}
    for i, v in ipairs( items_tab ) do
      if not palette_key[colors[v]] then
        palette_key[colors[v]] = true
        table.insert( palette, colors[v] )
      end
    end
    table.sort(palette, function (first, second) -- Thx to gxray!!!!
      local r1, g1, b1, a1 = ImGui.ColorConvertU32ToDouble4(first)
      local r2, g2, b2, a2 = ImGui.ColorConvertU32ToDouble4(second)
      local step_count = 8 -- This doesn't seems to do anything
      return step(r1, g1, b1, step_count) > step(r2, g2, b2, step_count)
    end)

    retval_palette_toggle, palette_toggle = ImGui.Checkbox(ctx, 'Filter color', palette_toggle)
    ImGui.SameLine(ctx)

    if palette_toggle then

      ImGui.PushItemWidth(ctx, 100) -- Set max with of inputs
      local open_popup = ImGui.ColorEdit3(ctx, '##3b', filter_color, ImGui.ColorEditFlags_NoPicker|ImGui.ColorEditFlags_NoAlpha|ImGui.ColorEditFlags_DisplayHex)
      ImGui.SameLine(ctx, 0, ({ImGui.GetStyleVar(ctx, ImGui.StyleVar_ItemInnerSpacing)})[1])
      open_popup = ImGui.Button(ctx, 'Palette') or open_popup
      if open_popup then
        ImGui.OpenPopup(ctx, 'mypicker')
      end

      if ImGui.BeginPopup(ctx, 'mypicker', ImGui.WindowFlags_NoMove ) then
        ImGui.Text(ctx, 'Palette')
        ImGui.Separator(ctx)

        ImGui.BeginGroup(ctx) -- Lock X position
        local palette_button_flags = ImGui.ColorEditFlags_NoAlpha  |
                                     ImGui.ColorEditFlags_NoPicker
        for n,c in ipairs(palette) do
          ImGui.PushID(ctx, n)
          if ((n - 1) % 16) ~= 0 then
            ImGui.SameLine(ctx, 0.0, ({ImGui.GetStyleVar(ctx, ImGui.StyleVar_ItemSpacing)})[2])
          end

          if ImGui.ColorButton(ctx, '##palette', c, palette_button_flags, 20, 20) then
            filter_color = c
          end

          ImGui.PopID(ctx)
        end
        ImGui.EndGroup(ctx)
        ImGui.EndPopup(ctx)
      end

      -- Refresh if filter color has changed or if palette toggle has been toggle twice and is activated
      if filter_color ~= last_filter_color or palette_toggle ~= last_palette_toggle then
        tab = FilterByTabValue(tab, colors, filter_color)
      else -- Keep previous filter keys
        tab = last_tab
      end

    end

    ImGui.Spacing( ctx )
    ImGui.Spacing( ctx )
    ImGui.Separator( ctx )
    ImGui.Spacing( ctx )
    ImGui.Spacing( ctx )

    for i, v in ipairs( tab ) do

      pop_style = false
      if colors[v] ~= colors_backup[v] then
        local buttonColor = ColorConvertHSVtoInt( 7.0, 0.6, 0.6, 1.0 )
        local hoveredColor = ColorConvertHSVtoInt(7.0, 0.7, 0.7, 1.0)
        local activeColor  = ColorConvertHSVtoInt(7.0, 0.8, 0.8, 1.0)
        ImGui.PushStyleColor(ctx, ImGui.Col_Button,        buttonColor)
        ImGui.PushStyleColor(ctx, ImGui.Col_ButtonHovered, hoveredColor)
        ImGui.PushStyleColor(ctx, ImGui.Col_ButtonActive,  activeColor)
        pop_style = true
      end

      if ImGui.Button(ctx, "Restore##3f"..i) then
        colors[v] = colors_backup[v]
        reaper.SetThemeColor( v, colors[v], 0 )
        reaper.ThemeLayout_RefreshAll()
      end

      if pop_style then
        pop_style = false
        ImGui.PopStyleColor(ctx, 3)
      end

      ImGui.SameLine( ctx )

      ImGui.PushItemWidth(ctx, 92) -- Set max with of inputs

      retval, colors[v] = ImGui.ColorEdit3(ctx, (color_descriptions_num == 0 and theme_var_descriptions and theme_var_descriptions[v]) or v, ImGui.ColorConvertNative(colors[v]),  ImGui.ColorEditFlags_DisplayHex )
      colors[v] = ImGui.ColorConvertNative( colors[v] )
      if retval then -- if changed
        reaper.SetThemeColor( v, colors[v], 0 )
        reaper.ThemeLayout_RefreshAll()
      end

      ImGui.PopItemWidth( ctx ) -- Restore max with of input
    end

    last_tab = CopyTable(tab) -- Copy filtered keys
    last_filter_color = filter_color
    last_palette_toggle = palette_toggle

    ImGui.End(ctx)

  end

  ImGui.PopStyleColor(ctx, count_theme_colors)
  ImGui.PopFont(ctx)

  if imgui_open and not ImGui.IsKeyPressed(ctx, ImGui.Key_Escape) and not process and not exit then
    reaper.defer(loop)
  end

end

----------------------------------------------------------------------
-- INIT --
----------------------------------------------------------------------

reaper.ClearConsole()

theme_path = reaper.GetLastColorThemeFile()
if not theme_path or theme_path == "" then
  return reaper.MB( "REAPER Bug (known issue): GetLastColorThemeFile returns invalid value.\nTry to change theme and switch back before running the script", "Error", 0 )
end
init_theme_path = theme_path
LoadTheme( theme_path )

--table.sort(all_tab)
filter_color = 0
palette_toggle = false
color_descriptions_num = 0 -- 0 for text, 1 for variables

ctx = ImGui.CreateContext( input_title, ImGui.ConfigFlags_DockingEnable | ImGui.ConfigFlags_NavEnableKeyboard ) -- For no saved setting: ImGui.ConfigFlags_NoSavedSettings
ImGui.SetConfigVar( ctx, ImGui.ConfigVar_DockingNoSplit, 1 )
ImGui.SetConfigVar( ctx, ImGui.ConfigVar_WindowsMoveFromTitleBarOnly, 1 )

font = ImGui.CreateFont('sans-serif', 16)
ImGui.Attach(ctx, font)
ImGui.SetNextWindowSize( ctx, 710, 400, ImGui.Cond_FirstUseEver )

r = reaper

loop()
