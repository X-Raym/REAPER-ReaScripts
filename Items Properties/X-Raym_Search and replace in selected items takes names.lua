--[[
 * ReaScript Name: Search and replace in selected items takes names
 * Screenshot: http://i.giphy.com/3oEdv3tKb0CpB7VCtq.gif
 * Author: X-Raym
 * Author URI: https://extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Properties (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1574814#post1574814
 * REAPER: 5.0
 * Version: 2.0
--]]

--[[
 * Changelog:
 * v2.0 (2022-10-08)
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
vars.ins_start_in = "" -- "/E" for item number in selection, "/T" for track name
vars.ins_end_in = "" -- "/E" for item number in selection, "/T" for track name
vars.select_renamed = "y" -- y/n to select item which have been actually renamed

input_title = "Search & Replace in Items Takes Names"
undo_text = "SSearch and replace in selected items takes names"

-----------------------------------------------------------
                              -- END OF USER CONFIG AREA --
-----------------------------------------------------------

-----------------------------------------------------------
-- GLOBALS --
-----------------------------------------------------------

vars_order = {"search", "replace", "use_lua_pattern", "truncate_start", "truncate_end", "ins_start_in", "ins_end_in", "select_renamed"}

instructions = instructions or {}
instructions.search = "Search?"
instructions.replace = "Replace?"
instructions.use_lua_pattern = "Use Lua Pattern? (y/n)"
instructions.truncate_start = "Truncate from start? (>0)"
instructions.truncate_end = "Truncate from end? (>0)"
instructions.ins_start_in = "Insert at start? (/E=Sel Num,/t...)"
instructions.ins_end_in = "Insert at end? (.../T=Track)"
instructions.select_renamed = "Select renamed items only? (y/n)"

sep = "\n"
extrawidth = "extrawidth=120"
separator = "separator=" .. sep

ext_name = "XR_SearchReplaceTakeNames"

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

  select_renamed_items = {}

  -- INITIALIZE
  for i = 0, sel_items_count-1  do

    local item = reaper.GetSelectedMediaItem(0, i)
    local item_count_take = reaper.CountTakes( item )
    for z = 0, item_count_take - 1 do
      
      local take = reaper.GetTake( item, z )

      -- GET NAMES
      local take_name = reaper.GetTakeName(take)
      local original_take_name = take_name

      local track = reaper.GetMediaItem_Track(item)
      local retval, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)

      -- MODIFY NAMES
      take_name = take_name:gsub(search, vars.replace)

      if vars.truncate_start > 0 then take_name = take_name:sub(vars.truncate_start+1) end
      if vars.truncate_end > 0 then
        take_name_len = take_name:len()
        take_name = take_name:sub(0, take_name_len-vars.truncate_end)
      end

      local ins_start = vars.ins_start_in:gsub("/E", tostring(i + 1))
      local ins_end = vars.ins_end_in:gsub("/E", tostring(i + 1))
      ins_start = ins_start:gsub("/T", track_name)
      ins_end = ins_end:gsub("/T", track_name)
      ins_start = ins_start:gsub("/t", z+1)
      ins_end = ins_end:gsub("/t", z+1)

      take_name = ins_start..take_name..ins_end

      if select_renamed == "y" and original_take_name ~= take_name then
        table.insert(select_renamed_items, item)
      end

      -- SETNAMES
      reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", take_name, true)

    end

  end

  if select_renamed == "y" then
    reaper.SelectAllMediaItems(0, false)
    for i, item in ipairs(select_renamed_items) do
      reaper.SetMediaItemSelected( item, true )
    end
  end

end

-----------------------------------------------------------
-- INIT --
-----------------------------------------------------------
function Init()

  sel_items_count = reaper.CountSelectedMediaItems(0)
  if sel_items_count == 0 then return false end

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
