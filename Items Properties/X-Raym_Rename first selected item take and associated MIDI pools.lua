--[[
 * ReaScript Name: Rename first selected item take and associated MIDI pools
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
 * v1.0 (2022-03-08)
  + Initial Release
--]]

function Msg( val )
  if console then
    reaper.ShowConsoleMsg(tostring(val) .. "\n")
  end
end

function Main()

  name = reaper.GetTakeName( sel_take )

  count_items = reaper.CountMediaItems( 0 )
  z = 0
  for i = 0, count_items - 1 do
    local item = reaper.GetMediaItem(0,i)
    local take = reaper.GetActiveTake( item )
    if take and reaper.TakeIsMIDI( take ) then
      retval, pool_guid = reaper.BR_GetMidiTakePoolGUID( take )
      if retval and pool_guid == sel_pool_guid then
        z = z + 1
        reaper.GetSetMediaItemTakeInfo_String( take, "P_NAME", name ..  " " .. z, true)
      end
    end
  end

end

-- RUN

sel_item = reaper.GetSelectedMediaItem(0,0)
if not sel_item then return end

sel_take = reaper.GetActiveTake( sel_item )
if not sel_take or not reaper.TakeIsMIDI( sel_take ) then return end

retval, sel_pool_guid = reaper.BR_GetMidiTakePoolGUID( sel_take )
if not retval then return end

reaper.PreventUIRefresh(1)

reaper.Undo_BeginBlock()

Main()

reaper.Undo_BeginBlock("Rename first selected item take and associated MIDI pools")

reaper.UpdateArrange()

reaper.PreventUIRefresh(-1)
