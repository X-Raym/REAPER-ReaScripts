--[[
 * ReaScript Name: Record or stop and rename newly created items with clipboard content
 * Author: X-Raym
 * Author URI: https://extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Transport (various)
 * Forum Thread URI: https://forums.cockos.com/showthread.php?t=189701
 * REAPER: 5.0
 * Version: 1.0.1
--]]

--[[
 * Changelog:
 * v1.0.1 (2018-09-27)
  # Pause fix
 * v1.0 (2018-09-26)
  + Initial Release
--]]

function Main()

  play_state = reaper.GetPlayState()
  
  if play_state == 5 and reaper.CF_GetClipboard then -- Need SWS
    
    reaper.Main_OnCommand( 1013,0 ) -- Transport: Record
  
    clipboard = reaper.CF_GetClipboard('')
    
    if clipboard ~= "" then
      for i = 0, reaper.CountSelectedMediaItems(0) - 1 do
        local take = reaper.GetActiveTake( reaper.GetSelectedMediaItem(0, i) )
        if take then
          reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", clipboard, true)
        end
      end
    end
    reaper.Main_OnCommand( 40073, 0 ) -- Transport: Play/pause
    reaper.Main_OnCommand( 1016, 0 ) -- Transport: Stop
  else
    reaper.Main_OnCommand( 1013,0 ) -- Transport: Record
  end
  
end

reaper.defer(Main)
