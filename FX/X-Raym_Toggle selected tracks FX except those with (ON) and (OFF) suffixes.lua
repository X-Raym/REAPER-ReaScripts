 --[[
 * ReaScript Name: Toggle selected tracks FX except those with (ON) and (OFF) suffixes
 * Author: X-Raym
 * Author URI: http:--extremraym.com
 * Source: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Source URI: https:--github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * Forum Thread: EEL script: Toggle FX by suffix
 * Forum Thread URI: https:--forum.cockos.com/showthread.php?t=154742
 * Version: 1.1
 * Version Date: 2019-05-07
 * Required: Reaper 4.60
]]

-- Heavily based on the great Toggle FX by suffix by HeDa
-- http:--forum.cockos.com/showthread.php?p=1472339

function ToggleTrackFX( tracki )
	trackifxcount = reaper.TrackFX_GetCount(tracki);          -- count number of FX instances on the track

	for k = 0, trackifxcount - 1 do                                        -- loop for all FX instances on each track
		retval, fx_name = reaper.TrackFX_GetFXName(tracki, k, '');          -- get the name of the FX instance

		if not (fx_name:find(" %(ON%)") or fx_name:find(" %(OFF%)") ) then                  -- if the name doesn't have the suffix...
			if reaper.TrackFX_GetEnabled(tracki, k) then           -- FX is enabled.
				reaper.TrackFX_SetEnabled(tracki, k, 0);      -- set FX to bypass 
		    else                                                  -- if not... 
				reaper.TrackFX_SetEnabled(tracki, k, 1);      --set FX to enabled 
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
reaper.Undo_EndBlock("Toggle FX by suffix", 0)
