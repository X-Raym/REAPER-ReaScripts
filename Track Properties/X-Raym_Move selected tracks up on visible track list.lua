--[[
 * ReaScript Name: Move selected tracks up on visible track list
 * Description: See title.
 * Instructions: Select tracks. Run.
 * Screenshot: http://i.imgur.com/GfN9y50.gif
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > REAPER Scripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * File URI: 
 * Licence: GPL v3
 * Forum Thread: http://forum.cockos.com/showthread.php?p=1704698&posted=1#post1704698
 * Forum Thread URI: Script to move track up or down
 * REAPER: 5.0
 * Extensions: SWS/S&M 2.8.7
 * Version: 2.0.1
--]]
 
--[[
 * Changelog:
 * v2.0.1 (2018-03-04)
  # No console output
 * v2.0 (2018-07-21)
  # ReorderSelectedTracks API: faster performance
 * v1.0 (2015-07-10)
  + Initial Release
 --]]

-- DEBUG FUNCTIONS
function Msg(variable)
  if console then
    reaper.ShowConsoleMsg(tostring(variable).."\n")
  end
end

function Is_Valid_Track(track)
  valid_track = reaper.ValidatePtr(track, "MediaTrack*")
  return valid_track
end

function ReverseTable(t)
  local reversedTable = {}
  local itemCount = #t
  for k, v in ipairs(t) do
      reversedTable[itemCount + 1 - k] = v
  end
  return reversedTable
end

function SaveSelectedTracks(table)
  for i = 0, reaper.CountSelectedTracks(0)-1 do
    table[i+1] = reaper.GetSelectedTrack(0, i)
  end
end

function Open_URL(url)
  if not OS then local OS = reaper.GetOS() end
  if OS=="OSX32" or OS=="OSX64" then
    os.execute("open ".. url)
   else
    os.execute("start ".. url)
  end
end

function CheckSWS()
  local SWS_installed
  if not reaper.BR_SetMediaTrackLayouts then
    local retval = reaper.ShowMessageBox("SWS extension is required by this script.\nHowever, it doesn't seem to be present for this REAPER installation.\n\nDo you want to download it now ?", "Warning", 1)
    if retval == 1 then
      Open_URL("http://www.sws-extension.org/download/pre-release/")
    end
  else
    SWS_installed = true
  end
  return SWS_installed
end

function Main()
  
  new_tracks = {}
  
  sel_tracks = ReverseTable( sel_tracks )
  
  for i, track in ipairs( sel_tracks ) do
  
    reaper.SetOnlyTrackSelected( track )
    
    reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_COPYSNDRCV1"),0) -- copy track with routing
    
    reaper.Main_OnCommand(reaper.NamedCommandLookup("_XENAKIOS_SELNEXTTRACK"),0) -- Select Next Track
    local track_copy = reaper.GetSelectedTrack(0, 0)
    
    if track_copy == track then
       table.insert( new_tracks, track ) 
      break
    end
    reaper.Main_OnCommand(40914, 0) -- set as last touch
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
  
  return new_tracks
  
end

function IsThereAnUnselectedTrackBefore( id )
  local out = false
  for i = 0, id - 1 do
    local track = reaper.GetTrack(0, i)
    if not reaper.IsTrackSelected( track ) then
      Msg(i)
      out = true
      break
    end
  end
  return out
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
    
    count_tracks = reaper.CountTracks(0)
    
    for i = 1, #sel_tracks do
      local track = sel_tracks[i]
      id = reaper.GetMediaTrackInfo_Value( track, "IP_TRACKNUMBER" )
      if IsThereAnUnselectedTrackBefore( id ) then
        reaper.SetOnlyTrackSelected( track )
        reaper.ReorderSelectedTracks(id-2, 0)
      end
    end
    
    for i, track in ipairs( sel_tracks ) do
      reaper.SetTrackSelected( track, true )
    end
    
    reaper.TrackList_AdjustWindows(0)
    reaper.UpdateArrange()
    
    reaper.Undo_EndBlock("Move selected tracks up on visible track list", -1)
    
    reaper.PreventUIRefresh(-1)
  
  elseif CheckSWS() then

  reaper.PreventUIRefresh(1)
  
  reaper.Undo_BeginBlock()
  
  reaper.ClearConsole() -- Clean the console
  
  -- Avoid complex selection with Child and their Parents
  reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_UNSELPARENTS"),0) -- Unselect parent track
  
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
  
  reaper.Undo_EndBlock("Move selected tracks up on visible track list", -1)
  
  reaper.PreventUIRefresh(-1)

end

end