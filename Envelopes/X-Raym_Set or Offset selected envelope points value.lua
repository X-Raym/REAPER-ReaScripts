--[[
 * ReaScript Name: Set or Offset selected envelope point value in selected envelope
 * About: A pop up to let you put offset vals for selected item points. Write vals you want. Use "+" sign for relative val (the val is added to the original), no sign for absolute Exemple: -6 is absolute, or +-6 is relative. Don't use percentage. Example: writte "60" for 60%. You can customize default behavior (relative or absolute mod and prefix character) in the User Area of this script.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: ReaScript: Set/Offset selected envelope points values
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1487882#post1487882
 * Version: 2.0.3
]]

--[[
 * Changelog:
 * v2.0.3 (2022-08-09)
  # Playrate envelope unit
 * v2.0.2 (2021-03-30)
  # Fix fader scaling
  # Keep point selected
 * v2.0.1 (2021-03-23)
  # Trim envelope support. Thx @daniboyle!
  + -inf, min, max keywords
  + comma decimal support
 * v2.0 (2021-03-23)
  + new core
  + Automation items support
  + Save/restore last input
  + preset file support
 * v1.8.1 (2020-01-07)
  # No debug
 * v1.8 (2020-01-07)
  + Tempo marker support
 * v1.7 (2016-07-18)
  + User config setting for deactivating the pop up
 * v1.6 (2015-09-09)
  + Fader-scaling support
 * v1.5 (2015-07-15)
  + User customization area
  # "Cancel" bug fix
 * v1.4 (2015-07-11)
  + Send support
 * v1.3 (2015-06-25)
  # Dual pan track support
 * v1.2 (2015-06-02)
  # No envelope selected bug fix (thanks Soli Deo Gloria for the report)
 * v1.1 (2015-05-07)
  # Time selection bug fix
 * v1.0 (2015-03-08)
  + Initial Release
]]

-- ------ USER AREA =====>
mod1 = "absolute" -- Set the primary mod that will be defined if no prefix character. Values are "absolute" or "relative".
mod2_prefix = "+" -- Prefix to enter the secondary mod
input = "" -- "" means no character aka relative per default.
popup = true -- true/false
console = true
-- <===== USER AREA ------

other_mod = {
  absolute = "offset",
  relative = "set"
}

ext_name = "XR_SetOffsetSelPointValue"

local env_width_db_scale = {}
env_width_db_scale["Volume"] = true
env_width_db_scale["Volume (Pre-FX)"] = true
env_width_db_scale["Send Volume"] = true
env_width_db_scale["Trim Volume"] = true

local env_no_mulitply = {}
env_no_mulitply["Mute"] = true
env_no_mulitply["Send Mute"] = true
env_no_mulitply["Pitch"] = true
env_no_mulitply["Tempo map"] = true

local env_multiply = {}
env_multiply["Width"] = -1
env_multiply["Width (Pre-FX)"] = -1
env_multiply["Pan"] = -1
env_multiply["Pan (Pre-FX)"] = -1
env_multiply["Pan (Left)"] = -1
env_multiply["Pan (Right)"] = -1
env_multiply["Pan (Left, Pre-FX)"] = -1
env_multiply["Pan (Right, Pre-FX)"] = -1
env_multiply["Send Pan"] = -1
env_multiply["Playrate"] = 100 -- TODO: work with playrate env

function Msg(g)
  if console then
    reaper.ShowConsoleMsg(tostring(g).."\n")
  end
end

function dBFromVal(val) return 20*math.log(val, 10) end
function ValFromdB(dB_val) return 10^(dB_val/20) end

function LimitNumber( val, min, max )
  return math.min(math.max(min, val), max)
end

