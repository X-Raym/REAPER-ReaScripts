--[[
 * ReaScript Name: Invert tracks (reverse vertically) of selected items
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * REAPER: 5.0
 * Version: 1.0
 --]]

--[[
 * Changelog:
 * v1.0 (2021-03-22)
  + Initial Release
--]]


-- USER CONFIG AREA -----------------------------------------------------------

console = true -- true/false: display debug messages in the console

undo_text = "Invert tracks (reverse vertically) of selected items"
------------------------------------------------------- END OF USER CONFIG AREA


-- UTILITIES -------------------------------------------------------------

-- Save item selection
function SaveSelectedItems(t)
  local t = t or {}
  for i = 0, reaper.CountSelectedMediaItems(0)-1 do
    t[i+1] = reaper.GetSelectedMediaItem(0, i)
  end
  return t
end

function RestoreSelectedItems( items )
  reaper.SelectAllMediaItems(0, false)
  for i, item in ipairs( items ) do
    reaper.SetMediaItemSelected( item, true )
  end
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

  tracks = {}
  for i, item in ipairs(init_sel_items) do
    track = reaper.GetMediaItemTrack( item )
    track_id = reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
    tracks[track_id] = track
  end

  tracks_order = {}
  for k, v in pairs( tracks ) do
    table.insert(tracks_order, k)
  end
  table.sort( tracks_order )

  tracks_dest = {}
  for i, track_id in ipairs( tracks_order ) do
    tracks_dest[track_id] = tracks[tracks_order[#tracks_order-i+1]]
  end

  for i, item in ipairs(init_sel_items) do
    track = reaper.GetMediaItemTrack( item )
    track_id = reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
    reaper.MoveMediaItemToTrack(item, tracks_dest[track_id])
  end

end


-- INIT
function Init()
  -- See if there is items selected
  count_sel_items = reaper.CountSelectedMediaItems(0)
  if count_sel_items == 0 then return false end

  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock()

  init_sel_items = SaveSelectedItems()

  Main()

  RestoreSelectedItems(init_sel_items)

  reaper.Undo_EndBlock(undo_text, -1)

  reaper.UpdateArrange()

  reaper.PreventUIRefresh(-1)

end

if not preset_file_init then
  Init()
end

