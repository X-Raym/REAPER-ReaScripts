--[[
 * ReaScript Name: Insert MIDI note in selected items active take
 * Screenshot: http://i.giphy.com/xTcnSXojAqCRl0dD8Y.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2023-01-04)
  + Initial Release
--]]


-----------------------------------------------------------
-- USER CONFIG AREA --
-----------------------------------------------------------
console = true
popup = true -- User input dialog box

vars = vars or {}
vars.chan = 1
vars.pitch = 86
vars.vel = 100

input_title = "Insert MIDI Note"
undo_text = "Insert MIDI note in selected items active take"
-----------------------------------------------------------
                              -- END OF USER CONFIG AREA --
-----------------------------------------------------------

-----------------------------------------------------------
-- GLOBALS --
-----------------------------------------------------------

vars_order = {"chan", "pitch", "vel"}

instructions = instructions or {}
instructions.chan = "Channel? (1-16)"
instructions.pitch = "Pitch? (0-127)"
instructions.vel = "Velocity? (0-127)"

sep = "\n"
extrawidth = "extrawidth=0"
separator = "separator=" .. sep

ext_name = "XR_InsertMIDINote"

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
  else
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
  for i = 0, count_sel_items - 1 do
    local item = reaper.GetMediaItem( 0, i )
    local take = reaper.GetActiveTake( item )
    if take and reaper.TakeIsMIDI( take ) then
      local item_pos = reaper.GetMediaItemInfo_Value( item, "D_POSITION" )
      local item_len = reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )
      local item_end = item_pos + item_len
      local start_ppq = reaper.MIDI_GetPPQPosFromProjTime( take, item_pos )
      local end_ppq = reaper.MIDI_GetPPQPosFromProjTime( take, item_end )
      reaper.MIDI_InsertNote( take, false, false, start_ppq, end_ppq, vars.chan, vars.pitch, vars.vel, false )
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
    end
  end

  if not popup or ( retval and ValidateVals(vars, vars_order) ) then -- if user complete the fields

      reaper.PreventUIRefresh(1)

      reaper.Undo_BeginBlock()

      if not clear_console_init then reaper.ClearConsole() end

      if popup then SaveState() end

      Main() -- Execute your main function

      reaper.Undo_EndBlock(undo_text, -1)

      reaper.UpdateArrange()

      reaper.PreventUIRefresh(-1)

  end
end

if not preset_file_init then
  Init()
end

