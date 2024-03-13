--[[
 * ReaScript Name: Set selected tracks as reference tracks
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
 * v1.0 (2024-03-13)
  + Initial release
--]]

undo_text = "Set selected tracks as reference tracks"

function Tooltip(message) -- DisplayTooltip() already taken by the GUI version
  local x, y = reaper.GetMousePosition()
  reaper.TrackCtl_SetToolTip( tostring(message), x+17, y+17, false )
end

function Main()
  local names = {}
  for i = 0, count_all_tracks - 1 do
    local track = reaper.GetTrack(0, i)
    local state = ""
    if reaper.IsTrackSelected( track ) then
      state = "REF"
      local retval, name = reaper.GetTrackName(track)
      table.insert( names, i+1 .. ". " .. name )
    end
    local retval, str = reaper.GetSetMediaTrackInfo_String( track, "P_EXT:XR_REF", state, true )
  end
  
  count_sel_tracks = reaper.CountSelectedTracks( 0 )
  if count_sel_tracks == 0 then
    Tooltip("Reference tracks unset")
  else
    Tooltip("Reference tracks:\n" .. table.concat( names, "\n") )
  end
end

function Init()
  count_all_tracks = reaper.CountTracks( 0 )
  if count_all_tracks == 0 then return end
  
  reaper.PreventUIRefresh( 1 )
  
  reaper.Undo_BeginBlock()
  
  Main()
  
  reaper.TrackList_AdjustWindows( false )
  
  reaper.Undo_EndBlock( undo_text, 0 )
  
  reaper.PreventUIRefresh( - 1 )
end

if not preset_file_init then
  Init()
end

