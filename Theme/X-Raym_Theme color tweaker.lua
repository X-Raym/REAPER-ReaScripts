--[[
 * ReaScript Name: Theme color tweaker
 * Author: X-Raym
 * Author URI: https://extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 0.6.13
--]]

--[[
 * Changelog:
 * v0.6.13 (2022-07-12)
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

local text = ''
local all_tab = {"col_main_bg2" , "col_main_text2" , "col_main_textshadow" , "col_main_3dhl" , "col_main_3dsh" , "col_main_resize2" , "col_main_text" , "col_main_bg" , "col_main_editbk" , "col_transport_editbk" , "col_toolbar_text" , "col_toolbar_text_on" , "col_toolbar_frame" , "toolbararmed_color" , "toolbararmed_drawmode" , "io_text" , "io_3dhl" , "io_3dsh" , "genlist_bg" , "genlist_fg" , "genlist_grid" , "genlist_selbg" , "genlist_selfg" , "genlist_seliabg" , "genlist_seliafg" , "genlist_hilite" , "genlist_hilite_sel" , "col_buttonbg" , "col_tcp_text" , "col_tcp_textsel" , "col_seltrack" , "col_seltrack2" , "tcplocked_color" , "tcplocked_drawmode" , "col_tracklistbg" , "col_mixerbg" , "col_arrangebg" , "arrange_vgrid" , "col_fadearm" , "col_fadearm2" , "col_fadearm3" , "col_tl_fg" , "col_tl_fg2" , "col_tl_bg" , "col_tl_bgsel" , "timesel_drawmode" , "col_tl_bgsel2" , "col_trans_bg" , "col_trans_fg" , "playrate_edited" , "col_mi_label" , "col_mi_label_sel" , "col_mi_label_float" , "col_mi_label_float_sel" , "col_mi_bg" , "col_mi_bg2" , "col_tr1_itembgsel" , "col_tr2_itembgsel" , "itembg_drawmode" , "col_tr1_peaks" , "col_tr2_peaks" , "col_tr1_ps2" , "col_tr2_ps2" , "col_peaksedge" , "col_peaksedge2" , "col_peaksedgesel" , "col_peaksedgesel2" , "cc_chase_drawmode" , "col_peaksfade" , "col_peaksfade2" , "col_mi_fades" , "fadezone_color" , "fadezone_drawmode" , "fadearea_color" , "fadearea_drawmode" , "col_mi_fade2" , "col_mi_fade2_drawmode" , "item_grouphl" , "col_offlinetext" , "col_stretchmarker" , "col_stretchmarker_h0" , "col_stretchmarker_h1" , "col_stretchmarker_h2" , "col_stretchmarker_b" , "col_stretchmarkerm" , "col_stretchmarker_text" , "col_stretchmarker_tm" , "take_marker" , "selitem_tag" , "activetake_tag" , "col_tr1_bg" , "col_tr2_bg" , "selcol_tr1_bg" , "selcol_tr2_bg" , "col_tr1_divline" , "col_tr2_divline" , "col_envlane1_divline" , "col_envlane2_divline" , "marquee_fill" , "marquee_drawmode" , "marquee_outline" , "marqueezoom_fill" , "marqueezoom_drawmode" , "marqueezoom_outline" , "areasel_fill" , "areasel_drawmode" , "areasel_outline" , "areasel_outlinemode" , "col_cursor" , "col_cursor2" , "playcursor_color" , "playcursor_drawmode" , "col_gridlines2" , "col_gridlines2dm" , "col_gridlines3" , "col_gridlines3dm" , "col_gridlines" , "col_gridlines1dm" , "guideline_color" , "guideline_drawmode" , "region" , "region_lane_bg" , "region_lane_text" , "marker" , "marker_lane_bg" , "marker_lane_text" , "col_tsigmark" , "ts_lane_bg" , "ts_lane_text" , "timesig_sel_bg" , "col_routinghl1" , "col_routinghl2" , "col_vudoint" , "col_vuclip" , "col_vutop" , "col_vumid" , "col_vubot" , "col_vuintcol" , "col_vumidi" , "col_vuind1" , "col_vuind2" , "col_vuind3" , "col_vuind4" , "mcp_sends_normal" , "mcp_sends_muted" , "mcp_send_midihw" , "mcp_sends_levels" , "mcp_fx_normal" , "mcp_fx_bypassed" , "mcp_fx_offlined" , "mcp_fxparm_normal" , "mcp_fxparm_bypassed" , "mcp_fxparm_offlined" , "tcp_list_scrollbar" , "tcp_list_scrollbar_mode" , "tcp_list_scrollbar_mouseover" , "tcp_list_scrollbar_mouseover_mode" , "mcp_list_scrollbar" , "mcp_list_scrollbar_mode" , "mcp_list_scrollbar_mouseover" , "mcp_list_scrollbar_mouseover_mode" , "midi_rulerbg" , "midi_rulerfg" , "midi_grid2" , "midi_griddm2" , "midi_grid3" , "midi_griddm3" , "midi_grid1" , "midi_griddm1" , "midi_trackbg1" , "midi_trackbg2" , "midi_trackbg_outer1" , "midi_trackbg_outer2" , "midi_selpitch1" , "midi_selpitch2" , "midi_selbg" , "midi_selbg_drawmode" , "midi_gridhc" , "midi_gridhcdm" , "midi_gridh" , "midi_gridhdm" , "midi_ccbut" , "midi_ccbut_text" , "midi_ccbut_arrow" , "midioct" , "midi_inline_trackbg1" , "midi_inline_trackbg2" , "midioct_inline" , "midi_endpt" , "midi_notebg" , "midi_notefg" , "midi_notemute" , "midi_notemute_sel" , "midi_itemctl" , "midi_ofsn" , "midi_ofsnsel" , "midi_editcurs" , "midi_pkey1" , "midi_pkey2" , "midi_pkey3" , "midi_noteon_flash" , "midi_leftbg" , "midifont_col_light_unsel" , "midifont_col_dark_unsel" , "midifont_mode_unsel" , "midifont_col_light" , "midifont_col_dark" , "midifont_mode" , "score_bg" , "score_fg" , "score_sel"
 , "score_timesel" , "score_loop" , "midieditorlist_bg" , "midieditorlist_fg" , "midieditorlist_grid" , "midieditorlist_selbg" , "midieditorlist_selfg" , "midieditorlist_seliabg" , "midieditorlist_seliafg" , "midieditorlist_bg2" , "midieditorlist_fg2" , "midieditorlist_selbg2" , "midieditorlist_selfg2" , "col_explorer_sel" , "col_explorer_seldm" , "col_explorer_seledge" , "docker_shadow" , "docker_selface" , "docker_unselface" , "docker_text" , "docker_text_sel" , "docker_bg" , "windowtab_bg" , "auto_item_unsel" , "col_env1" , "col_env2" , "env_trim_vol" , "col_env3" , "col_env4" , "env_track_mute" , "col_env5" , "col_env6" , "col_env7" , "col_env8" , "col_env9" , "col_env10" , "env_sends_mute" , "col_env11" , "col_env12" , "col_env13" , "col_env14" , "col_env15" , "col_env16" , "env_item_vol" , "env_item_pan" , "env_item_mute" , "env_item_pitch" , "wiring_grid2" , "wiring_grid" , "wiring_border" , "wiring_tbg" , "wiring_ticon" , "wiring_recbg" , "wiring_recitem" , "wiring_media" , "wiring_recv" , "wiring_send" , "wiring_fader" , "wiring_parent" , "wiring_parentwire_border" , "wiring_parentwire_master" , "wiring_parentwire_folder" , "wiring_pin_normal" , "wiring_pin_connected" , "wiring_pin_disconnected" , "wiring_horz_col" , "wiring_sendwire" , "wiring_hwoutwire" , "wiring_recinputwire" , "wiring_hwout" , "wiring_recinput" , "group_0" , "group_1" , "group_2" , "group_3" , "group_4" , "group_5" , "group_6" , "group_7" , "group_8" , "group_9" , "group_10" , "group_11" , "group_12" , "group_13" , "group_14" , "group_15" , "group_16" , "group_17" , "group_18" , "group_19" , "group_20" , "group_21" , "group_22" , "group_23" , "group_24" , "group_25" , "group_26" , "group_27" , "group_28" , "group_29" , "group_30" , "group_31" , "group_32" , "group_33" , "group_34" , "group_35" , "group_36" , "group_37" , "group_38" , "group_39" , "group_40" , "group_41" , "group_42" , "group_43" , "group_44" , "group_45" , "group_46" , "group_47" , "group_48" , "group_49" , "group_50" , "group_51" , "group_52" , "group_53" , "group_54" , "group_55" , "group_56" , "group_57" , "group_58" , "group_59" , "group_60" , "group_61" , "group_62" , "group_63"}
--table.sort(all_tab)
filter_color = 0
palette_toggle = false
color_descriptions_num = 0 -- 0 for text, 1 for variables

localize = true
os_sep = package.config:sub(1,1)
path_resource = reaper.GetResourcePath()
local theme_var_desc_path = table.concat( {path_resource, "Scripts", "ReaTeam Scripts", "Development", "amagalma_Theme variable descriptions.lua"}, os_sep )
if reaper.file_exists( theme_var_desc_path ) then
  dofile( theme_var_desc_path )
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

-- For no saved settings:
-- local ctx = reaper.ImGui_CreateContext('XR Theme Tweaker - Beta', reaper.ImGui_ConfigFlags_DockingEnable()+reaper.ImGui_ConfigFlags_NoSavedSettings() )
local ctx = reaper.ImGui_CreateContext('XR Theme Tweaker - Beta', reaper.ImGui_ConfigFlags_DockingEnable() )
reaper.ImGui_SetNextWindowSize( ctx, 710, 400, reaper.ImGui_Cond_FirstUseEver() )

export_text = "Theme saved."

r = reaper

function Msg( val )
  reaper.ShowConsoleMsg( tostring(val) .. "\n" )
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
    local color = colors[v]
    if os_sep == "/" and color ~= colors_backup[v] then
      local r, g, b = reaper.ColorFromNative( color )
      color = reaper.ColorToNative(r, g, b)
    end
    table.insert(t, v .. "=" .. ( color and reaper.ImGui_ColorConvertNative(color) or modes[v]) )
  end
  table.insert(t, "[REAPER]")
  for i, v in ipairs(fonts_tab) do
    table.insert(t, v .. "=" .. (fonts[v] or "") )
  end
  local str = table.concat(t, "\n")
  WriteFile( GetExportThemeFileName(), str)
end

function CopyTable( t )
  local out = {}
  for i, v in ipairs( t ) do
    out[i] = v
  end
  return out
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

-- Split file name
function SplitFileName( strfilename )
  -- Returns the Path, Filename, and Extension as 3 values
  local path, file_name, extension = string.match( strfilename, "(.-)([^\\|/]-([^\\|/%.]+))$" )
  file_name = string.match( file_name, ('(.+)%.(.+)') )
  return path, file_name, extension
end

function LoadTheme( theme_path, reload )
  if reload then reaper.OpenColorThemeFile( theme_path ) end
  theme_is_zip =  not reaper.file_exists( theme_path )
  theme_folder, theme_name, theme_ext =  SplitFileName( theme_path )
  theme_mod_name = theme_name .. " - Mod"
  
  modes_tab, items_tab = FilterTab( all_tab, "mode dm", true )
  
  colors, colors_backup = {}, {}
  for k, v in ipairs( items_tab ) do
    local col = reaper.ImGui_ColorConvertNative(reaper.GetThemeColor(v,0))
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
-- INIT --
----------------------------------------------------------------------

reaper.ClearConsole()

theme_path = reaper.GetLastColorThemeFile()
LoadTheme( theme_path )

function ColorConvertHSVtoInt( h, s, v, a )
  local r, g, b = reaper.ImGui_ColorConvertHSVtoRGB( h, s, v, a )
  return reaper.ImGui_ColorConvertDouble4ToU32( r, g, b, a )
end

function loop()

  reaper.ImGui_PushStyleColor(ctx, reaper.ImGui_Col_WindowBg(), 0x0F0F0FFF) -- Black opaque background
  
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

    reaper.ImGui_SetNextWindowPos(ctx, center[1], center[2], reaper.ImGui_Cond_Appearing(), 0.5, 0.5)

    if reaper.ImGui_BeginPopupModal(ctx, 'Info', nil, reaper.ImGui_WindowFlags_AlwaysAutoResize() |  reaper.ImGui_WindowFlags_NoMove()) then
      reaper.ImGui_Text(ctx, export_text)
      if fonts["lb_font"] == "-1" then
        reaper.ImGui_Text(ctx, "WARNING: ReaperThemeZip as theme source isn't well supported.")
        reaper.ImGui_Text(ctx, "[REAPER] section is missing, and blend modes are wrong.")
        reaper.ImGui_Text(ctx, "Better work from uncompressed ReaperThemeZip.")
      end
      reaper.ImGui_Separator(ctx)

      if reaper.ImGui_Button(ctx, 'OK', 120, 0) then reaper.ImGui_CloseCurrentPopup(ctx) end
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
      local r1, b1, g1 = reaper.ColorFromNative(first)
      local r2, b2, g2 = reaper.ColorFromNative(second)
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
    reaper.ImGui_Separator(ctx)
    reaper.ImGui_Spacing( ctx )
    reaper.ImGui_Spacing( ctx )

    for i, v in ipairs( tab ) do
      reaper.ImGui_PushItemWidth(ctx, 100) -- Set max with of inputs
      retval, colors[v] = reaper.ImGui_ColorEdit3(ctx, (color_descriptions_num == 0 and theme_var_descriptions and theme_var_descriptions[v]) or v, colors[v],  reaper.ImGui_ColorEditFlags_DisplayHex() )
      if retval then -- if changed
        reaper.SetThemeColor( v, reaper.ImGui_ColorConvertNative(colors[v]), 0 )
        reaper.ThemeLayout_RefreshAll()
      end
      reaper.ImGui_SameLine(ctx, math.max(reaper.ImGui_GetWindowWidth( ctx )-80, 310) )
      reaper.ImGui_SameLine(ctx, math.max(reaper.ImGui_GetWindowWidth( ctx )-80, 630) )

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
        reaper.SetThemeColor( v, reaper.ImGui_ColorConvertNative(colors[v]), 0 )
        reaper.ThemeLayout_RefreshAll()
      end

      if pop_style then
        pop_style = false
        r.ImGui_PopStyleColor(ctx, 3)
      end

      reaper.ImGui_PopItemWidth( ctx ) -- Restore max with of input
    end

    last_tab = CopyTable(tab) -- Copy filtered keys
    last_filter_color = filter_color
    last_palette_toggle = palette_toggle

    reaper.ImGui_End(ctx)

  end
  
  reaper.ImGui_PopStyleColor(ctx) -- Remove black opack background

  if not imgui_open then
    reaper.ImGui_DestroyContext(ctx)
  else
    reaper.defer(loop)
  end

end

loop()
