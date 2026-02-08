--[[
 * ReaScript Name: List installed FX according to their installation order (ReaImGui)
 * About: This script is just a proof of concept
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Licence: GPL v3
 * Version: 0.2.4
--]]

--[[
 * Changelog:
 * v0.2.4 (2025-01-28)
  # Window resize border color
  # Moving window with click and drag titlebar only
 * v0.2.2 (2025-01-06)
  # Renamed with ReaImGui suffix
  # ReaImGui v0.9.3.2
  # Dark Theme
 * v0.2.1 (2024-04-13)
  # Force reaimgui version
 * v0.2 (2023-11-13)
  # Remove JSFX cause can't work as expected
 * v0.1 (2023-07-26)
  + Initial release
--]]

--------------------------------------------------------------------------------
-- USER CONFIG AREA --
--------------------------------------------------------------------------------

console = true -- Display debug messages in the console
reaimgui_force_version = "0.9.3.2"-- false or string like "0.8.4"

--------------------------------------------------------------------------------
                                                   -- END OF USER CONFIG AREA --
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- GLOBALS --
--------------------------------------------------------------------------------

input_title = "XR - List installed FX"

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
  TextSelectedBg    = 0x292929ff, -- Search Field Selected Text
  SeparatorHovered  = 0x606060ff,
  SeparatorActive   = 0x404040ff,
  CheckMark         = 0xffffffff, -- CheckMark
}

--------------------------------------------------------------------------------
-- DEPENDENCIES --
--------------------------------------------------------------------------------

imgui_path = reaper.ImGui_GetBuiltinPath and ( reaper.ImGui_GetBuiltinPath() .. '/imgui.lua' )

if not imgui_path then
  reaper.MB("Missing dependency: ReaImGui extension.\nDownload it via Reapack ReaTeam extension repository.", "Error", 0)
  return false
end

local ImGui = dofile(imgui_path) (reaimgui_force_version)

--------------------------------------------------------------------------------
                                                       -- END OF DEPENDENCIES --
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- DEBUG --
--------------------------------------------------------------------------------

function Msg( value )
  if console then
    reaper.ShowConsoleMsg( tostring( value ) .. "\n" )
  end
end

--------------------------------------------------------------------------------
-- DEFER --
--------------------------------------------------------------------------------

-- Set ToolBar Button State
function SetButtonState( set )
  local is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  reaper.SetToggleCommandState( sec, cmd, set or 0 )
  reaper.RefreshToolbar2( sec, cmd )
end

function Exit()
  SetButtonState()
end

--------------------------------------------------------------------------------
-- TABLES --
--------------------------------------------------------------------------------

function SortTable( tab, val1, val2)
  -- SORT TABLE
  -- thanks to https://forums.coronalabs.com/topic/37595-nested-sorting-on-multi-dimensional-array/
  table.sort(tab, function( a,b )
    if (a[val1] < b[val1]) then
      -- primary sort on position -> a before b
      return true
    elseif (a[val1] > b[val1]) then
      -- primary sort on position -> b before a
      return false
    else
      -- primary sort tied, resolve w secondary sort on rank
      return a[val2] < b[val2]
    end
  end)
end

function ReverseTable(t)
    local reversedTable = {}
    local itemCount = #t
    for k, v in ipairs(t) do
        reversedTable[itemCount + 1 - k] = v
    end
    return reversedTable
end

--------------------------------------------------------------------------------
-- OTHER --
--------------------------------------------------------------------------------

function read_lines(filepath)
  local lines = {}
  local f = io.input(filepath)
  if not f then return false end
  repeat
    local s = f:read ("*l") -- read one line
    if s then  -- if not end of file (EOF)
      table.insert(lines, s)
    end
  until not s  -- until end of file
  f:close()
  return lines
end