function ProcessPoint( env, env_name, val, user_input_num, set, min, max )
  -- Pre Process val
  local fader_scaling = reaper.GetEnvelopeScalingMode(env)
  if env_width_db_scale[env_name] then
    if fader_scaling == 1 then val = reaper.ScaleFromEnvelopeMode(1, val) end
    val = dBFromVal( val )
  end

  -- Human Format
  local user_val = user_input_num * (env_multiply[env_name] or 1)

  if set then val = 0 end

  if env_no_mulitply[env_name] or env_width_db_scale[env_name] then
    val = val + user_val
  else
    val = val + user_val/100
  end

  -- post Process val
  if env_width_db_scale[env_name] then
    val = ValFromdB( val )
    val = LimitNumber( val, min, max )
    if fader_scaling == 1 then val = reaper.ScaleToEnvelopeMode(1, val) end
  else
    val = LimitNumber( val, min, max )
  end

  return val
end

function ProcessEnv(env, set, user_input_num)

  local retval, env_name = reaper.GetEnvelopeName(env, "")
  local env_point_count = reaper.CountEnvelopePoints(env)

  br_env = reaper.BR_EnvAlloc( env, false )
  local active, visible, armed, inLane, laneHeight, defaultShape, min, max, centerValue, type_point, faderScaling, automationItemsOptions = reaper.BR_EnvGetProperties( br_env )
  reaper.BR_EnvFree( br_env, false )

  for i = 0, env_point_count - 1 do
    local retval, time, val, shape, tension, selected = reaper.GetEnvelopePoint(env,i)
    if selected then

      val = ProcessPoint( env, env_name, val, user_input_num, set, min, max )

      if env_name == "Tempo map" then
                -- SET POINT VALUE
        local retval, timepos, measurepos, beatpos, bpm, timesig_num, timesig_denom, lineartempo = reaper.GetTempoTimeSigMarker( 0, i )
        reaper.SetTempoTimeSigMarker( 0, i, timepos, measurepos, beatpos, val, timesig_num, timesig_denom, lineartempo )
      else
        reaper.SetEnvelopePoint(env, i, time, val, shape, tension, true, false)
      end

    end -- ENDIF point is selected
    --reaper.Envelope_SortPoints(env)
  end -- END Loop

  local count_ai = reaper.CountAutomationItems( env )
  for i = 0, count_ai - 1 do
    local count_ai_points = reaper.CountEnvelopePointsEx( env, i )
    for j = 0, count_ai_points - 1 do
      local retval, time, val, shape, tension, selected = reaper.GetEnvelopePointEx( env, i, j )
      if selected then
        val = ProcessPoint( env, env_name, val, user_input_num, set, min, max )
        reaper.SetEnvelopePointEx( env, i, j, time, val, shape, tension, true, false )
      end
      --reaper.Envelope_SortPointsEx(env, i )
    end
  end

end -- END Process function

function Main()

  if popup then
    if not preset_file_init then
      input = reaper.GetExtState( ext_name, "input", input, true )
    end
    retval, input = reaper.GetUserInputs("Set or Offset Selected Points Values", 1, "Value? (num, " .. mod2_prefix .." " .. other_mod[mod1] .. ", min, max)", input)
  end

  if retval or not popup then

    if not preset_file_init then
      reaper.SetExtState( ext_name, "input", input, true )
    end

    input = input:gsub(',','.')

    local x, y = string.find(input, mod2_prefix)

    if mod1 == "absolute" then
      set = (x == nil) or false
    end

    if mod1 == "relative" then
      set = (x ~= nil) or false
    end

    input = input:gsub(mod2_prefix, "")
    if input == "-inf" or input == "min" then input = - math.huge end
    if input == "max" then input = math.huge end
    user_input_num = tonumber(input)

    -- IF VALID INPUT
    if user_input_num then
      ProcessEnv(env, set, user_input_num)
    end

  end -- if ot retval or poup
end -- END OF FUNCTION

function Init()
  env = reaper.GetSelectedEnvelope(0)
  if env then
    reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
    reaper.ClearConsole()
    Main() -- Execute your main function
    reaper.UpdateArrange() -- Update the arrangement (often needed)
    reaper.Undo_EndBlock("Set or Offset selected envelope point value", -1) -- End of the undo block. Leave it at the bottom of your main function.
  end
end

if not preset_init_file then
  Init()
end
