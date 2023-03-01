--[[
 * ReaScript Name: Set visible only tracks with items under play or edit cursor
 * About: Default ignore muted items. Moded from mpl_Toggle show tracks if play cursor crossing any of their items.lua
 * Screenshot: https://i.imgur.com/JkkJmoB.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER Scripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: [request] Minimize tracks withou any item in current region
 * Forum Thread URI: https://forum.cockos.com/showthread.php?t=276666
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2023-03-01)
  + Initial Release
--]]

-- TODO: Parent and Sends support

for key in pairs(reaper) do _G[key]=reaper[key]  end 
----------------------------------
function HasCrossedItems(tr, curpos)
  for i_it = 1,  CountTrackMediaItems( tr ) do
    local it = GetTrackMediaItem( tr, i_it-1 )
    local it_pos = GetMediaItemInfo_Value( it, 'D_POSITION' )
    local it_len = GetMediaItemInfo_Value( it, 'D_LENGTH' )        
    if it_pos > curpos then break end
    local it_mute = GetMediaItemInfo_Value( it, 'B_MUTE' )
    if it_pos <= curpos and it_pos + it_len >= curpos and it_mute == 0 then return true end
  end
end
-------------------------------------------------------
function Exit() return end

function Main()  
  local curpos =  GetPlayPosition()
  for i_tr = 1, CountTracks(0) do
    local tr = GetTrack(0,i_tr-1) 
    
    if HasCrossedItems(tr, curpos) then
      SetMediaTrackInfo_Value( tr, 'B_SHOWINMIXER', 1 )
      SetMediaTrackInfo_Value( tr, 'B_SHOWINTCP',   1 )  
     else
      SetMediaTrackInfo_Value( tr, 'B_SHOWINMIXER', 0 )
      SetMediaTrackInfo_Value( tr, 'B_SHOWINTCP',   0 )
    end
  end
  
  TrackList_AdjustWindows( false )
  UpdateArrange()
  reaper.defer(Main)
end

function Init()
  Main()
  reaper.atexit(Exit)
end

if not preset_file_init then
  Init()
end