-- CSV to Table
-- http://lua-users.org/wiki/LuaCsv
-- Mod by X-Raym to support either ' or " as escpaing character.
function ParseCSVLine2(line,sep)
  local res = {}
  local pos = 1
  sep = sep or ','
  while true do
    local c = string.sub(line,pos,pos)
    if c == "" then break end
    if c == "'" or c == '"' or c == '`' then
      local quote = c
      local other_quote = '"'
      -- quoted value (ignore separator within)
      local txt = ""
      repeat
        local startp,endp = string.find(line,"^%b".. quote .. quote,pos)
        txt = txt..string.sub(line,startp+1,endp-1)
        pos = endp + 1
        c = string.sub(line,pos,pos)
        if (c == other_quote) then txt = txt..other_quote end
        -- check first char AFTER quoted string, if it is another
        -- quoted string without separator, then append it
        -- this is the way to "escape" the quote char in a quote. example:
        --   value1,"blub""blip""boing",value3  will result in blub"blip"boing  for the middle
      until (c ~= quote)
      table.insert(res,txt)
      assert(c == sep or c == "")
      pos = pos + 1
    else
      -- no quotes used, just look for the first separator
      local startp,endp = string.find(line,sep,pos)
      if (startp) then
        table.insert(res,string.sub(line,pos,startp-1))
        pos = endp + 1
      else
        -- no separator found -> use rest of string and terminate
        table.insert(res,string.sub(line,pos))
        break
      end
    end
  end
  return res
end

-- Split file name
function SplitFileName( strfilename )
  -- Returns the Path, Filename, and Extension as 3 values
  local path, file_name, extension = string.match( strfilename, "(.-)([^\\|/]-([^\\|/%.]+))$" )
  file_name = string.match( file_name, ('(.+)%.(.+)') )
  return path, file_name, extension
end

--------------------------------------------------------------------------------
-- REAIMGUI --
--------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------
-- MAIN --
--------------------------------------------------------------------------------
os_sep = package.config:sub(1,1)
user_resource_folder = reaper.GetResourcePath() .. os_sep

function GetVST64FXPlugins()
  local plugins = {}
  local file = user_resource_folder .. "reaper-vstplugins64.ini"
  local lines = read_lines( file )
  if not lines then return false end
  for i, line in ipairs( lines ) do
    local plugin_filename, values = line:match("(.+)=(.+)") -- TODO: Multiple FX can registered from one single dll, see <SHELL>
    if plugin_filename then
      local values_t = ParseCSVLine2( values, "," )
      if values_t[3] then
        --table.insert( plugins, {file_name = plugin_filename, name = values_t[3] } )
        table.insert( plugins, { name = values_t[3]:gsub("!!!VSTi",""), file = plugin_filename } )
      end
    end
  end
  return plugins
end

function GetVST64FXPluginsPaths()
  if not fx_plugins_vst64 or #fx_plugins_vst64 == 0 then return end

  local reaper_ini_file = reaper.get_ini_file()
  local retval, config_paths_str = reaper.BR_Win32_GetPrivateProfileString( "reaper", "vstpath64", "",  reaper_ini_file  )
  if not retval or config_paths_str == "" then return end
  config_paths = ParseCSVLine2(config_paths_str,";")

  local files_folder = {}
  --a  = {}
  for i, path in pairs( config_paths ) do
    local files = EnumerateFilesRescursiveSubFolder( path )
    for z, file in ipairs( files ) do
      local folder, file_name, ext = SplitFileName( file )
      if file_name and (ext == "dll" or ext == "vst3") then
        files_folder[file_name:gsub(" ", "_") .. "." .. ext] = folder
        --table.insert( a, file_name .. "." .. ext .. "\t" .. folder )
      end
    end
  end

  --reaper.CF_SetClipboard( table.concat( a, "\n" ) )

  return files_folder
end

-----------------------------------------------------------
-- FILES --
-----------------------------------------------------------

function EnumerateFiles( folder )
  local files = {}
  local i = 0
  repeat
    local retval = reaper.EnumerateFiles( folder, i )
    if retval then
      table.insert(files, folder .. os_sep .. retval)
    end
    i = i + 1
  until not retval
  return files
end

