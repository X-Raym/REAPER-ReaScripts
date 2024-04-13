--[[
 * ReaScript Name: List installed FX according to their installation order (ReaImGui)
 * About: This script is just a proof of concept
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Licence: GPL v3
 * Version: 0.2.1
--]]

--[[
 * Changelog:
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
reaimgui_force_version = "0.8.7.6"-- false or string like "0.8.4"

--------------------------------------------------------------------------------
                                                   -- END OF USER CONFIG AREA --
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- GLOBALS --
--------------------------------------------------------------------------------

input_title = "XR - List installed FX"

--------------------------------------------------------------------------------
-- DEPENDENCIES --
--------------------------------------------------------------------------------

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
    local plugin_filename, values = line:match("(.+)=(.+)")
    if plugin_filename then
      local values_t = ParseCSVLine2( values, "," )
      if values_t[3] then
        --table.insert( plugins, {file_name = plugin_filename, name = values_t[3] } )
        table.insert( plugins, plugin_filename)
      end
    end
  end
  return plugins
end

fx_plugins_vst64 = ReverseTable( GetVST64FXPlugins() )

function Main()
  reaper.ImGui_TextWrapped(ctx, [[This script is a proof of concept. Only VST is supported for now. No solution possible for JSFX cause their index file doesn't have any kind of date info and is sorting alphabetically]] )
  reaper.ImGui_Dummy( ctx, 10, 10 )
  reaper.ImGui_Text( ctx, "VST")
  local cur_y = reaper.ImGui_GetCursorPosY( ctx )
  reaper.ImGui_InputTextMultiline( ctx, "##vst64", table.concat(fx_plugins_vst64, "\n"), imgui_width - 20, (imgui_height-cur_y-10) ) -- height could be divised by the number of text area
end

function Run()

  reaper.ImGui_SetNextWindowBgAlpha( ctx, 1 )

  reaper.ImGui_PushFont(ctx, font)
  reaper.ImGui_SetNextWindowSize(ctx, 800, 200, reaper.ImGui_Cond_FirstUseEver())

  if set_dock_id then
    reaper.ImGui_SetNextWindowDockID(ctx, set_dock_id)
    set_dock_id = nil
  end

  local imgui_visible, imgui_open = reaper.ImGui_Begin(ctx, input_title, true, reaper.ImGui_WindowFlags_NoCollapse())

  if imgui_visible then

    imgui_width, imgui_height = reaper.ImGui_GetWindowSize( ctx )

    Main()

    --------------------

    reaper.ImGui_End(ctx)
  end

  reaper.ImGui_PopFont(ctx)

  if imgui_open and not reaper.ImGui_IsKeyPressed(ctx, reaper.ImGui_Key_Escape()) and not process then
    reaper.defer(Run)
  end

end -- END DEFER

--------------------------------------------------------------------------------
-- INIT --
--------------------------------------------------------------------------------

function Init()
  SetButtonState( 1 )
  reaper.atexit( Exit )

  ctx = reaper.ImGui_CreateContext(input_title)
  font = reaper.ImGui_CreateFont('sans-serif', 16)
  reaper.ImGui_Attach(ctx, font)

  reaper.defer(Run)
end

if not preset_file_init then
  Init()
end

