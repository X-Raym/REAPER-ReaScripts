--[[
 * ReaScript Name: Delete envelope points at cursor position
 * About: A way to delete multiple points across different envelopes and tracks.
 * Instructions: Make a selection area. Execute the script.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Script (LUA): Copy points envelopes in time selection and paste them at edit cursor
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1497832#post1497832
 * Version: 1.1
 * Version Date: 2015-03-21
 * REAPER: 5.0 pre 18b
 * Extensions: SWS 2.6.3 #0
--]]

--[[
 * Changelog:
 * v1.1 (2015-03-21)
  + Selected envelope overides armed and visible envelope on selected tracks
 * v1.0 (2015-03-20)
  + Initial release
--]]


function Action(env)

  -- GET THE ENVELOPE
  retval, envelopeName = reaper.GetEnvelopeName(env, "envelopeName")
  br_env = reaper.BR_EnvAlloc(env, false)

  active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, type, faderScaling = reaper.BR_EnvGetProperties(br_env, true, true, true, true, 0, 0, 0, 0, 0, 0, true)

  -- IF ENVELOPE IS A CANDIDATE
  if visible == true and armed == true then

    reaper.DeleteEnvelopePointRange(env, offset-0.000000001, offset+0.000000001)

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

        Action(env)

      end -- ENDLOOP through envelopes

    end -- ENDLOOP through selected tracks

  else

    Action(env)

  end -- endif sel envelope

  reaper.Undo_EndBlock("Invert envelope points values", 0) -- End of the undo block. Leave it at the bottom of your main function.

end -- end main()




main() -- Execute your main function


reaper.UpdateArrange() -- Update the arrangement (often needed)



-- Update the TCP envelope value at edit cursor position
reaper.TrackList_AdjustWindows( false )