function EnumerateFilesRescursiveSubFolder( folder, files )
  if not files then files = {} end

  folder = folder:gsub( os_sep .. "*$", "") -- removing end os_path

  local current_folder_files = EnumerateFiles( folder )
  for i, v in ipairs(current_folder_files) do
      table.insert(files, v)
  end

  local subfolder = 0
  local retval = false

  repeat
    retval = reaper.EnumerateSubdirectories( folder, subfolder )
    if retval and retval ~= "" then
      subfolder = subfolder + 1
      local files_sub = EnumerateFilesRescursiveSubFolder( folder .. os_sep .. retval, files )
    end
  until not retval or retval == ""

  return files
end

-----------------------------------------------------------
                                         -- END OF FILES --
-----------------------------------------------------------


fx_plugins_vst64 = ReverseTable( GetVST64FXPlugins() )

function Main()
  ImGui.TextWrapped(ctx, [[This script is a proof of concept. Only VST is supported for now. No solution possible for JSFX cause their index file doesn't have any kind of date info and is sorted alphabetically]] )
  ImGui.Dummy( ctx, 10, 10 )

  ImGui.Text( ctx, "Search:")
  ImGui.PushItemWidth(ctx, -1) -- Set max with of inputs
  r, search = ImGui.InputText( ctx, "##search##" )

  ImGui.Text( ctx, "VST")
  --local cur_y = ImGui.GetCursorPosY( ctx )
  --ImGui.InputTextMultiline( ctx, "##vst64", table.concat(fx_plugins_vst64, "\n"), imgui_width - 20, (imgui_height-cur_y-10) ) -- height could be divised by the number of text area
  if ImGui.BeginTable(ctx, '##table_output', 3, ImGui.TableFlags_SizingFixedFit ) then
    ImGui.TableHeadersRow(ctx)
    ImGui.TableSetColumnIndex(ctx, 0)
    ImGui.TableHeader( ctx, "Folder" )
    ImGui.TableSetColumnIndex(ctx, 1)
    ImGui.TableHeader( ctx, "Add to Track" )
    ImGui.TableSetColumnIndex(ctx, 2)
    ImGui.TableHeader( ctx, "FX Name" )

    for i, v in ipairs( fx_plugins_vst64 ) do

      if search == "" or v.name:lower():find(search) then
        ImGui.TableNextRow(ctx)

        ImGui.TableSetColumnIndex(ctx, 0)
        if ImGui.Button( ctx, 'Open##open_' .. i ) then
          fx_plugins_vst64_paths = fx_plugins_vst64_paths or GetVST64FXPluginsPaths()
          reaper.CF_ShellExecute( fx_plugins_vst64_paths[v.file] )
        end
        ImGui.TableSetColumnIndex(ctx, 1)
        if ImGui.Button( ctx, 'Add##add_' .. i ) then
          local track = reaper.GetSelectedTrack(0,0)
          if track then
            local fx = reaper.TrackFX_AddByName( track, v.name, false, -1 )
            if fx >= 0 then
              reaper.TrackFX_SetOpen( track, fx, true )
            end
          end
        end
        ImGui.TableSetColumnIndex(ctx, 2)
        ImGui.SetNextItemWidth( ctx, imgui_width )
        ImGui.InputText(ctx, "##" .. i,  v.name)
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

    Main()

    --------------------

    ImGui.End(ctx)
  end

  ImGui.PopStyleColor(ctx, count_theme_colors)
  ImGui.PopFont(ctx)

  if imgui_open and not ImGui.IsKeyPressed(ctx, ImGui.Key_Escape) and not process then
    reaper.defer(Run)
  end

end -- END DEFER

--------------------------------------------------------------------------------
-- INIT --
--------------------------------------------------------------------------------

function Init()
  SetButtonState( 1 )
  reaper.atexit( Exit )

  ctx = ImGui.CreateContext( input_title, ImGui.ConfigFlags_DockingEnable | ImGui.ConfigFlags_NavEnableKeyboard )
  ImGui.SetConfigVar( ctx, ImGui.ConfigVar_DockingNoSplit, 1 )
  ImGui.SetConfigVar( ctx, ImGui.ConfigVar_WindowsMoveFromTitleBarOnly, 1 )

  font = ImGui.CreateFont('sans-serif', 16)
  ImGui.Attach(ctx, font)

  reaper.defer(Run)
end

if not preset_file_init then
  Init()
end


