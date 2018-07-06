--[[
 * ReaScript Name: Propagate last focused FX parameters values but bypass to similarly named FX on child tracks (real-time)
 * Description: A way to propagate FX param value from last touched FX to others childs of its parent track in real-time. The propagate values algorithm overcome spk77 scripts which works on last touch parameter, cause some GUI controllers modify several parameters at the same time but the last touch parameter as returned by ReaScript functions is only one value.
 * Screenshot: 
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-Scripts
 * Licence: GPL v3
 * Forum Thread: Scripts: FX Param Values (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=164796
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2018-07-06)
  + Initial Release
--]]

 -- Set ToolBar Button ON
function SetButtonON()
  is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  state = reaper.GetToggleCommandStateEx( sec, cmd )
  reaper.SetToggleCommandState( sec, cmd, 1 ) -- Set ON
  reaper.RefreshToolbar2( sec, cmd )
end

-- Set ToolBar Button OFF
function SetButtonOFF()
  is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  state = reaper.GetToggleCommandStateEx( sec, cmd )
  reaper.SetToggleCommandState( sec, cmd, 0 ) -- Set OFF
  reaper.RefreshToolbar2( sec, cmd )
end

function GetChildTracks( track )
  local id = reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
  local depth =  reaper.GetTrackDepth( track )
  
  local tracks = {}
  local count_tracks = reaper.CountTracks()
  for i = id, count_tracks - 1 do
    local next_track = reaper.GetTrack( 0, i )
    local next_depth =  reaper.GetTrackDepth( next_track )
    if depth < next_depth then
     table.insert( tracks, next_track )
    else
      break
    end
  end
  return tracks
end

local repaer = reaper

function main()

  -- GET LAST TOUCHED FX
  local last_retval, last_track_id, last_fx_id, last_fx_param = reaper.GetLastTouchedFX()

  if last_retval and last_track_id >= 0 then

    local last_track = reaper.GetTrack(0, last_track_id - 1)
    
    local child_tracks = GetChildTracks( last_track )

    if #child_tracks > 0 then

      local last_fx_name_retval, last_fx_name = reaper.TrackFX_GetFXName(last_track, last_fx_id, "")

      -- LOOP IN SELECTED TRACK
      for i , track in ipairs( child_tracks) do

        -- FX LOOP
        local count_fx = reaper.TrackFX_GetCount(track)

        for j = 0, count_fx - 1 do

          local fx_name_retval, fx_name = reaper.TrackFX_GetFXName(track, j, "")

          -- NAMES MATCH
          if fx_name == last_fx_name then

            -- PARAMETERS LOOP
            local count_params = reaper.TrackFX_GetNumParams(track, j)

            for k = 0, count_params - 1 do
              
              if k ~= count_params - 2 then
                local param_retval, minval, maxval = reaper.TrackFX_GetParam(last_track, last_fx_id, k)
                local param_retval_2, minval_2, maxval_2 = reaper.TrackFX_GetParam(track, j, k)
  
                if param_retval ~= param_retval_2 then
                  reaper.TrackFX_SetParam(track, j, k, param_retval)
                end
              end

            end

            break -- First fx with same name

          end -- Names match

        end -- Loop in FX

      end -- Loop in selected tracks

    end -- If last touched FX track is selected

  end -- Get last touched Fx

  reaper.defer(main)

end

-- RUN
SetButtonON()
main()
reaper.atexit( SetButtonOFF )
