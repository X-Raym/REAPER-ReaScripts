--[[
 * ReaScript Name: Toggle focused FX chain panel.lua
 * Screenshot: https://i.imgur.com/dYiR6e3.gif
 * About: Works on Take FX, Track FX, Input Track FX, Master FX, and Monitor FX.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: https://github.com/X-Raym/REAPER-Scripts
 * Licence: GPL v3
 * REAPER: 6.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2023-03-30)
  + Initial release
--]]

------------------------------------------------------------
-- USER CONFIG AREA --
------------------------------------------------------------

-- NOTE: Mowing floating FX when the FX window appears is made from FLOATPOS in track chunk
-- you have to mode for moving the floating fx window: defer and chunk
-- defer is more efficient but has a faulty frame cause it can only be done after the window has been opened

move_floating_fx = "chunk" -- "chunk" or "defer"

------------------------------------------------------------
                              -- END OF USER CONFIG AREA --
------------------------------------------------------------

-- HARDCORE: this script was extremly complex because of the different FX chains types, way to save data etc.

------------------------------------------------------------
-- DEPENDENCIES --
------------------------------------------------------------

if not reaper.JS_ReaScriptAPI_Version or not reaper.JS_Window_Destroy then
  reaper.ShowMessageBox( 'Please install or update js_ReaScriptAPI extension, available via Reapack.', 'Missing Dependency', 0)
  return false
end

if not reaper.CF_GetSWSVersion then
  reaper.ShowMessageBox( 'Please Install last SWS extension.', 'Missing Dependency', 0 )
  return false
end

------------------------------------------------------------
-- FUNCTIONS --
------------------------------------------------------------

function ToggleTakeFXChain()
  local is_chain_visible =  reaper.TakeFX_GetChainVisible( take )
  if is_chain_visible == -1 then
    reaper.TakeFX_Show( take, fx_id, 1 ) -- Show Take FX Chain
  else
    reaper.TakeFX_Show( take, fx_id, 0 ) -- Hide Take FX Chain
  end
end

function ToggleTrackFXChain( is_rec )
  local is_chain_visible = ( is_rec and reaper.TrackFX_GetRecChainVisible( track ) ) or reaper.TrackFX_GetChainVisible( track )
  if is_chain_visible == -1 then
    reaper.TrackFX_Show( track, fx_id, 1 ) -- Show Track FX Chain
  else
    reaper.TrackFX_Show( track, fx_id, 0 ) -- Hide Track FX Chain
  end
end

-- https://helloacm.com/split-a-string-in-lua/
function split(s, delimiter)
  local result = {}
  for match in (s..delimiter):gmatch("(.-)"..delimiter) do
    table.insert(result, match)
  end
  return result
end

function SetFloatingPosFXFromChunk( obj, fx_id, left, top, is_monitor_fx )
  local retal, str
  local SetChunk
  if reaper.ValidatePtr( obj, "MediaTrack*" ) then
    if is_monitor_fx then
      local os_sep = package.config:sub(1,1)
      reaper_folder = reaper.GetResourcePath()
      monitor_fx_path = reaper_folder .. os_sep .. "reaper-hwoutfx.ini"
      if not reaper.file_exists( monitor_fx_path ) then return false end
      local file = io.open(monitor_fx_path, "r")
      str = file:read('*a')
      file:close()
      fx_guid = str:match( "FXID (.+)$")
    else
      retval, str = reaper.GetTrackStateChunk( track, "", false )
      fx_guid = reaper.TrackFX_GetFXGUID( track, fx_id )
    end
    SetChunk = reaper.SetTrackStateChunk
  elseif reaper.ValidatePtr( obj, "MediaItem_Take*" ) then
    obj = reaper.GetMediaItemTake_Item( take )
    retval, str = reaper.GetItemStateChunk( item, '', false )
    fx_guid = reaper.TakeFX_GetFXGUID( take, fx_id )
    SetChunk = reaper.SetItemStateChunk
  end
  if not fx_guid or fx_guid == "" or str == "" then return false end

  local lines = split( str, '\n')

  for i, line in ipairs( lines ) do
    if line == "FXID " .. fx_guid then
      float_left, float_top, float_w, float_h = lines[i-1]:match("(%d+) (%d+) (%d+) (%d+)" )
      if float_w == "0" then float_w = 200 end
      if float_h == "0" then float_h = 200 end
      lines[i-1] = "FLOATPOS " .. left .. " " .. top .. " " .. float_w .. " " .. float_h
      str = table.concat( lines, "\n" )
      if is_monitor_fx then
        -- Opens a file in append mode
        local file = io.open(monitor_fx_path, "w")
        file:write( str )
        file:close()
      else
        reaper.CF_SetClipboard( str )
        retval = SetChunk( obj, str, false )
      end
      return retval
    end
  end
