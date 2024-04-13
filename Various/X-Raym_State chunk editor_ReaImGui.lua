--[[
 * ReaScript Name: State chunk editor (ReaImGui)
 * Screenshot: https://i.imgur.com/fCw0Flt.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: X-Raym Premium Scripts
 * Licence: GPL v3
 * Version: 1.0.3
--]]

--[[
 * Changelog:
 * v1.0.3 (2024-04-13)
  # Force reaimgui version
 * v1.0 (2024-01-03)
  # Fix env chunk
 * v1.0 (2024-01-03)
  + Initial release
--]]

----------------------------------------------------------------------
-- USER CONFIG AREA --
----------------------------------------------------------------------

-- Use Preset Script for safe moding or to create a new action with your own values
-- https://github.com/X-Raym/REAPER-ReaScripts/tree/master/Templates/Script%20Preset

console = true -- Display debug messages in the console
reaimgui_force_version = "0.8.7.6" -- false or string like "0.8.4"

----------------------------------------------------------------------
                                         -- END OF USER CONFIG AREA --
----------------------------------------------------------------------

----------------------------------------------------------------------
-- GLOBALS --
----------------------------------------------------------------------

input_title = "XR - State Chunk Editor"

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
-- OTHER --
----------------------------------------------------------------------

-- remove trailing and leading whitespace from string.
-- http://en.wikipedia.org/wiki/Trim_(programming)
function trim(s)
  -- from PiL2 20.4
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function FormatChunk( str )
  local t = {""}
  local indent = 0
  local i = 0
  -- split into lines and loop for each line
  for line in string.gmatch(str, '[^\r\n]+') do
    i = i + 1
    if line == ">" then -- whole line is just > means end of tag
      indent = indent - 1
    end
    local will_increment = false
    if line:sub(1, 1) == "<" then
      will_increment = true
    end
    for z = 1, indent do
      line = "  " .. line
    end
    if will_increment then
      indent = indent + 1
    end
    t[i] = line
  end
  return table.concat( t, "\n" )
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

----------------------------------------------------------------------
                                                    -- END OF IMGUI --
----------------------------------------------------------------------

----------------------------------------------------------------------
-- MAIN --
----------------------------------------------------------------------
destination = 1
txts = { "", "" }
function Main()

  local chunk = ""

  if reaper.ImGui_Button( ctx, "Get Track" ) then
    local track = reaper.GetSelectedTrack( 0, 0 )
    if track then
      local retval, track_chunk = reaper.GetTrackStateChunk( track, "", false )
      chunk = FormatChunk( track_chunk )
    end
  end
  
  reaper.ImGui_SameLine( ctx )
  
  if reaper.ImGui_Button( ctx, "Get Item" ) then
    local item = reaper.GetSelectedMediaItem( 0, 0 )
    if item then
      local retval, item_chunk = reaper.GetItemStateChunk( item, "", false )
      chunk = FormatChunk( item_chunk )
    end
  end
  
  reaper.ImGui_SameLine( ctx )
  
  if reaper.ImGui_Button( ctx, "Get Envelope" ) then
    local env = reaper.GetSelectedEnvelope( 0 )
    if env then
      local retval, env_chunk = reaper.GetEnvelopeStateChunk( env, "", false )
      chunk = FormatChunk( env_chunk )
    end
  end
  
  if chunk ~= "" then
    txts[ destination ] = chunk
  end
  
  if reaper.ImGui_Button( ctx, "Set Track" ) then
    local track = reaper.GetSelectedTrack( 0, 0 )
    if track then
      local retval, track_chunk = reaper.SetTrackStateChunk( track, txts[ destination ], true )
      reaper.Undo_OnStateChange( "Set track state" )
    end
  end
  
  reaper.ImGui_SameLine( ctx )
  
  if reaper.ImGui_Button( ctx, "Set Item" ) then
    local item = reaper.GetSelectedMediaItem( 0, 0 )
    if item then
      local retval, item_chunk = reaper.SetItemStateChunk( item, txts[ destination ], true )
      reaper.Undo_OnStateChange( "Set item state" )
    end
  end
  
  reaper.ImGui_SameLine( ctx )
  
  if reaper.ImGui_Button( ctx, "Set Envelope" ) then
    local env = reaper.GetSelectedEnvelope( 0 )
    if env then
      local retval, env_chunk = reaper.SetEnvelopeStateChunk( env, txts[ destination ], true )
      reaper.Undo_OnStateChange( "Set env state" )
    end
  end
  
  local w = imgui_width/2 - 10
  local h = math.max( 200, imgui_height-140)

  if reaper.ImGui_BeginChild(ctx, 'left_panel', w, nil, true, reaper.ImGui_WindowFlags_MenuBar()) then
    
    if reaper.ImGui_BeginMenuBar(ctx) then
      reaper.ImGui_Text(ctx,'Chunk 1')
      reaper.ImGui_EndMenuBar(ctx)
    end
    
    retval, txts[1] = reaper.ImGui_InputTextMultiline( ctx, "##Text1", txts[1], w-10, h,  reaper.ImGui_InputTextFlags_AllowTabInput() )
    if reaper.ImGui_IsItemActive( ctx ) then
      destination = 1
    end
    reaper.ImGui_EndChild( ctx )
  end
  reaper.ImGui_SameLine( ctx )
  if reaper.ImGui_BeginChild(ctx, 'right_panel', w, nil, true, reaper.ImGui_WindowFlags_MenuBar()) then
    
    if reaper.ImGui_BeginMenuBar(ctx) then
      reaper.ImGui_Text(ctx,'Chunk 2')
      reaper.ImGui_EndMenuBar(ctx)
    end
    
    retval, txts[2] = reaper.ImGui_InputTextMultiline( ctx, "##Text2", txts[2], w-10, h,  reaper.ImGui_InputTextFlags_AllowTabInput() )
    if reaper.ImGui_IsItemActive( ctx ) then
      destination = 2
    end
    reaper.ImGui_EndChild( ctx )
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
  
  reaper.ClearConsole()

  ctx = reaper.ImGui_CreateContext(input_title,  reaper.ImGui_ConfigFlags_DockingEnable())
  font = reaper.ImGui_CreateFont('sans-serif', 16)
  reaper.ImGui_Attach(ctx, font)

  Run()
end

if not preset_file_init then
  Init()
end

