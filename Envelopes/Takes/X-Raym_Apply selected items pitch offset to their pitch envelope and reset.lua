--[[
 * ReaScript Name: Apply selected items pitch offset to their pitch envelope and reset
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2020-02-09)
  + Initial Release
--]]

function Main()

  reaper.Undo_BeginBlock()

  reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_TAKEENVSHOW7"),0) -- SWS/S&M: Show take pitch envelope

  for i = 0, count_sel_items - 1 do

    item = reaper.GetSelectedMediaItem( 0, i )

    take = reaper.GetActiveTake( item )

    if take then

      take_pitch = reaper.GetMediaItemTakeInfo_Value( take, "D_PITCH" )

      if take_pitch ~= 0 then

        env = reaper.GetTakeEnvelopeByName(take, "Pitch")

        if env then
          count_points = reaper.CountEnvelopePoints(env)
          for j = 0, count_points - 1 do
            retval, time, value, shape, tension, selected = reaper.GetEnvelopePoint( env, j )
            reaper.SetEnvelopePoint( env, j, time, value + take_pitch, shape, tension, selected, false )
          end

        end

        reaper.SetMediaItemTakeInfo_Value( take, "D_PITCH", 0 )

      end

    end


  end

  reaper.Undo_EndBlock("Apply selected items pitch offset to their pitch envelope and reset", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

count_sel_items = reaper.CountSelectedMediaItems(0)
if count_sel_items > 0 then
  reaper.PreventUIRefresh(1)

  Main() -- Execute your main function

  reaper.UpdateArrange() -- Update the arrangement (often needed)

  reaper.PreventUIRefresh(-1)
end