end

function Main()

  track = ( track_id == 0 and reaper.GetMasterTrack(0) ) or reaper.GetTrack( 0, track_id - 1 )

  -- ITEM -----------------------------------------------------------
  if item_id >= 0 then

    item = reaper.GetTrackMediaItem( track, item_id )
    take = reaper.GetActiveTake( item )
    take_name = reaper.GetTakeName( take )

    is_chain_visible =  reaper.TakeFX_GetChainVisible( take )
    if is_chain_visible > -1 then
       retval, left, top, right, bottom = reaper.JS_Window_GetRect(  reaper.CF_GetTakeFXChain( take )  )
    end

    ToggleTakeFXChain()

    is_floating = reaper.TakeFX_GetFloatingWindow( take, fx_id )
    if is_floating then
      fx_hwnd = is_floating
      retval, left, top, right, bottom = reaper.JS_Window_GetRect( fx_hwnd )
      reaper.TakeFX_Show( take, fx_id, 2 ) -- close chain
      if is_chain_visible > -1 then
        reaper.TakeFX_Show( take, fx_id, 1 ) -- Put in the the chain which was open at initial state
      end
      local fx_chain = reaper.CF_GetTakeFXChain( take )
      reaper.JS_Window_Move( fx_chain, left, top )
    else
      if move_floating_fx == "chunk" then
        SetFloatingPosFXFromChunk( take, fx_id, left, top )
      end
      reaper.TakeFX_Show( take, fx_id, 3 )
      -- Hack because it is too fast
      -- Need chunk editing
      if move_floating_fx == "defer" then
        reaper.defer( function() reaper.JS_Window_Move( reaper.TakeFX_GetFloatingWindow( take, fx_id ), left, top ) end)
      end
    end

  else -- TRACK -----------------------------------------------------------

    is_rec = fx_id >= 16777216

    is_chain_visible = ( is_rec and reaper.TrackFX_GetRecChainVisible( track ) ) or reaper.TrackFX_GetChainVisible( track )

    if is_chain_visible > -1 then
      fx_chain = reaper.CF_GetTrackFXChainEx( 0, track, is_rec )
      retval, left, top, right, bottom = reaper.JS_Window_GetRect( fx_chain )
    end

    ToggleTrackFXChain( is_rec )

    is_floating = reaper.TrackFX_GetFloatingWindow( track, fx_id )
    if is_floating then
      fx_hwnd = is_floating
      retval, left, top, right, bottom = reaper.JS_Window_GetRect( fx_hwnd )
      reaper.TrackFX_Show( track, fx_id, 2 ) -- close chain
      if is_chain_visible > -1 then
        reaper.TrackFX_Show( track, fx_id, 1 ) -- Put in the the chain which was open at initial state
      end
      local fx_chain = reaper.CF_GetTrackFXChainEx( 0, track, is_rec )
      reaper.JS_Window_Move( fx_chain, left, top )
    else
      if move_floating_fx == "chunk" then
        SetFloatingPosFXFromChunk( track, fx_id, left, top, track_id == 0 and is_rec )
      end
      reaper.TrackFX_Show( track, fx_id, 3 ) -- set as inidividual floating
      -- Hack because it is too fast
      -- Need chunk editing
      if move_floating_fx == "defer" then
        reaper.defer( function() reaper.JS_Window_Move( reaper.TrackFX_GetFloatingWindow( track, fx_id ), left, top ) end)
      end
    end

  end
end

------------------------------------------------------------
-- INIT --
------------------------------------------------------------

function Init()
  retval, track_id, item_id, fx_id = reaper.GetFocusedFX2()
  a_retval, a_track_id, a_dx_id = retval, track_id, item_id, fx_id -- debug on top
  if retval == 0 then return false end

  reaper.defer( Main )
end

if not preset_file_init then
  Init()
end
