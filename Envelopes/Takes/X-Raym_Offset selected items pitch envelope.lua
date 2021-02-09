--[[
 * ReaScript Name: Offset selected items pitch envelope
 * Screenshot: https://i.imgur.com/C7AqMt5.gif
 * Author: X-Raym
 * Author URI: https://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2021-02-09)
  + Initial Release
--]]

-- USER CONFIG AREA ---------------------
console = true
popup = true -- User input dialog box

vars = {
  offset = 0,
}

----------------- END OF USER CONFIG AREA

vars_order = {"offset"}
ext_name = "XR_OffsetTakePitchEnvelope"
input_title = "Offset Take Pitch Envelope"

separator = "\n"

instructions = {
  "Offset? (num)",
  --"extrawidth=120",
  "separator=" .. separator,
}

undo_text = "Offset selected items pitch envelope"

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

function Main()

  for i = 0, count_sel_items - 1 do
    item = reaper.GetSelectedMediaItem( 0, i )

    take = reaper.GetActiveTake( item )

    if take then
        
      env = reaper.GetTakeEnvelopeByName(take, "Pitch")
      
      if env then
        count_points = reaper.CountEnvelopePoints(env)
        for j = 0, count_points - 1 do
          retval, time, value, shape, tension, selected = reaper.GetEnvelopePoint( env, j )
          reaper.SetEnvelopePoint( env, j, time, value + vars.offset, shape, tension, selected, false )
        end
      
      end

    end
  
    
  end
end

function Init()
  if popup then

    GetValsFromExtState()
    
    retval, retvals_csv = reaper.GetUserInputs(input_title, #vars_order, table.concat(instructions, "\n"), ConcatenateVarsVals() ) 
    if retval then
      vars = ParseRetvalCSV( retvals_csv )
      if vars.offset then
        vars.offset = vars.offset:gsub("+", "")
        vars.offset=tonumber( vars.offset )
      end
    end
  end

  if not popup or ( retval and ValidateVals(vars) ) then -- if user complete the fields

      reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
      
      count_sel_items = reaper.CountSelectedMediaItems(0)

      if vars.offset ~= 0 and count_sel_items > 0 then

        Main() -- Execute your main function

      end
      
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
