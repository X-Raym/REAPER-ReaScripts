--[[
 * ReaScript Name: Set selected tracks FX parameter value from last focused FX last touch parameter
 * About: A way to propagate FX param value from last touched FX to others on selected tracks
 * Instructions: Touch an FX param. Run.
 * Screenshot: http://i.giphy.com/3oEdv7plpUl2dmlOcU.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: FX Param Values (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=164796
 * REAPER: 5.0 RC 14b
 * Version: 1.0.1
--]]

--[[
 * Changelog:
 * v1.0 (2015-08-11)
  + Initial Release
--]]

function Main()

  reaper.Undo_BeginBlock()

  -- IF SELECTED TRACK
  count_sel_tracks = reaper.CountSelectedTracks(0)

  if count_sel_tracks > 0 then

    -- GET LAST TOUCHED FX
    last_retval, last_track_id, last_fx_id, last_fx_param = reaper.GetLastTouchedFX()

    if last_retval and last_track_id >= 0 then

      last_track = reaper.GetTrack(0, last_track_id - 1)

      last_fx_name_retval, last_fx_name = reaper.TrackFX_GetFXName(last_track, last_fx_id, "")

      -- LOOP IN SELECTED TRACK
      for i = 0, count_sel_tracks - 1 do

        track = reaper.GetSelectedTrack(0, i)

        -- TRACKS ARE DIFFERENT
        if track ~= last_track then

          -- FX LOOP
          count_fx = reaper.TrackFX_GetCount(track)

          for j = 0, count_fx - 1 do

            fx_name_retval, fx_name = reaper.TrackFX_GetFXName(track, j, "")

            -- NAMES MATCH
            if fx_name == last_fx_name then

              param_retval, minval, maxval = reaper.TrackFX_GetParam(last_track, last_fx_id, last_fx_param)

              reaper.TrackFX_SetParam(track, last_fx_id, last_fx_param, param_retval)

            end -- Names match

          end -- Loop in FX

        end -- Track is different than last fx track

      end -- Loop in selected tracks

    end -- Get last touched Fx

  end -- Tracks are selected

  reaper.Undo_EndBlock("Set selected tracks FX parameter value from last focused FX last touch parameter", -1)

end -- function

reaper.PreventUIRefresh(1)

Main()

reaper.PreventUIRefresh(-1)