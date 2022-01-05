--[[
 * ReaScript Name: Insert sysex events at time selection
 * Screenshot: https://i.imgur.com/dnAKtCX.gif
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
 * v1.0 (2020-07-11)
  + Initial Release
--]]

-- USER CONFIG AREA ---------------------

prompt = true -- User input dialog box
selected = false -- new notes are selected

vars = {
  type_start = 1,
  type_end = 1,
  bytestr_start = "STR START",
  bytestr_end = "STR END"
}

----------------- END OF USER CONFIG AREA

vars_order = {"type_start", "type_end", "bytestr_start", "bytestr_end"}
ext_name = "XR_InsertSysexTimeSel"

function SaveState()
  for k, v in pairs( vars ) do
    SaveExtState( k, v )
  end
end

function SaveExtState( var, val)
  reaper.SetExtState( ext_name, var, tostring(val), true )
end

function GetExtState( var, val )
  if reaper.HasExtState( ext_name, var ) then
    local t = type( val )
    val = reaper.GetExtState( ext_name, var )
    if t == "boolean" then val = toboolean( val )
    elseif t == "number" then val = tonumber( val )
    else
    end
  end
  return val
end


-- Console Message
function Msg(g)
  reaper.ShowConsoleMsg(tostring(g).."\n")
end


function main()

  start_pos, end_pos = reaper.GetSet_LoopTimeRange2( 0, false, false, 0, 0, false )

  take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive())

  if take and start_pos ~= end_pos then

    iPosOut = reaper.MIDI_GetPPQPosFromProjTime(take, start_pos)
    end_time = reaper.MIDI_GetPPQPosFromProjTime(take, end_pos)

    retval = reaper.MIDI_InsertTextSysexEvt( take, true, false, iPosOut, vars.type_start, vars.bytestr_start )
    retval = reaper.MIDI_InsertTextSysexEvt( take, true, false, end_time, vars.type_end, vars.bytestr_end )

    reaper.MIDI_Sort(take)

  end -- ENFIF Take is MIDI

end

if prompt then
  for k, v in pairs( vars ) do
    vars[k] = GetExtState( k, vars[k] )
  end

  vals = {}
  for i, v in ipairs( vars_order ) do
    vals[i] = vars[v]
  end
  vals = table.concat(vals, ",")

  instructions = {
    "Type Start",
    "Type End",
    "STR Start",
    "STR End"
  }
  retval, user_input_str = reaper.GetUserInputs("Insert SYSEX", #instructions, table.concat(instructions, ","), vals )
  if retval then
        vars = {}
        vars.type_start, vars.type_end, vars.bytestr_start, vars.bytestr_end = user_input_str:match("([^,]+),([^,]+),([^,]+),([^,]+)")
  end
end

if not prompt or ( retval and vars.type_start ) then -- if user complete the fields

    reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

    main() -- Execute your main function

    if prompt then
      SaveState()
    end

    reaper.Undo_EndBlock("Insert sysex events at time selection", -1) -- End of the undo block. Leave it at the bottom of your main function.

    reaper.UpdateArrange() -- Update the arrangement (often needed)

end
