--[[
 * ReaScript Name: Search and replace in selected tracks names
 * About: Select tracks. Run.
 * Screenshot: http://i.giphy.com/3o85xuFcHQ27K06TdK.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Tracks Names (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=167300
 * REAPER: 5.0
 * Version: 2.0
--]]

--[[
 * Changelog:
 * v2.0 (2022-10-06)
  + New core
  + Escape pattern field
  + Save last input
  # Updated preset system
 * v1.1 (2022-03-24)
  + Minimal preset file support
 * v1.0 (2015-10-08)
  + Initial Release
--]]

-----------------------------------------------------------
-- USER CONFIG AREA --
-----------------------------------------------------------

-- Preset file: https://gist.github.com/X-Raym/f7f6328b82fe37e5ecbb3b81aff0b744#file-preset-lua

console = true
popup = true -- User input dialog box

vars = vars or {}
vars.search = ""
vars.replace = ""
vars.use_lua_pattern = "n"
vars.truncate_start = 0
vars.truncate_end = 0
vars.ins_start_in = ""
vars.ins_end_in = ""

input_title = "Search & Replace in Track Names"
undo_text = "Search and replace in selected tracks names"
-----------------------------------------------------------
                              -- END OF USER CONFIG AREA --
-----------------------------------------------------------

-----------------------------------------------------------
-- GLOBALS --
-----------------------------------------------------------

vars_order = {"search", "replace", "use_lua_pattern", "truncate_start", "truncate_end", "ins_start_in", "ins_end_in"}

instructions = instructions or {}
instructions.search = "Search?"
instructions.replace = "Replace?"
instructions.use_lua_pattern = "Use Lua Pattern? (y/n)"
instructions.truncate_start = "Truncate from start? (>0)"
instructions.truncate_end = "Truncate from end? (>0)"
instructions.ins_start_in = "Insert at start? (/E for Sel Num)"
instructions.ins_end_in = "Insert at end?"

sep = "\n"
extrawidth = "extrawidth=120"
separator = "separator=" .. sep

ext_name = "XR_SearchReplaceTrackNames"

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
-- https://stackoverflow.com/questions/29072601/lua-string-gsub-with-a-hyphen
function EscapePatternStr(str)
    return string.gsub(str, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1") -- escape pattern
end

function Main()

  search = (vars.use_lua_pattern == "y" and vars.search) or EscapePatternStr(  vars.search )

  -- INITIALIZE
  for i = 0, sel_tracks_count-1  do

    local track = reaper.GetSelectedTrack(0, i)

    -- GET NAME
    local retval, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)

    -- MODIFY NAME
    local track_name = track_name:gsub(search, vars.replace)

    if vars.truncate_start > 0 then track_name = track_name:sub(vars.truncate_start+1) end
    if vars.truncate_end > 0 then
      track_name_len = track_name:len()
      track_name = track_name:sub(0, track_name_len-vars.truncate_end)
    end
    ins_start = vars.ins_start_in:gsub("/E", tostring(i + 1))
    ins_end = vars.ins_end_in:gsub("/E", tostring(i + 1))

    -- SET NAMES
    reaper.GetSetMediaTrackInfo_String(track, "P_NAME", ins_start..track_name..ins_end, true)

  end

end

-----------------------------------------------------------
-- INIT --
-----------------------------------------------------------
function Init()

  sel_tracks_count = reaper.CountSelectedTracks(0)
  if sel_tracks_count == 0 then return false end

  if popup then

    if not preset_file_init and not reset then
      GetValsFromExtState()
    end

    retval, retvals_csv = reaper.GetUserInputs(input_title, #vars_order, ConcatenateVarsVals(instructions, sep, vars_order) .. sep .. extrawidth .. sep .. separator, ConcatenateVarsVals(vars, sep, vars_order) )
    if retval then
      vars = ParseRetvalCSV( retvals_csv, sep, vars_order )
      if vars.ins_start_in == "/no" then vars.ins_start_in = "" end
      if vars.ins_end_in == "/no" then vars.ins_end_in = "" end
      vars.truncate_start = tonumber(vars.truncate_start) or vars.truncate_start:len()
      vars.truncate_start = math.max( 0, vars.truncate_start )
      vars.truncate_end = tonumber(vars.truncate_end) or vars.truncate_end:len()
      vars.truncate_end = math.max( 0, vars.truncate_end )
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
