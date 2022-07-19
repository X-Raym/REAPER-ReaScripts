--[[
 * ReaScript Name: Unselect envelope point at edit cursor
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
 * v1.0 (2022-07-19)
  + Initial Release
--]]

-- USER CONFIG AREA ---------------------
console = false
minimum_distance = 0.000001

undo_text = "Unselect envelope point at edit cursor"
----------------- END OF USER CONFIG AREA

-- Console Message
function Msg(g)
  if console then
    reaper.ShowConsoleMsg(tostring(g).."\n")
  end
end

function Main()

  edit_cur_pos = reaper.GetCursorPosition()
  Msg(edit_cur_pos)
  Msg("-------")

  env_take, index, index2 = reaper.Envelope_GetParentTake( env )
  if env_take then
    item = reaper.GetMediaItemTake_Item( env_take )
    take_rate = reaper.GetMediaItemTakeInfo_Value(env_take, "D_PLAYRATE")
    item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
  end
  -- env_track, index, index2 = reaper.Envelope_GetParentTrack( env )

  count_points = reaper.CountEnvelopePoints(env)
  for i = 0, count_points - 1 do

    local retval, time, value, shape, tension, selected = reaper.GetEnvelopePoint( env, i )
    
    local absolute_time = time
    if env_take then absolute_time = item_pos + time * 1 / take_rate end
    Msg( math.abs(absolute_time - edit_cur_pos) )
    if math.abs(absolute_time - edit_cur_pos) <= minimum_distance then
      reaper.SetEnvelopePoint( env, i, time, value, shape, tension, false, false )
    end
    if absolute_time > edit_cur_pos + minimum_distance then
      break
    end

  end

  reaper.Envelope_SortPoints(env)

end


env = reaper.GetSelectedEnvelope(0)
if not env then return false end

function Init()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
  
  reaper.ClearConsole()

  Main()

  reaper.Undo_EndBlock(undo_text, -1) -- End of the undo block. Leave it at the bottom of your main function.

  reaper.UpdateArrange() -- Update the arrangement (often needed)

end

if not preset_file_init then
  Init()
end
