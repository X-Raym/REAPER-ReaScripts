--[[
 * ReaScript Name: Set or offset selected tracks volume pan and width value
 * Author: X-Raym
 * Author URI: https://extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2021-05-29)
  + Initial Release
--]]

-----------------------------------------------------------
-- USER CONFIG AREA --
-----------------------------------------------------------
console = true
popup = true -- User input dialog box
reset = true

vars = vars or {}
vars.volume = "+0"
vars.pan = "+0"
vars.width = "+0"

input_title = "Tracks Values Input"
undo_text = "Set or offset selected tracks volume pan and width value"

mod = "relative"
mod_prefix = "+" -- Prefix to enter the secondary mod
mod_prefix_multiply = "*" -- Prefix to enter the secondary mod multiply
-----------------------------------------------------------
                              -- END OF USER CONFIG AREA --
-----------------------------------------------------------

-----------------------------------------------------------
-- GLOBALS --
-----------------------------------------------------------

vars_order = {"volume", "pan", "width"}

instructions = instructions or {}
instructions.volume = "Volume? (" .. mod_prefix .." for " .. mod .. ", * and /)"
instructions.pan = "Pan? (" .. mod_prefix .." for " .. mod .. ", * and /)"
instructions.width = "Width? (" .. mod_prefix .." for " .. mod .. ", * and /)"

sep = "\n"
--extrawidth = "extrawidth=120"
extrawidth = ""
separator = "separator=" .. sep

ext_name = "XR_SetOrOffsetTracksVol"

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
-- PROCESS --
-----------------------------------------------------------
function ProcessInputMath( str )
  local x, y = string.find(str, mod_prefix)

  local multiply = string.find(str, "%*")
  local divide = string.find(str, "/")

  local set = "set"
  if multiply then set = "multiply" end
  if divide then set = "divide" end
  if x then set = "offset" end

  local user_input_num = str:gsub(mod_prefix, "")
  user_input_num = user_input_num:gsub("%*", "")
  user_input_num = user_input_num:gsub("/", "")
  user_input_num = tonumber(user_input_num)
  return user_input_num, set
end

function LimitNumber( val, min, max )
  return math.min(math.max(min, val), max)
end

function dBFromVal(val) return 20*math.log(val, 10) end
function ValFromdB(dB_val) return 10^(dB_val/20) end

multipliers = { pan = 100, width = 100}

function ProcessMath(val_a, val_b, set, name)
  local val = val_b / ( multipliers[name] or 1 )-- absolute
  if set == "multiply" then
    val = val_a * val_b
  elseif set == "divide" then
    val = val_a / val_b
  elseif set == "offset" then
    val = val_a + val_b / ( multipliers[name] or 1 )
  end
  return val
end
-----------------------------------------------------------
-- MAIN --
-----------------------------------------------------------
function Main()
  vol_input, vol_set = ProcessInputMath( vars.volume )
  pan_input, pan_set = ProcessInputMath( vars.pan )
  width_input, width_set = ProcessInputMath( vars.width )

  if not vol_input and not pan_input and not width_input then return false end

  for i = 0, count_sel_tracks - 1 do
    local track = reaper.GetSelectedTrack(0, i)
    local vol = dBFromVal( reaper.GetMediaTrackInfo_Value(track, "D_VOL") )
    local pan = reaper.GetMediaTrackInfo_Value(track, "D_PAN")
    local width = reaper.GetMediaTrackInfo_Value(track, "D_WIDTH")

    if vol_input then vol = ProcessMath(vol, vol_input, vol_set, "vol") end
    if pan_input then pan = ProcessMath(pan, pan_input, pan_set, "pan") end
    if width_input then width = ProcessMath(width, width_input, width_set, "width") end

    reaper.SetMediaTrackInfo_Value(track, "D_VOL", ValFromdB( LimitNumber(vol, -150, 12) ) )
    reaper.SetMediaTrackInfo_Value(track, "D_PAN", LimitNumber(pan, -1, 1) )
    reaper.SetMediaTrackInfo_Value(track, "D_WIDTH", LimitNumber(width, -1, 1 ) )
  end
end

-----------------------------------------------------------
-- INIT --
-----------------------------------------------------------
function Init()

  count_sel_tracks = reaper.CountSelectedTracks(0)
  if count_sel_tracks == 0 then return false end

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
