--[[
 * ReaScript Name: Play first selected item once from first snap offset position
 * About: Just like the SWS action Xenakios/SWS: Play selected items once but from snap offset pos
 * Screenshot: https://i.imgur.com/80v4gQk.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > ReaScripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.1
--]]

play_action = 1007 -- Transport: Play
move_view = true
seek_play = false
console = false

ext_name = "XR_PlayItemsOnce"

function Main_OnCommand( val )
  if not tonumber(val) then
    val = reaper.NamedCommandLookup(val)
  end
  reaper.Main_OnCommand( val, 0 )
end

function GetFirstSelItem()
  local first_item
  local min_pos = math.huge
  for i = 0, count_sel_items - 1 do
    local item = reaper.GetSelectedMediaItem(0,i)
    local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    if item_pos < min_pos then
      min_pos = math.min( min_pos, item_pos )
      first_item = item
    end
  end
  return first_item
end

function Run()
  local cur_play = reaper.GetPlayPosition()
  local play_state = reaper.GetPlayState()
  local max = reaper.GetExtState(ext_name, "max")
  max = tonumber(max)
  if max and cur_play < max and play_state == 1 then
    reaper.defer(Run)
  else
    reaper.DeleteExtState(ext_name, "is_running", true)
    reaper.DeleteExtState(ext_name, "max", true)
    reaper.OnStopButton()
    Msg("EXIT")
  end
end

function Init()
  count_sel_items = reaper.CountSelectedMediaItems(0)
  if count_sel_items > 0 then
    local item = GetFirstSelItem()
    local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    local item_snap = reaper.GetMediaItemInfo_Value(item, "D_SNAPOFFSET")
    local item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    min = item_pos + item_snap
    max = item_pos + item_len
    reaper.SetExtState(ext_name, "max", tostring(max), false)
    reaper.SetEditCurPos( min, move_view, seek_play)
    Main_OnCommand( play_action )
    is_running = reaper.GetExtState(ext_name, "is_running")
    if is_running ~= "true" then
      reaper.SetExtState(ext_name, "is_running", "true", false)
      Run()
    else
      if not reaper.HasExtState(ext_name, "first_run") then
        console = true
        Msg("IMPORTANT: Click on New Instance + Always remember")
        reaper.SetExtState(ext_name, "first_run", "true", true)
      end
    end
  else
    reaper.DeleteExtState(ext_name, "is_running", true)
    reaper.DeleteExtState(ext_name, "max", true)
  end
end

function Msg( val )
  if console then
    reaper.ShowConsoleMsg( tostring(val) .. "\n" )
  end
end

if not preset_file_init then
  Msg("START")
  Init()
end
