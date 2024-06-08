--[[
 * ReaScript Name: Insert empty space at edit cursor (popup)
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0.1
--]]

--[[
 * Changelog:
 * v1.0.1 (2024-06-08)
  # Fix sample duration calculation
 * v1.0 (2021-02-12)
  + Initial Release
--]]

-- USER CONFIG AREA ---------------------
console = true
popup = true -- User input dialog box

vars = {
  value = 1,
  unit = "s",
}

----------------- END OF USER CONFIG AREA

vars_order = {"value", "unit"}
ext_name = "XR_InsertEmptySpacePopup"
input_title = "Insert Empty Space"

separator = "\n"

instructions = {
  "Value? (num > 0)",
  "Unit (s/ms/samples/grid/frames)",
  -- "extrawidth=120",
  "separator=" .. separator,
}

undo_text = "Insert empty space at edit cursor"

function ConvertValToSeconds(val, unit)
  -- Val to number
  local val = tonumber(val)
  if not val then return end
  -- Convert unit length to seconds
  if unit == "grid" or unit == "g" then
    grid, division, swingmode, swingamt = reaper.GetSetProjectGrid( 0, false )
    bpm = reaper.Master_GetTempo()
    unit_length = 60 / bpm * division * 4
  elseif unit == "samples" or unit == "smpl" then
    unit_length = reaper.parse_timestr_len("1", 0, 4)
  elseif unit == "ms" then
    unit_length = 1 / 1000
  elseif unit == "frames" or unit == "f" then
    frameRate, dropFrameOut = reaper.TimeMap_curFrameRate(0)
    unit_length = 1 / frameRate -- Frame duration
  else
    unit_length = 1
  end
  return val * unit_length
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

function Main()
  value = ConvertValToSeconds(vars.value, vars.unit)
  time_start, time_end = reaper.GetSet_LoopTimeRange( false, false, 0, 0, false )

  cur_pos = reaper.GetCursorPosition()

  reaper.GetSet_LoopTimeRange( true, false, cur_pos, cur_pos + value, false )

  reaper.Main_OnCommand(40200,0) -- Time selection: Insert empty space at time selection (moving later items)

  reaper.GetSet_LoopTimeRange( true, false, time_start, time_end, false )
end

function Init()
  if popup then

    GetValsFromExtState()

    retval, retvals_csv = reaper.GetUserInputs(input_title, #vars_order, table.concat(instructions, "\n"), ConcatenateVarsVals() )
    if retval then
      vars = ParseRetvalCSV( retvals_csv )
      if vars.value then
        vars.value = tonumber( vars.value )
      end
    end
  end

  if not popup or ( retval and ValidateVals(vars) ) then -- if user complete the fields

      reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

      Main() -- Execute your main function

      if popup then
        SaveState()
      end

      reaper.Undo_EndBlock(undo_text, -1) -- End of the undo block. Leave it at the bottom of your main function.

      reaper.UpdateArrange() -- Update the arrangement (often needed)

  end
end

if not preset_file_init then
  Init()
end

