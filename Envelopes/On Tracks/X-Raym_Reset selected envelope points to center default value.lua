--[[
 * ReaScript Name: Reset selected envelope points to center default value
 * About: A way to reset envelope points value across tracks.
 * Instructions: Select tracks with visible and armed envelopes. Execute the script.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Script (LUA): Copy points envelopes in time selection and paste them at edit cursor
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1497832#post1497832
 * REAPER: 5.0 pre 18b
 * Extensions: SWS 2.6.3 #0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2021-07-26)
  + Initial release
--]]

function SetAtTimeSelection(env, k, point_time, value, shape, tension)

  if time_selection == true then

    if point_time > start_time and point_time < end_time then
      reaper.SetEnvelopePoint(env, k, point_time, value, shape, tension, true, true)
    end

  else
    reaper.SetEnvelopePoint(env, k, point_time, value, shape, tension, false, true)
  end

end

function Action(env)

  br_env = reaper.BR_EnvAlloc(env, false)
  active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, type, faderScaling = reaper.BR_EnvGetProperties(br_env, true, true, true, true, 0, 0, 0, 0, 0, 0, true)

  -- IF ENVELOPE IS A CANDIDATE
  if visible == true and armed == true then

    -- LOOP THROUGH POINTS
    env_points_count = reaper.CountEnvelopePoints(env)

    if env_points_count > 0 then
      for k = 0, env_points_count-1 do
        retval, point_time, valueOut, shapeOutOptional, tensionOutOptional, selectedOutOptional = reaper.GetEnvelopePoint(env, k)
        SetAtTimeSelection(env, k, point_time, centerValue, shapeInOptional, tensionInOptional)
      end
    end

    reaper.BR_EnvFree(br_env, 0)
    reaper.Envelope_SortPoints(env)

  end

end

function main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  -- GET CURSOR POS
  offset = reaper.GetCursorPosition()

  start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)

  if start_time ~= end_time then
    time_selection = true
  end

  -- LOOP TRHOUGH SELECTED TRACKS
  env = reaper.GetSelectedEnvelope(0)

  if env == nil then

    selected_tracks_count = reaper.CountSelectedTracks(0)
    for i = 0, selected_tracks_count-1  do

      -- GET THE TRACK
      track = reaper.GetSelectedTrack(0, i) -- Get selected track i

      -- LOOP THROUGH ENVELOPES
      env_count = reaper.CountTrackEnvelopes(track)
      for j = 0, env_count-1 do

        -- GET THE ENVELOPE
        env = reaper.GetTrackEnvelope(track, j)

        Action(env)

      end -- ENDLOOP through envelopes

    end -- ENDLOOP through selected tracks

  else

    Action(env)

  end -- endif sel envelope

  reaper.Undo_EndBlock("Reset selected envelope points to center default value", -1) -- End of the undo block. Leave it at the bottom of your main function.

end -- end main()

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

reaper.TrackList_AdjustWindows(false)

reaper.PreventUIRefresh(-1)  -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)

