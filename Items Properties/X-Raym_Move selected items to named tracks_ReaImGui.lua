--[[
 * ReaScript Name: Move selected items to named tracks (ReaImGui)
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.1.6
--]]

--[[
 * Changelog:
 * v1.1.6 (2025-01-28)
  # Window resize border color
  # Moving window with click and drag titlebar only
 * v1.1.5 (2025-01-09)
  # Exit via context menu
 * v1.1.3 (2025-01-05)
  # Renamed
  # Theme
  # ReaImGui v0.9.3.2
 * v1.1.2 (2024-05-31)
  # Basic shim to ReaImGui v0.8.7.6
 * v1.1 (2021-07-20)
  + Track color label using custom render (thx cfillion!)
  + Track depth character prefix
  + Responsive button layouts
  # Ok label is now Move
 * v1.0 (2021-07-19)
  + Initial Release
--]]

-- USER CONFIG AREA ---------------------
console = true
popup = true -- User input dialog box

vars = vars or {}
vars.track_id = 1

input_title = "Move Items to Named Tracks"
undo_text = "Move selected items to named tracks"

reaimgui_force_version = "0.9.3.2" -- false or string like "0.8.4"

----------------- END OF USER CONFIG AREA

ext_name = "XR_MoveItemsToNamedTrack"

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

-----------------------------------------------------------
-- DEPENDENCIES --
-----------------------------------------------------------

imgui_path = reaper.ImGui_GetBuiltinPath and ( reaper.ImGui_GetBuiltinPath() .. '/imgui.lua' )

if not imgui_path then
  reaper.MB("Missing dependency: ReaImGui extension.\nDownload it via Reapack ReaTeam extension repository.", "Error", 0)
  return false
end

local ImGui = dofile(imgui_path) (reaimgui_force_version)

-----------------------------------------------------------
                                  -- END OF DEPENDENCIES --
-----------------------------------------------------------

-- Console Message
function Msg(g)
  if console then
    reaper.ShowConsoleMsg(tostring(g).."\n")
  end
end

function SaveState()
  if ValidateVals( vars ) then
    for k, v in pairs( vars ) do
      reaper.SetExtState( ext_name, k, tostring(v), true )
    end
  end
end

function GetExtState( var, val )
  local val_original = val
  local t = type( val )
  if reaper.HasExtState( ext_name, var ) then
    val = reaper.GetExtState( ext_name, var )
  end
  if t == "boolean" then val = toboolean( val )
  elseif t == "number" then val = tonumber( val )
  else
  end
  if val == nil then val = val_original end
  return val
end

function GetValsFromExtState()
  for k, v in pairs( vars ) do
    vars[k] = GetExtState( k, vars[k] )
  end
end

function SetButtonState( set )
  if not set then set = 0 end
  local is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  local state = reaper.GetToggleCommandStateEx( sec, cmd )
  reaper.SetToggleCommandState( sec, cmd, set ) -- Set ON
  reaper.RefreshToolbar2( sec, cmd )
end

function Exit()
  SaveState()
  SetButtonState()
end

function SaveExtState( var, val)
  reaper.SetExtState( ext_name, var, tostring(val), true )
end

function ValidateVals( vars )
  local validate = true
  for k, v in pairs( vars ) do
    if vars[k] == nil then
      validate = false
      break
    end
  end
  return validate
end

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

-- Save item selection
function SaveSelectedItems(t)
  local t = t or {}
  for i = 0, reaper.CountSelectedMediaItems(0)-1 do
    t[i+1] = reaper.GetSelectedMediaItem(0, i)
  end
  return t
end

function Process()
  local sel_items = SaveSelectedItems(t)
  for i, item in ipairs(sel_items) do
    reaper.MoveMediaItemToTrack(item, tracks[current_track].track)
  end
  vars.track_id = current_track
  SaveState()
end

-- Save track selection
function SaveTracks( t )
  if not t then t = {} end
  local count_track = reaper.CountTracks( 0 )
  for i = 0, count_track - 1 do
    local track = reaper.GetTrack(0,i)
    local retval, track_name = reaper.GetTrackName( track )
    local track_depth = reaper.GetTrackDepth(track)
    local indent = ""
    for j = 1, track_depth do
      indent = indent .. "-"
    end
    track_name = i .. ": " .. indent .. track_name
    local color = reaper.GetMediaTrackInfo_Value( track, "I_CUSTOMCOLOR")
    t[i+1] = {
      track = track,
      color =  color > 0 and ImGui.ColorConvertNative( color ) or 0,
      name = track_name
    }
  end
  return t
end


