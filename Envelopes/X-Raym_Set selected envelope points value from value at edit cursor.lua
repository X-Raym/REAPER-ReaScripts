--[[
 * ReaScript Name: Set selected envelope points value from value at edit cursor
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: ReaScript: Set/Offset selected envelope points values
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1487882#post1487882
 * Version: 1.0
]]

--[[
 * Changelog:
 * v1.0 (2021-05-30)
  + Initial Release
]]

function Msg(g)
  if console then
    reaper.ShowConsoleMsg(tostring(g).."\n")
  end
end

function Main()

  time = reaper.GetCursorPosition()
  retval, edit_val  = reaper.Envelope_Evaluate(env, time, 0, 0)

  local retval, env_name = reaper.GetEnvelopeName(env, "")
  local env_point_count = reaper.CountEnvelopePoints(env)

  for i = 0, env_point_count - 1 do
    local retval, time, val, shape, tension, selected = reaper.GetEnvelopePoint(env,i)
    if selected then

      --if env_name == "Tempo map" then
                -- SET POINT VALUE
        --local retval, timepos, measurepos, beatpos, bpm, timesig_num, timesig_denom, lineartempo = reaper.GetTempoTimeSigMarker( 0, i )
        --reaper.SetTempoTimeSigMarker( 0, i, timepos, measurepos, beatpos, val, timesig_num, timesig_denom, lineartempo )
      --else
        reaper.SetEnvelopePoint(env, i, time, edit_val, shape, tension, true, false)
      --end

    end -- ENDIF point is selected
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
    end
  end

end -- END OF FUNCTION

function Init()
  reaper.PreventUIRefresh(1)
  env = reaper.GetSelectedEnvelope(0)
  if env then
    reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
    reaper.ClearConsole()
    Main() -- Execute your main function
    reaper.UpdateArrange() -- Update the arrangement (often needed)
    reaper.Undo_EndBlock("Set selected envelope points value from value at edit cursor", -1) -- End of the undo block. Leave it at the bottom of your main function.
  end
  reaper.PreventUIRefresh(-1)
end

if not preset_init_file then
  Init()
end
