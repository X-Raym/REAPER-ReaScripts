--[[
 * ReaScript Name: Add points on envelopes at markers
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Extensions: SWS 2.8.1
 * Version: 1.1.1
--]]

--[[
 * Changelog:
 * v1.0 (2021-05-19)
  + Initial release
--]]

function AddPoints(env)
    -- GET THE ENVELOPE
  br_env = reaper.BR_EnvAlloc(env, false)

  active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, type, faderScaling = reaper.BR_EnvGetProperties(br_env, true, true, true, true, 0, 0, 0, 0, 0, 0, true)

  if visible == true and armed == true then

    env_points_count = reaper.CountEnvelopePoints(env)

    if env_points_count > 0 then
      for k = 0, env_points_count+1 do
        reaper.SetEnvelopePoint(env, k, timeInOptional, valueInOptional, shapeInOptional, tensionInOptional, false, true)
      end
    end

    -- LOOP IN REGIONS
    new_points = {}
    p=0
    repeat

      retval, isrgn, pos, rgnend, name, markrgnindex = reaper.EnumProjectMarkers2(0, p)

      if isrgn == false then -- if name mtach activate take name

        --GET POINT VALUE
        retval, valueOut, dVdSOutOptional, ddVdSOutOptional, dddVdSOutOptional = reaper.Envelope_Evaluate(env, pos, 0, 0)

        table.insert(new_points, {time = pos, val = valueOut, shape = dVdSOutOptional, tension = ddVdSOutOptional, dddVdSOutOptional})

      end

      p = p+1

    until retval == 0 -- end loop regions and markers

    for p, point in ipairs(new_points) do
      reaper.InsertEnvelopePoint(env, point.time, point.val, point.shape, point.tension, true, true) -- INSERT startLoop point
    end

    reaper.BR_EnvFree(br_env, 0)
    reaper.Envelope_SortPoints(env)

  end
end

function main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  -- GET CURSOR POS
  offset = reaper.GetCursorPosition()

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

        AddPoints(env)

      end -- ENDLOOP through envelopes

    end -- ENDLOOP through selected tracks

  else

    AddPoints(env)

  end -- endif sel envelope

  reaper.Undo_EndBlock("Add points on envelopes at markers", -1) -- End of the undo block. Leave it at the bottom of your main function.

end -- end main()

reaper.PreventUIRefresh(1)

main() -- Execute your main function

reaper.PreventUIRefresh(-1)

reaper.UpdateArrange() -- Update the arrangement (often needed)

reaper.TrackList_AdjustWindows(false)
