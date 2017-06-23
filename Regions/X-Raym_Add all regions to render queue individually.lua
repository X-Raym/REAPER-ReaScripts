--[[
 * ReaScript Name: Add all regions to render queue individually
 * Description: See title.
 * Instructions: Set render to region matrix (you need to select one track to close the window). Run the action.
 * Author: X-Raym
 * Author URI: http://www.extremraym.com/
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * Links:
     Script Request: Render Region Matrix (stopping in between regions) http://forum.cockos.com/showthread.php?t=193188
     Screenshot http://i.imgur.com/nKc09wL.gif
 * REAPER: 5.0
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2017-06-23)
  + Initial Release
--]]

-- GET MASTER TRACK
master_track = reaper.GetMasterTrack( 0 )

-- TRACKS
count_tracks = reaper.CountTracks( 0 )

-- CLEARN RENDER MATRIX
i=0
repeat
  iRetval, bIsrgn, iPos, iRgnend, sName, iIndex, iColor = reaper.EnumProjectMarkers3(0,i)
  if iRetval >= 1 then
    if bIsrgn == true then
    
      reaper.SetRegionRenderMatrix( 0, iIndex, master_track, -1 )
      
      for j = 0 , count_tracks - 1 do
        
        track = reaper.GetTrack( 0, j )
        reaper.SetRegionRenderMatrix( 0, iIndex, track, -1 )
      
      end
      
    end
    i = i+1
  end
until iRetval == 0

-- LOOP THROUGH REGIONS
i=0
repeat
  iRetval, bIsrgn, iPos, iRgnend, sName, iIndex, iColor = reaper.EnumProjectMarkers3(0,i)
  if iRetval >= 1 then
    if bIsrgn == true then
    
      reaper.SetRegionRenderMatrix( 0, iIndex, master_track, 1 )
      reaper.Main_OnCommand( 41823, 0 ) -- Add to render queue with last settings
      reaper.SetRegionRenderMatrix( 0, iIndex, master_track, -1 )
            
    end
    i = i+1
  end
until iRetval == 0