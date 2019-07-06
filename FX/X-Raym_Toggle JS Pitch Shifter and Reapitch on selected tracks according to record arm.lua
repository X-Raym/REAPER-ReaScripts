 --[[
 * ReaScript Name: TToggle JS Pitch Shifter and Reapitch on selected tracks according to record arm
 * Author: X-Raym
 * Author URI: http:--extremraym.com
 * Source: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Source URI: https:--github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * Forum Thread: EEL script: Toggle FX by suffix
 * Forum Thread URI: https://forum.cockos.com/showthread.php?t=154742
 * Version: 1.0
 * Version Date: 2019-07-06
 * Required: Reaper 4.60
]]


function ToggleTrackFX( tracki )
  trackifxcount = reaper.TrackFX_GetCount(tracki);          -- count number of FX instances on the track
  record_state =  reaper.GetMediaTrackInfo_Value( tracki, "I_RECARM" )

  for k = 0, trackifxcount - 1 do        

    retval, fx_name = reaper.TrackFX_GetFXName(tracki, k, '');          -- get the name of the FX instance

    if fx_name:find("Pitch Shifter") then
      if record_state == 0 then           
        reaper.TrackFX_SetEnabled(tracki, k, 0)    
      else                                                
        reaper.TrackFX_SetEnabled(tracki, k, 1)     
      end
    end
    if fx_name:find("(ReaPitch)") then
      if record_state >= 1 then           
        reaper.TrackFX_SetEnabled(tracki, k, 0)    
      else                                                
        reaper.TrackFX_SetEnabled(tracki, k, 1)    
      end
    end
  end
end

function ToggleFXbySuffix()

NumberTracks = reaper.CountSelectedTracks(0);

for i = 0, NumberTracks - 1 do                                        -- loop for all tracks
    
  tracki = reaper.GetSelectedTrack(0, i);                                   -- which track
  
  ToggleTrackFX( tracki );
end

mster_track = reaper.GetMasterTrack( 0 );
if reaper.IsTrackSelected(mster_track) then
  ToggleTrackFX(mster_track);
end


end

reaper.Undo_BeginBlock()
ToggleFXbySuffix() -- Run Run run !!!!
reaper.Undo_EndBlock("Toggle JS Pitch Shifter and Reapitch on selected tracks according to record arm", 0)
