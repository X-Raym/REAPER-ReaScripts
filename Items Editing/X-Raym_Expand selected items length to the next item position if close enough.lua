--[[
 * ReaScript Name: Expand selected items length to the next item position if close enough
 * About: Expand selected items to the next item position
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Editing (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=163363
 * REAPER: 5.0
 * Version: 2.0
--]]

--[[
 * Changelog:
 * v2.0 (2023-05-10)
  # New core
  + Save last input
  + deactivable popup
  + preset script support
 * v1.0 (2015-08-23)
  + Initial Release
--]]

-- TODO: ITEMS INSIDE OTHERS

-----------------------------------------------------------
-- USER CONFIG AREA --
-----------------------------------------------------------

-- Use Preset Script for safe moding or to create a new action with your own values
-- https://github.com/X-Raym/REAPER-ReaScripts/tree/master/Templates/Script%20Preset

console = true
popup = true -- User input dialog box

vars = vars or {}
vars.gap = 1

input_title = "Expand items right"
undo_text = "Expand selected items length to the next item position if close enough"
-----------------------------------------------------------
                              -- END OF USER CONFIG AREA --
-----------------------------------------------------------

-----------------------------------------------------------
-- GLOBALS --
-----------------------------------------------------------

vars_order = {"gap"}

instructions = instructions or {}
instructions.gap = "Consecutivity Threshold? (s)"

sep = "\n"
extrawidth = "extrawidth=0"
separator = "separator=" .. sep

ext_name = "XR_ExpandItemsRightIfClose"

-----------------------------------------------------------
-- DEBUGGING --
-----------------------------------------------------------
function Msg(g)
  if console then
    reaper.ShowConsoleMsg(tostring(g).."\n")
  end
end

-----------------------------------------------------------
-- STATES --
-----------------------------------------------------------
function SaveState()
  for k, v in pairs( vars ) do
    reaper.SetExtState( ext_name, k, tostring(v), true )
  end
end

function GetExtState( var, val )
  local t = type( val )
  if reaper.HasExtState( ext_name, var ) then
    val = reaper.GetExtState( ext_name, var )
  end
  if t == "boolean" then val = toboolean( val )
  elseif t == "number" then val = tonumber( val )
  end
  return val
end

function GetValsFromExtState()
  for k, v in pairs( vars ) do
    vars[k] = GetExtState( k, vars[k] )
  end
end

function ConcatenateVarsVals(t, sep, vars_order)
  local vals = {}
  for i, v in ipairs( vars_order ) do
    vals[i] = t[v]
  end
  return table.concat(vals, sep)
end

function ParseRetvalCSV( retvals_csv, sep, vars_order )
  local t = {}
  local i = 0
  for line in retvals_csv:gmatch("[^" .. sep .. "]*") do
    i = i + 1
    t[vars_order[i]] = line
  end
  return t
end

function ValidateVals( vars, vars_order )
  local validate = true
  for i, v in ipairs( vars_order ) do
    if vars[v] == nil then
      validate = false
      break
    end
  end
  return validate
end

-----------------------------------------------------------
-- MAIN --
-----------------------------------------------------------
function Main()

  for i=0, count_sel_items - 1 do

    local item = reaper.GetSelectedMediaItem(0, i)
    local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION") -- Get the value of a the parameter
    local item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    local item_end = item_pos + item_len

    local item_track = reaper.GetMediaItemTrack(item)
    local item_id = reaper.GetMediaItemInfo_Value(item, "IP_ITEMNUMBER")

    local next_item = reaper.GetTrackMediaItem(item_track, item_id+1)

    if next_item then

      local next_item_pos = reaper.GetMediaItemInfo_Value(next_item, "D_POSITION")
      local distance = next_item_pos - item_end

      if distance < vars.gap then

        local item_len_input = next_item_pos - item_pos -- Prepare value output
        reaper.SetMediaItemInfo_Value(item, "D_LENGTH", item_len_input) -- Set the value to the parameter

      end

    end

  end

end

-----------------------------------------------------------
-- INIT --
-----------------------------------------------------------
function Init()

  count_sel_items = reaper.CountSelectedMediaItems(0)
  if count_sel_items == 0 then return false end

  if popup then

    if not preset_file_init and not reset then
      GetValsFromExtState()
    end

    retval, retvals_csv = reaper.GetUserInputs(input_title, #vars_order, ConcatenateVarsVals(instructions, sep, vars_order) .. sep .. extrawidth .. sep .. separator, ConcatenateVarsVals(vars, sep, vars_order) )
    if retval then
      vars = ParseRetvalCSV( retvals_csv, sep, vars_order )
      -- CUSTOM SANITIZATION HERE
      vars.gap = tonumber( vars.gap )
    end
  end

  if not popup or ( retval and ValidateVals(vars, vars_order) ) then Run() end -- if user complete the fields

end

function Run()
  -- RUN
  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock()

  if not no_clear_console_init then reaper.ClearConsole() end

  if popup then SaveState() end

  Main() -- Execute your main function

  reaper.Undo_EndBlock(undo_text, -1)

  reaper.UpdateArrange()

  reaper.PreventUIRefresh(-1)
end

if not preset_file_init then
  Init()
end
