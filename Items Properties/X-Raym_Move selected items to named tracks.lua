--[[
 * ReaScript Name: Move selected items to named tracks
 * Author: X-Raym
 * Author URI: https://extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0.1
--]]

--[[
 * Changelog:
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
----------------- END OF USER CONFIG AREA

ext_name = "XR_MoveItemsToNamedTrack"

if not reaper.ImGui_CreateContext then 
  reaper.MB("Missing dependency: ReaImGui extension.\nDownload it via Reapack ReaTeam extension repository.", "Error", 0)
  return false
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
    reaper.MoveMediaItemToTrack(item, tracks[current_track+1])
  end
  vars.track_id = current_track
  SaveState()
end

-- Save track selection
function SaveTracks( t )
  if not t then t = {} end
  local count_track = reaper.CountTracks( 0 )
  for i = 0, count_track - 1 do
    t[i+1] = reaper.GetTrack( 0, i )
  end
  return t
end

function GetTrackNameList(t, char)
  local out = {}
  for i, track in ipairs( t ) do
    local retval, track_name = reaper.GetTrackName(track)
    out[i] = i .. ": " .. track_name
  end
  return table.concat(out, char) .. "\31"
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

function Run()

  local imgui_visible, imgui_open = reaper.ImGui_Begin(ctx, input_title, true, reaper.ImGui_WindowFlags_NoCollapse())
  if imgui_visible then
  
    tracks = SaveTracks{}
  
    imgui_width, imgui_height = reaper.ImGui_GetWindowSize( ctx )
    ------
    reaper.ImGui_SetNextItemWidth( ctx, imgui_width -25 )
    if not current_track and vars.track_id and tracks[vars.track_id] then current_track = vars.track_id end
    retval, current_track, tracks_name = reaper.ImGui_Combo( ctx, "##combo_tracks", current_track, GetTrackNameList(tracks, "\31"), 500 )
    
    -- OK BUTTON
    local button_width = imgui_width / 3
    reaper.ImGui_Dummy( ctx, 50, 13*2 )
    reaper.ImGui_Spacing( ctx )
    reaper.ImGui_SameLine(ctx, imgui_width / 6)
    if reaper.ImGui_Button(ctx, 'OK', button_width, 35) or reaper.ImGui_IsKeyPressed(ctx, 13) then -- Ok or Enter Key
      Main()
    end
    reaper.ImGui_SameLine(ctx)
    if reaper.ImGui_Button(ctx, 'OK & Quit', button_width, 35) or reaper.ImGui_IsKeyPressed(ctx, 13) then -- Ok or Enter Key
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
