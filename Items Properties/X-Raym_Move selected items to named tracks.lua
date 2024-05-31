--[[
 * ReaScript Name: Move selected items to named tracks
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.1.2
--]]

--[[
 * Changelog:
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

reaimgui_force_version = "0.8.7.6" -- false or string like "0.8.4"
----------------- END OF USER CONFIG AREA

ext_name = "XR_MoveItemsToNamedTrack"

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
      color =  color > 0 and reaper.ImGui_ColorConvertNative( color ) or 0,
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

  local draw_list = reaper.ImGui_GetWindowDrawList(ctx)
  local x, y = reaper.ImGui_GetCursorScreenPos(ctx)
  local size = reaper.ImGui_GetTextLineHeight(ctx)
  reaper.ImGui_DrawList_AddRectFilled(draw_list, x, y, x + size, y + size, color)

  local pad = reaper.ImGui_GetStyleVar(ctx, reaper.ImGui_StyleVar_FramePadding())
  reaper.ImGui_SetCursorScreenPos(ctx, x + size + pad, y)
end

function Run()

  -- TODO: dock
  --[[
  dock_id = -2
  if dock_id then
    reaper.ImGui_SetNextWindowDockID(ctx, dock_id)
    dock_id = nil
  end
  ]]
  local imgui_visible, imgui_open = reaper.ImGui_Begin(ctx, input_title, true, reaper.ImGui_WindowFlags_NoCollapse())
  if imgui_visible then

    count_sel_items = reaper.CountSelectedMediaItems(0)

    imgui_width, imgui_height = reaper.ImGui_GetWindowSize( ctx )

    tracks = SaveTracks()

    -- CUSTOM COMBO
    reaper.ImGui_SetNextItemWidth( ctx, imgui_width -25 )
    if not current_track and vars.track_id and tracks[vars.track_id] then current_track = vars.track_id end

    local combo_pos = {reaper.ImGui_GetCursorScreenPos(ctx)}

    if reaper.ImGui_BeginCombo(ctx, '##combo_tracks', '') then

      for i,v in ipairs(tracks) do
        reaper.ImGui_PushID(ctx, i)

        colorSquare(ctx, v.color)

        if reaper.ImGui_Selectable(ctx, v.name, current_track == i, reaper.ImGui_SelectableFlags_SpanAllColumns()) then
          current_track = i
        end

        reaper.ImGui_PopID(ctx)
      end

      reaper.ImGui_EndCombo(ctx)
    end

    -- move the cursor back to the beginning of the combo box
    local backup_pos = {reaper.ImGui_GetCursorScreenPos(ctx)}
    local pad_x, pad_y = reaper.ImGui_GetStyleVar(ctx, reaper.ImGui_StyleVar_FramePadding())
    reaper.ImGui_SetCursorScreenPos(ctx, combo_pos[1] + pad_x, combo_pos[2] + pad_y)

    -- do the custom preview
    local v = tracks[current_track]
    if v then
      colorSquare(ctx, v.color)
      reaper.ImGui_PushClipRect(ctx, combo_pos[1] + pad_x, combo_pos[2] + pad_y, combo_pos[1] + pad_x + imgui_width-50, combo_pos[2] + pad_y + 200, true) -- Text need clipping based on imgui_width / combo width
      reaper.ImGui_Text(ctx, v.name)
      reaper.ImGui_PopClipRect( ctx ) -- remove clipping
    end

    -- restore the cursor to the end of the combo box
    reaper.ImGui_SetCursorScreenPos(ctx, table.unpack(backup_pos))

    ------

    -- OK BUTTON
    local break_point = 270
    local button_width = imgui_width > break_point and imgui_width / 3 or imgui_width - 15
    reaper.ImGui_Dummy( ctx, 50, 13*2 )
    reaper.ImGui_Spacing( ctx )
    if imgui_width > break_point then reaper.ImGui_SameLine(ctx, imgui_width / 6) end
    if reaper.ImGui_Button(ctx, 'Move', button_width, 35) then -- Ok
      Main()
    end
    if imgui_width > break_point then reaper.ImGui_SameLine(ctx) end
    if reaper.ImGui_Button(ctx, 'Move & Quit', button_width, 35) or reaper.ImGui_IsKeyPressed(ctx, 13) then -- Ok or Enter Key
      Main()
      process = true
    end
    reaper.ImGui_End(ctx)
  end

  if process or not imgui_open then
    reaper.ImGui_DestroyContext(ctx)
  else
    reaper.defer(Run)
  end

end

function Init()
  if popup then
    if not preset_file_init then
      GetValsFromExtState()
    end

    SetButtonState( 1 )
    reaper.atexit( Exit )
    ctx = reaper.ImGui_CreateContext(input_title)
    Run()
  else
    Main()
  end
end

if not preset_file_init then
  Init()
end