function Main()
  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  reaper.ClearConsole()

  Process() -- Execute your main function

  reaper.Undo_EndBlock(undo_text, -1) -- End of the undo block. Leave it at the bottom of your main function.

  reaper.UpdateArrange() -- Update the arrangement (often needed)

  reaper.PreventUIRefresh(-1)
end

function colorSquare(ctx, color)
  color = (color << 8) | 0xff -- RGB to RGBA with 100% opacity

  local draw_list = ImGui.GetWindowDrawList(ctx)
  local x, y = ImGui.GetCursorScreenPos(ctx)
  local size = ImGui.GetTextLineHeight(ctx)
  ImGui.DrawList_AddRectFilled(draw_list, x, y, x + size, y + size, color)

  local pad = ImGui.GetStyleVar(ctx, ImGui.StyleVar_FramePadding)
  ImGui.SetCursorScreenPos(ctx, x + size + pad, y)
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

    count_sel_items = reaper.CountSelectedMediaItems(0)

    imgui_width, imgui_height = ImGui.GetWindowSize( ctx )

    tracks = SaveTracks()

    -- CUSTOM COMBO
    ImGui.SetNextItemWidth( ctx, imgui_width -25 )
    if not current_track and vars.track_id and tracks[vars.track_id] then current_track = vars.track_id end

    local combo_pos = {ImGui.GetCursorScreenPos(ctx)}

    if ImGui.BeginCombo(ctx, '##combo_tracks', '') then

      for i,v in ipairs(tracks) do
        ImGui.PushID(ctx, i)

        colorSquare(ctx, v.color)

        if ImGui.Selectable(ctx, v.name, current_track == i, ImGui.SelectableFlags_SpanAllColumns) then
          current_track = i
        end

        ImGui.PopID(ctx)
      end

      ImGui.EndCombo(ctx)
    end

    -- move the cursor back to the beginning of the combo box
    local backup_pos = {ImGui.GetCursorScreenPos(ctx)}
    local pad_x, pad_y = ImGui.GetStyleVar(ctx, ImGui.StyleVar_FramePadding)
    ImGui.SetCursorScreenPos(ctx, combo_pos[1] + pad_x, combo_pos[2] + pad_y)

    -- do the custom preview
    local v = tracks[current_track]
    if v then
      colorSquare(ctx, v.color)
      ImGui.PushClipRect(ctx, combo_pos[1] + pad_x, combo_pos[2] + pad_y, combo_pos[1] + pad_x + imgui_width-50, combo_pos[2] + pad_y + 200, true) -- Text need clipping based on imgui_width / combo width
      ImGui.Text(ctx, v.name)
      ImGui.PopClipRect( ctx ) -- remove clipping
    end

    -- restore the cursor to the end of the combo box
    ImGui.SetCursorScreenPos(ctx, table.unpack(backup_pos))

    ------

    -- OK BUTTON
    local break_point = 270
    local button_width = imgui_width > break_point and imgui_width / 3 or imgui_width - 15
    ImGui.Dummy( ctx, 50, 13*2 )
    ImGui.Spacing( ctx )
    if imgui_width > break_point then ImGui.SameLine(ctx, imgui_width / 6) end
    if ImGui.Button(ctx, 'Move', button_width, 35) then -- Ok
      Main()
    end
    if imgui_width > break_point then ImGui.SameLine(ctx) end
    if ImGui.Button(ctx, 'Move & Quit', button_width, 35) or ImGui.IsKeyPressed(ctx, ImGui.Key_Enter) then -- Ok or Enter Key
      Main()
      process = true
    end
    ImGui.End(ctx)
  end

  ImGui.PopStyleColor(ctx, count_theme_colors)
  ImGui.PopFont(ctx)

  if imgui_open and not ImGui.IsKeyPressed(ctx, ImGui.Key_Escape) and not process and not exit then
    reaper.defer(Run)
  end

end

function Init()
  if popup then
    if not preset_file_init and not reset then
      GetValsFromExtState()
    end

    SetButtonState( 1 )
    reaper.atexit( Exit )

    ctx = ImGui.CreateContext( input_title, ImGui.ConfigFlags_DockingEnable | ImGui.ConfigFlags_NavEnableKeyboard )
    ImGui.SetConfigVar( ctx, ImGui.ConfigVar_DockingNoSplit, 1 )
    ImGui.SetConfigVar( ctx, ImGui.ConfigVar_WindowsMoveFromTitleBarOnly, 1 )

    font = ImGui.CreateFont('sans-serif', 16)
    ImGui.Attach(ctx, font)

    Run()
  else
    Main()
  end
end

if not preset_file_init then
  Init()
end

