--[[
 * ReaScript Name: Move selected tracks up to the top of the visible track list
 * Description: See title.
 * Instructions: Select tracks. Run.
 * Screenshot: http://i.imgur.com/SPfJoQp.gif
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > REAPER Scripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * File URI:
 * Licence: GPL v3
 * Forum Thread: http://forum.cockos.com/showthread.php?t=179122
 * Forum Thread URI: how to move selected track/s to the top
 * REAPER: 5.0
 * Extensions: SWS/S&M 2.8.7
 * Version: 2.0
--]]
 
--[[
 * Changelog:
 * v2.0 (2018-07-21)
  # ReorderSelectedTracks API: faster performance
 * v1.0 (2015-07-16)
  + Initial Release
 --]]

-- DEBUG FUNCTIONS
function Msg(variable)
  reaper.ShowConsoleMsg(tostring(variable).."\n")
end

function Is_Valid_Track(track)
  valid_track = reaper.ValidatePtr(track, "MediaTrack*")
  return valid_track
end

function SaveSelectedTracks(table)
  for i = 0, reaper.CountSelectedTracks(0)-1 do
    table[i+1] = reaper.GetSelectedTrack(0, i)
  end
end

function ReverseTable(t)
  local reversedTable = {}
  local itemCount = #t
  for k, v in ipairs(t) do
      reversedTable[itemCount + 1 - k] = v
  end
  return reversedTable
end

function Main()

  new_tracks = {}

  sel_tracks = ReverseTable( sel_tracks )

  reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_CREATETRK1"),0)-- insert track at top

  local track_top = reaper.GetSelectedTrack(0, 0)

  for i, track in ipairs( sel_tracks ) do

    reaper.SetOnlyTrackSelected( track )

    reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_COPYSNDRCV1"),0) -- copy track with routing

    reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_SELMASTER"),0) -- Select Master

    reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_PASTSNDRCV1"),0) -- paste track with routing

    local track_copy = reaper.GetSelectedTrack(0, 0)

    -- ADD SENDS ENVELOPE
    for category = -1, 1 do
      local sends_count = reaper.GetTrackNumSends( track, category )
      for sendidx = 0, sends_count -1 do
        for envelopeType = 0, 2 do
          local env = reaper.BR_GetMediaTrackSendInfo_Envelope( track, category, sendidx, envelopeType )
          local retval, xml = reaper.GetEnvelopeStateChunk( env, "", false )
          local env_copy = reaper.BR_GetMediaTrackSendInfo_Envelope( track_copy, category, sendidx, envelopeType )
          reaper.SetEnvelopeStateChunk( env_copy, xml, false )
        end
      end
    end

    reaper.DeleteTrack( track ) -- Delete Source Track

    table.insert( new_tracks, track_copy )

  end

  reaper.DeleteTrack( track_top ) -- Delete Top Track

end

-- INIT
local reaper = reaper

count_selected_track = reaper.CountSelectedTracks( 0 )

if count_selected_track > 0 then

  if reaper.APIExists( 'ReorderSelectedTracks' ) then
  
  reaper.PreventUIRefresh(1)
     reaper.Undo_BeginBlock()
     
     -- Save Tracks
     sel_tracks = {}
     SaveSelectedTracks( sel_tracks )

     reaper.ReorderSelectedTracks(0, 0)
     
     reaper.TrackList_AdjustWindows(0)
     reaper.UpdateArrange()
     
     reaper.Undo_EndBlock("Move selected tracks up to the top of the visible track list", -1)
     
     reaper.PreventUIRefresh(-1)
   
   elseif CheckSWS() then

  reaper.PreventUIRefresh(1)
  -- Avoid complex selection with Child and their Parents
  reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_UNSELPARENTS"),0) -- Unselect parent track
  reaper.Undo_BeginBlock()

  reaper.ClearConsole() -- Clean the console

  -- Save Tracks
  sel_tracks = {}
  SaveSelectedTracks( sel_tracks )

  Main()

  -- Select New Tracks
  if new_tracks then
    for i, track in ipairs( new_tracks ) do
      reaper.SetTrackSelected( track, true )
    end
  end

  -- Select Source Tracks if they still exist
  for i, track in ipairs( sel_tracks ) do
    if Is_Valid_Track( track ) then
      reaper.SetTrackSelected( track, true )
    end
  end
  reaper.TrackList_AdjustWindows(0)
  reaper.UpdateArrange()

  reaper.Undo_EndBlock("Move selected tracks up to the top of the visible track list", -1)

  reaper.PreventUIRefresh(-1)

end

end
