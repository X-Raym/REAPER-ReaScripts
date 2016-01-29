--[[
 * ReaScript Name: Toggle envelopes properties
 * Description: A way to set properties of several envelopes
 * Instructions: Select tracks with visible and armed envelopes. Execute the script. Note that if there is an envelope selected, it will work only for it.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI:
 * Licence: GPL v3
 * Forum Thread: Scripts (Lua): Multiple Tracks and Multiple Envelope Operations
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=157483
 * REAPER: 5.0
 * Extensions: SWS 2.8.3
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2016-01-29)
  + Initial release
 --]]
 
-- ------ USER CONFIG AREA =====>
-- here you can customize the script
dest_env_name = "Volume"

-- Envelope Output Properties
active_out = nil -- true or false or nil for toggle
-- <===== USER CONFIG AREA ------

function Msg(val)
  reaper.ShowConsoleMsg(tostring(val).."\n")
end

function Action(env)
  
  -- GET THE ENVELOPE
  local br_env = reaper.BR_EnvAlloc(env, false)

  local active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, type, faderScaling = reaper.BR_EnvGetProperties(br_env, true, true, true, true, 0, 0, 0, 0, 0, 0, true)

  -- IF ENVELOPE IS A CANDIDATE
  if visible == true and armed == true then
	
	if active_out == nil then
		if active then active = false
		else active = true end
	else
		active = active_out
	end
  
    reaper.BR_EnvSetProperties(br_env, active, visible, armed, inLane, laneHeight, defaultShape, faderScaling)
  
  end
  
  reaper.BR_EnvFree(br_env, 1)
  -- reaper.Envelope_SortPoints(env)

end

function main() -- local (i, j, item, take, track)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
  
  edit_pos = reaper.GetCursorPosition()
  
  -- LOOP TRHOUGH SELECTED TRACKS
  env = reaper.GetSelectedEnvelope(0)

  if env == nil then

    selected_tracks_count = reaper.CountSelectedTracks(0)
    
    -- if selected_tracks_count > 0 and UserInput() then
    if selected_tracks_count > 0 then
      for i = 0, selected_tracks_count-1  do
        
        -- GET THE TRACK
        track = reaper.GetSelectedTrack(0, i) -- Get selected track i

        -- LOOP THROUGH ENVELOPES
        env_count = reaper.CountTrackEnvelopes(track)
        for j = 0, env_count-1 do

          -- GET THE ENVELOPE
          env = reaper.GetTrackEnvelope(track, j)

          	retval, envName = reaper.GetEnvelopeName(env, "")
			if envName == dest_env_name then
			  Action(env)
			end

        end -- ENDLOOP through envelopes

      end -- ENDLOOP through selected tracks
      
    end

  else
	
	retval, envName = reaper.GetEnvelopeName(env, "")
	if envName == dest_env_name then
      Action(env)
    end
  
  end -- endif sel envelope

  reaper.Undo_EndBlock("Toggle envelopes properties", -1) -- End of the undo block. Leave it at the bottom of your main function.

end -- end main()


-- INIT

reaper.PreventUIRefresh(1)-- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)
