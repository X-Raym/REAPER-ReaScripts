--[[
 * ReaScript Name: Theme color tweaker
 * Author: X-Raym
 * Author URI: https://extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 0.7.1
--]]

--[[
 * Changelog:
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

if not reaper.ImGui_CreateContext then
  reaper.MB("Missing dependency: ReaImGui extension.\nDownload it via Reapack ReaTeam extension repository.", "Error", 0)
  return false
end

reaimgui_shim_file_path = reaper.GetResourcePath() .. '/Scripts/ReaTeam Extensions/API/imgui.lua'
if reaper.file_exists( reaimgui_shim_file_path ) then
  dofile( reaimgui_shim_file_path )('0.8')
end

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
  local r, g, b = reaper.ImGui_ColorConvertHSVtoRGB( h, s, v, a )
  return reaper.ImGui_ColorConvertDouble4ToU32( r, g, b, a )
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

----------------------------------------------------------------------
-- RUN --
----------------------------------------------------------------------

function loop()

  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_WindowBg(), 0x0F0F0FFF) -- Black opaque background
  reaper.ImGui_PushFont(ctx, font)

  local imgui_visible, imgui_open = reaper.ImGui_Begin(ctx, 'XR Theme Tweaker', true, reaper.ImGui_WindowFlags_AlwaysVerticalScrollbar() )
  if imgui_visible then

    reaper.ImGui_PushItemWidth(ctx,reaper.ImGui_GetWindowWidth( ctx ) - 85) -- Set max with of inputs
    reaper.ImGui_InputText(ctx, 'Theme', theme_name,  reaper.ImGui_InputTextFlags_ReadOnly() )

    if reaper.ImGui_Button(ctx, 'Restore All', reaper.ImGui_GetWindowWidth( ctx )) then
      LoadTheme( theme_path, true )
    end

    if reaper.ImGui_Button(ctx, 'Export') then
      ExportTheme()
      reaper.ImGui_OpenPopup(ctx, 'Info')
    end

    reaper.ImGui_SameLine(ctx)

    reaper.ImGui_PushItemWidth(ctx,reaper.ImGui_GetWindowWidth( ctx )-172) -- Set max with of inputs
    retval_text, theme_mod_name = reaper.ImGui_InputText(ctx, 'File name', theme_mod_name)

    -- Popup
    local display_size = {reaper.ImGui_GetWindowSize(ctx)}
    local center = { display_size[1] * 0.5, display_size[2] * 0.5 }
    local x, y = reaper.ImGui_GetWindowPos( ctx )
    reaper.ImGui_SetNextWindowPos(ctx, x + center[1], y + center[2], reaper.ImGui_Cond_Appearing(), 0.5, 0.5)

    if reaper.ImGui_BeginPopupModal(ctx, 'Info', nil, reaper.ImGui_WindowFlags_AlwaysAutoResize() |  reaper.ImGui_WindowFlags_NoMove()) then
      reaper.ImGui_Text(ctx, export_text)
      if fonts["lb_font"] == "-1" then
        reaper.ImGui_Text(ctx, "WARNING: ReaperThemeZip as theme source isn't well supported.")
        reaper.ImGui_Text(ctx, "[REAPER] section is missing, and blend modes are wrong.")
        reaper.ImGui_Text(ctx, "Better work from uncompressed ReaperThemeZip.")
      end
      reaper.ImGui_Separator(ctx)

      if reaper.ImGui_Button(ctx, 'OK', 120, 0) then
        reaper.ImGui_CloseCurrentPopup(ctx)
      end
      reaper.ImGui_SameLine( ctx )
      if reaper.ImGui_Button(ctx, 'Load New Theme', 120, 0) then
        local theme_mod_path = GetExportThemeFileName()
        LoadTheme( theme_mod_path, true )
        theme_path = theme_mod_path
        reaper.ImGui_CloseCurrentPopup(ctx)
      end
      reaper.ImGui_SetItemDefaultFocus(ctx)
      reaper.ImGui_EndPopup(ctx)
    end

    if theme_is_zip then
      reaper.ImGui_Spacing( ctx )
      reaper.ImGui_TextWrapped(ctx, "WARNING: Zipped Theme.\nUnzip theme to have working blend modes and font section in exported file.")
    end

    if reaper.ImGui_Button(ctx, 'Load Theme from Export Path') then
      local theme_mod_path = GetExportThemeFileName()
      LoadTheme( theme_mod_path, true )
      theme_path = theme_mod_path
    end
    
    reaper.ImGui_SameLine( ctx )
    if reaper.ImGui_Button(ctx, 'Restore Initial Theme') then
      LoadTheme( init_theme_path, true )
      theme_path = init_theme_path
    end

    reaper.ImGui_Spacing( ctx )
    reaper.ImGui_Spacing( ctx )
    reaper.ImGui_Separator(ctx)
    reaper.ImGui_Spacing( ctx )
    reaper.ImGui_Spacing( ctx )

    reaper.ImGui_PushItemWidth(ctx, 100 )
    if  theme_var_descriptions then
      local retval, color_descriptions_num_temp = r.ImGui_Combo(ctx, 'Labels', color_descriptions_num, "Text\0Variables\0")
      if retval then color_descriptions_num = color_descriptions_num_temp end
    else
      reaper.ImGui_TextWrapped(ctx, "WARNING: Missing theme labels description files.\nInstall ReaTeam ReaScripts repository via Reapack to have labels text.")
    end

    reaper.ImGui_PushItemWidth(ctx,reaper.ImGui_GetWindowWidth( ctx )-113) -- Set max with of inputs
    retval_text, text = reaper.ImGui_InputText(ctx, 'Filter name', text)
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
      local r1, g1, b1, a1 = reaper.ImGui_ColorConvertU32ToDouble4(first)
      local r2, g2, b2, a2 = reaper.ImGui_ColorConvertU32ToDouble4(second)
      local step_count = 8 -- This doesn't seems to do anything
      return step(r1, g1, b1, step_count) > step(r2, g2, b2, step_count)
    end)

    retval_palette_toggle, palette_toggle = r.ImGui_Checkbox(ctx, 'Filter color', palette_toggle)
    r.ImGui_SameLine(ctx)

    if palette_toggle then

      reaper.ImGui_PushItemWidth(ctx, 100) -- Set max with of inputs
      local open_popup = r.ImGui_ColorEdit3(ctx, '##3b', filter_color, r.ImGui_ColorEditFlags_NoPicker()|r.ImGui_ColorEditFlags_NoAlpha()|reaper.ImGui_ColorEditFlags_DisplayHex())
      r.ImGui_SameLine(ctx, 0, ({r.ImGui_GetStyleVar(ctx, r.ImGui_StyleVar_ItemInnerSpacing())})[1])
      open_popup = r.ImGui_Button(ctx, 'Palette') or open_popup
      if open_popup then
        r.ImGui_OpenPopup(ctx, 'mypicker')
      end

      if r.ImGui_BeginPopup(ctx, 'mypicker', reaper.ImGui_WindowFlags_NoMove() ) then
        r.ImGui_Text(ctx, 'Palette')
        r.ImGui_Separator(ctx)

        r.ImGui_BeginGroup(ctx) -- Lock X position
        local palette_button_flags = r.ImGui_ColorEditFlags_NoAlpha()  |
                                     r.ImGui_ColorEditFlags_NoPicker()
        for n,c in ipairs(palette) do
          r.ImGui_PushID(ctx, n)
          if ((n - 1) % 16) ~= 0 then
            r.ImGui_SameLine(ctx, 0.0, ({r.ImGui_GetStyleVar(ctx, r.ImGui_StyleVar_ItemSpacing())})[2])
          end

          if r.ImGui_ColorButton(ctx, '##palette', c, palette_button_flags, 20, 20) then
            filter_color = c
          end

          r.ImGui_PopID(ctx)
        end
        r.ImGui_EndGroup(ctx)
        r.ImGui_EndPopup(ctx)
      end

      -- Refresh if filter color has changed or if palette toggle has been toggle twice and is activated
      if filter_color ~= last_filter_color or palette_toggle ~= last_palette_toggle then
        tab = FilterByTabValue(tab, colors, filter_color)
      else -- Keep previous filter keys
        tab = last_tab
      end

    end

    reaper.ImGui_Spacing( ctx )
    reaper.ImGui_Spacing( ctx )
    reaper.ImGui_Separator( ctx )
    reaper.ImGui_Spacing( ctx )
    reaper.ImGui_Spacing( ctx )

    for i, v in ipairs( tab ) do
      
      pop_style = false
      if colors[v] ~= colors_backup[v] then
        local buttonColor = ColorConvertHSVtoInt( 7.0, 0.6, 0.6, 1.0 )
        local hoveredColor = ColorConvertHSVtoInt(7.0, 0.7, 0.7, 1.0)
        local activeColor  = ColorConvertHSVtoInt(7.0, 0.8, 0.8, 1.0)
        r.ImGui_PushStyleColor(ctx, r.ImGui_Col_Button(),        buttonColor)
        r.ImGui_PushStyleColor(ctx, r.ImGui_Col_ButtonHovered(), hoveredColor)
        r.ImGui_PushStyleColor(ctx, r.ImGui_Col_ButtonActive(),  activeColor)
        pop_style = true
      end
      
      if r.ImGui_Button(ctx, "Restore##3f"..i) then
        colors[v] = colors_backup[v]
        reaper.SetThemeColor( v, colors[v], 0 )
        reaper.ThemeLayout_RefreshAll()
      end
      
      if pop_style then
        pop_style = false
        r.ImGui_PopStyleColor(ctx, 3)
      end
      
      reaper.ImGui_SameLine( ctx )
      
      reaper.ImGui_PushItemWidth(ctx, 92) -- Set max with of inputs
      
      retval, colors[v] = reaper.ImGui_ColorEdit3(ctx, (color_descriptions_num == 0 and theme_var_descriptions and theme_var_descriptions[v]) or v, reaper.ImGui_ColorConvertNative(colors[v]),  reaper.ImGui_ColorEditFlags_DisplayHex() )
      colors[v] = reaper.ImGui_ColorConvertNative( colors[v] )
      if retval then -- if changed
        reaper.SetThemeColor( v, colors[v], 0 )
        reaper.ThemeLayout_RefreshAll()
      end
      
      reaper.ImGui_PopItemWidth( ctx ) -- Restore max with of input
    end

    last_tab = CopyTable(tab) -- Copy filtered keys
    last_filter_color = filter_color
    last_palette_toggle = palette_toggle

    reaper.ImGui_End(ctx)

  end

  reaper.ImGui_PopStyleColor(ctx) -- Remove black opack background
  reaper.ImGui_PopFont(ctx)

  if not imgui_open or reaper.ImGui_IsKeyPressed(ctx, 27) then
    reaper.ImGui_DestroyContext(ctx)
  else
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

-- For no saved settings:
-- local ctx = reaper.ImGui_CreateContext('XR Theme Tweaker - Beta', reaper.ImGui_ConfigFlags_DockingEnable()+reaper.ImGui_ConfigFlags_NoSavedSettings() )
ctx = reaper.ImGui_CreateContext('XR Theme Tweaker - Beta', reaper.ImGui_ConfigFlags_DockingEnable() )
font = reaper.ImGui_CreateFont('sans-serif', 14)
reaper.ImGui_Attach(ctx, font)
reaper.ImGui_SetNextWindowSize( ctx, 710, 400, reaper.ImGui_Cond_FirstUseEver() )

r = reaper

loop()
