--[[
 * ReaScript Name: Play selected items once from first snap offset position
 * About: Just like the SWS action Xenakios/SWS: Play selected item, but without lag.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

play_action = 1007 -- Transport: Play
move_view = true
seek_play = false
console = false

-- Set ToolBar Button State
function SetButtonState( set )
  local is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  reaper.SetToggleCommandState( sec, cmd, set or 0 )
  reaper.RefreshToolbar2( sec, cmd )
end

function Exit()
  SetButtonState( set )
  reaper.OnStopButton()
end

function Main_OnCommand( val )
  if not tonumber(val) then
    val = reaper.NamedCommandLookup(val)
  end
  reaper.Main_OnCommand( val, 0 )
end

function GetItemsEdges()
  local max, min = 0, math.huge
  for i = 0, count_sel_items - 1 do
    local item = reaper.GetSelectedMediaItem(0,i)
    local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    local item_snap = reaper.GetMediaItemInfo_Value(item, "D_SNAPOFFSET")
    local item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    min = math.min( min, item_pos + item_snap)
    max = math.max( max, item_pos + item_len )
  end
  return min, max
end

function Run()
  cur_play = reaper.GetPlayPosition()
  local play_state = reaper.GetPlayState()
  if max and cur_play < max and (play_state == 1 or play_state == 5 ) then
    reaper.defer(Run)
  end
end

function Init()
  reaper.set_action_options(2)
  count_sel_items = reaper.CountSelectedMediaItems(0)
  if count_sel_items > 0 then
    min, max = GetItemsEdges()
    reaper.SetEditCurPos( min, move_view, seek_play)
    Main_OnCommand( play_action )
  end
  Run()
  reaper.atexit( Exit )
end

function Msg( val )
  if console then
    reaper.ShowConsoleMsg( tostring(val) .. "\n" )
  end
end

if not preset_file_init then
  Init()
end
