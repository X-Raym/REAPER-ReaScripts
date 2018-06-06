--[[
 * ReaScript Name: Rename selected track sends based on their source track name
 * Instructions: Select tracks. Run.
 * Description: Sponored by Dan Stanley
 * Screenshot: https://i.imgur.com/RXSUmi6.gifv
 * Author: X-Raym
 * Author URI: https://extremraym.com
 * Repository: GitHub > X-Raym > Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Track Properties (various)
 * Forum Thread URI: https://forum.cockos.com/showthread.php?t=166157
 * Extensions: SWS 2.9.6
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2018-06-06)
  + Initial Release
--]]
 
-- ------ USER CONFIG AREA =====>

sep = " - "

-- <===== USER CONFIG AREA ------

function main()
  
  for i = 0, tracks_count - 1 do
    local track = reaper.GetSelectedTrack(0, i)
    local track_name_retval, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", '', false)
    local num_send = reaper.GetTrackNumSends( track, 0 )
    for j = 0, num_send - 1 do
      local send_track = reaper.BR_GetMediaTrackSendInfo_Track( track, 0, j, 1 )
      local _, send_track_name = reaper.GetSetMediaTrackInfo_String(send_track, "P_NAME", track_name .. sep .. (j + 1), true)
    end
  end

end

-- INIT
tracks_count = reaper.CountSelectedTracks(0)

if tracks_count > 0 then
  
  reaper.PreventUIRefresh(1)
   
  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
 
  main()
   
  reaper.Undo_EndBlock("Rename selected track sends based on their source track name", -1) -- End of the undo block. Leave it at the bottom of your main function.
   
  reaper.PreventUIRefresh(-1)
  
end
