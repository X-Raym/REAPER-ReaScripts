--[[
 * ReaScript Name: Split selected items every X seconds intervals
 * Screenshot: https://cloud.extremraym.com/sharex/reascripts/OMsDvrG.mp4
 * Author: X-Raym
 * Author URI: http://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Lua Script: Split Media Into Into X Equal Parts
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1609741#post1609741
 * REAPER: 5.0
 * Version: 2.0
--]]

--[[
 * Changelog:
 * v2.0 (2024-06-08)
  # New core
  # Bug fix (last section could be longer than X)
 * v1.0 (2015-12-19)
  + Initial Release
--]]

-- USER CONFIG AREA ---------------------
console = true
popup = true -- User input dialog box

vars = vars or {}
vars.val = 1

input_title = "Split items"
undo_text = "Split selected items every X seconds intervals"
----------------- END OF USER CONFIG AREA

vars_order = {"val"}
ext_name = "XR_SplitItemsXSeconds"

separator = "\n"

instructions = {
  "Value (s)? (x>0)",
  "separator=" .. separator,
}

-- Console Message
function Msg(g)
  if console then
    reaper.ShowConsoleMsg(tostring(g).."\n")
  end
end

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
  else
  end
  return val
end

function GetValsFromExtState()
  for k, v in pairs( vars ) do
    vars[k] = GetExtState( k, vars[k] )
  end
end

function ConcatenateVarsVals()
  local vals = {}
  for i, v in ipairs( vars_order ) do
    vals[i] = vars[v]
  end
  return table.concat(vals, "\n")
end

function ParseRetvalCSV( retvals_csv )
  local t = {}
  local i = 0
  for line in retvals_csv:gmatch("[^" .. separator .. "]*") do
  i = i + 1
  t[vars_order[i]] = line
  end
  return t
end

function ValidateVals( vars )
  local validate = true
  for i, v in ipairs( vars_order ) do
    if vars[v] == nil then
      validate = false
      break
    end
  end
  return validate
end

-- Save item selection
function SaveSelectedItems (table)
  for i = 0, reaper.CountSelectedMediaItems(0)-1 do
    table[i+1] = reaper.GetSelectedMediaItem(0, i)
  end
end

function RestoreSelectedItems (table)
  reaper.SelectAllMediaItems( 0, false ) -- Unselect all items
  for _, item in ipairs(table) do
    reaper.SetMediaItemSelected(item, true)
  end
end

function Main()
  for i, item in ipairs( init_sel_items) do
    table.insert( new_sel_items , item )
    local i = 1
    repeat
      local item_pos = reaper.GetMediaItemInfo_Value( item, "D_POSITION" )
      item = reaper.SplitMediaItem(item, item_pos + i * vars.val)
      table.insert( new_sel_items , item )
    until item == nil
  end
end

function Init()
  count_sel_items = reaper.CountSelectedMediaItems(0,0)
  if count_sel_items == 0 then return false end

  if popup then

    if not preset_file_init and not reset then
      GetValsFromExtState()
    end

    retval, retvals_csv = reaper.GetUserInputs(input_title, #vars_order, table.concat(instructions, "\n"), ConcatenateVarsVals() )
    if retval then
      vars = ParseRetvalCSV( retvals_csv )
      vars.val = tonumber(vars.val)
      if vars.val and vars.val < 0 then return false end
    end
  end

  if not popup or ( retval and ValidateVals(vars) ) then -- if user complete the fields

      reaper.PreventUIRefresh(1)

      reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

      reaper.ClearConsole()

      if popup then
        SaveState()
      end

      init_sel_items = {}
      SaveSelectedItems(init_sel_items)

      new_sel_items = {}

      Main() -- Execute your main function

      RestoreSelectedItems( new_sel_items )

      reaper.Undo_EndBlock(undo_text, -1) -- End of the undo block. Leave it at the bottom of your main function.

      reaper.UpdateArrange() -- Update the arrangement (often needed)

      reaper.PreventUIRefresh(-1)

  end
end

if not preset_file_init then
  Init()
end
