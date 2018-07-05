--[[
 * ReaScript Name: Set selected tracks FX parameters values from last focused FX (real-time)
 * Description: A way to propagate FX param value from last touched FX to others on selected tracks on real-time. This version overcome spk77 scripts which works on last touch parameter, cause some GUI controllers modify several parameters at the same time but the last touch parameter as returned by ReaScript functions is only one value.
 * Screenshot: https://i.imgur.com/YtwrB9M.gifv
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-Scripts
 * Licence: GPL v3
 * Forum Thread: Scripts: FX Param Values (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=164796
 * REAPER: 5.0
 * Version: 1.0.1
--]]

--[[
 * Changelog:
 * v1.0.1 (2018-07-05)
  # Source FX has to be on selected tracks
 * v1.0 (2018-07-05)
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

local repaer = reaper

function main()

    -- IF SELECTED TRACK
  local count_sel_tracks = reaper.CountSelectedTracks(0)

  if count_sel_tracks > 0 then

    -- GET LAST TOUCHED FX
    local last_retval, last_track_id, last_fx_id, last_fx_param = reaper.GetLastTouchedFX()

    if last_retval and last_track_id >= 0 then

      local last_track = reaper.GetTrack(0, last_track_id - 1)

      if reaper.IsTrackSelected( last_track ) then

        local last_fx_name_retval, last_fx_name = reaper.TrackFX_GetFXName(last_track, last_fx_id, "")

        -- LOOP IN SELECTED TRACK
        for i = 0, count_sel_tracks - 1 do

          local track = reaper.GetSelectedTrack(0, i)

          -- TRACKS ARE DIFFERENT
          if track ~= last_track then

            -- FX LOOP
            local count_fx = reaper.TrackFX_GetCount(track)

            for j = 0, count_fx - 1 do

              local fx_name_retval, fx_name = reaper.TrackFX_GetFXName(track, j, "")

              -- NAMES MATCH
              if fx_name == last_fx_name then

                -- PARAMETERS LOOP
                local count_params = reaper.TrackFX_GetNumParams(track, j)

                for k = 0, count_params - 1 do

                  local param_retval, minval, maxval = reaper.TrackFX_GetParam(last_track, last_fx_id, k)
                  local param_retval_2, minval_2, maxval_2 = reaper.TrackFX_GetParam(track, j, k)

                  if param_retval ~= param_retval_2 then
                    reaper.TrackFX_SetParam(track, j, k, param_retval)
                  end

                end

                break -- First fx with same name

              end -- Names match

            end -- Loop in FX

          end -- Track is different than last fx track

        end -- Loop in selected tracks

      end -- If last touched FX track is selected

    end -- Get last touched Fx

  end -- Tracks are selected

  reaper.defer(main)

end

-- RUN
SetButtonON()
main()
reaper.atexit( SetButtonOFF )
