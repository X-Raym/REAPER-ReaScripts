--[[
 * ReaScript Name: Move selected items to first track with same color
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
 * v1.0 (2021-04-21)
  + Initial Release
--]]


-- USER CONFIG AREA -----------------------------------------------------------

console = true -- true/false: display debug messages in the console

------------------------------------------------------- END OF USER CONFIG AREA

-- Save item selection
function SaveSelectedItems (table)
  for i = 0, reaper.CountSelectedMediaItems(0)-1 do
    table[i+1] = reaper.GetSelectedMediaItem(0, i)
  end
end

function SaveTrackPerColor(t)
  if not t then t = {} end
  local count_track = reaper.CountTracks(0)
  for i = 0, count_track - 1 do
    local track = reaper.GetTrack(0, i)
    local color = reaper.GetMediaTrackInfo_Value(track, "I_CUSTOMCOLOR")
    if not t[color] then t[color] = track end
  end
  return t
end
-- Display a message in the console for debugging
function Msg(value)
  if console then
    reaper.ShowConsoleMsg(tostring(value) .. "\n")
  end
end

--------------------------------------------------------- END OF UTILITIES


-- Main function
function Main()

  tracks = SaveTrackPerColor()

  for i, item in ipairs( init_sel_items ) do
    local color = reaper.GetDisplayedMediaItemColor( item )
    local track = reaper.GetMediaItemTrack(item)
    if tracks[color] and track ~= tracks[color] then
      reaper.MoveMediaItemToTrack(item, tracks[color])
    end
  end

end

-- INIT

-- See if there is items selected
count_sel_items = reaper.CountSelectedMediaItems(0)

if count_sel_items > 0 then

  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  init_sel_items =  {}
  SaveSelectedItems(init_sel_items)

  Main()

  reaper.Undo_EndBlock("Move selected items to first track with same color", -1) -- End of the undo block. Leave it at the bottom of your main function.

  reaper.UpdateArrange()

  reaper.PreventUIRefresh(-1)

end
