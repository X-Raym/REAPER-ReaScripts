--[[
 * ReaScript Name: Duplicate lines in clipboard content
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
 * v1.0 (2021-03-06)
  + Initial Release
--]]

-- USER CONFIG AREA ---------------------
console = true
popup = true -- User input dialog box

sep = "\n" -- default sep
filter_empty_lines = false

vars = vars or {}
vars.duplicate = 1

input_title = "Duplicate line"
undo_text = "Duplicate lines in clipboard content"
----------------- END OF USER CONFIG AREA

vars_order = {"duplicate"}
ext_name = "XR_DuplicateClipboardLines"

separator = "\n"

instructions = {
  "Duplicate lines X times: (X>1)",
  -- "extrawidth=120",
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

-- https://helloacm.com/split-a-string-in-lua/
function split(s, delimiter, preserve)
  local result = {}
  local i = 0
  for match in (s..delimiter):gmatch("(.-)"..delimiter) do
    if preserve and i > 0 then
      table.insert(result, delimiter .. match)
    else
      table.insert(result, match)
    end
    i = i + 1
  end
  return result
end

function Main()
  clipboard = reaper.CF_GetClipboard('')

  lines = split(clipboard,sep)

  if filter_empty_lines then
    lines_filtered= {}
    for i, v in ipairs( names ) do
      if v ~= "\r" and v ~= "" then table.insert( lines_filtered, v ) end
    end
    lines = names_filtered
  end

  -- Duplicate
  new_lines = {}
  for i, line in ipairs( lines ) do
    for j = 1, vars.duplicate do
      table.insert(new_lines, line)
    end
  end

  -- Concat
  new_clipboard = table.concat(new_lines, "\n")
  reaper.CF_SetClipboard(new_clipboard)
  Msg(new_clipboard)

end

function Init()
  if popup then

    GetValsFromExtState()

    retval, retvals_csv = reaper.GetUserInputs(input_title, #vars_order, table.concat(instructions, "\n"), ConcatenateVarsVals() )
    if retval then
      vars = ParseRetvalCSV( retvals_csv )
      -- CUSTOM SANITIZATION HERE
      if vars.duplicate then
        vars.duplicate = tonumber( vars.duplicate )
        if vars.duplicate then
          vars.duplicate = math.max(1, math.floor(vars.duplicate))
        end
      end
    end
  end

  if not popup or ( retval and ValidateVals(vars) ) then -- if user complete the fields

      reaper.PreventUIRefresh(1)

      reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

      reaper.ClearConsole()

      if popup then
        SaveState()
      end

      Main() -- Execute your main function

      reaper.Undo_EndBlock(undo_text, -1) -- End of the undo block. Leave it at the bottom of your main function.

      reaper.UpdateArrange() -- Update the arrangement (often needed)

      reaper.PreventUIRefresh(-1)

  end
end

if not preset_file_init then
  Init()
end
