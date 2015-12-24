--[[
 * ReaScript Name: Delete envelope points below consecutive threshold (envelope smoother)
 * Description: A pop up to let you put the consecutive threshold.
 * Instructions: Select tracks with visible and armed envelopes or select an envelope. Execute the script.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: 
 * Licence: GPL v3
 * Forum Thread: Scripts (Lua): Multiple Tracks and Multiple Envelope Operations 
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=157483
 * REAPER: 5.0 pre 36
 * Extensions: SWS 2.7.3 #0
 * Version: 1.0
]]
 
--[[
 * Changelog:
 * v1.0 (2015-07-19)
  + Initial Release
]]

-- ------ USER DEFAULT SETTINGS AREA =====>
-- here you can customize the default values of the script

time_threshold = 0.1 -- Default consecutive threshold in seconds.

-- <===== USER DEFAULT SETTINGS AREA ------

--[[ ----- DEBUGGING ===>
function get_script_path()
  if reaper.GetOS() == "Win32" or reaper.GetOS() == "Win64" then
  return debug.getinfo(1,'S').source:match("(.*".."\\"..")"):sub(2) -- remove "@"
  end
  return debug.getinfo(1,'S').source:match("(.*".."/"..")"):sub(2)
end

package.path = package.path .. ";" .. get_script_path() .. "?.lua"
require("X-Raym_Functions - console debug messages")

debug = 1 -- 0 => No console. 1 => Display console messages for debugging.
clean = 1 -- 0 => No console cleaning before every script execution. 1 => Console cleaning before every script execution.

--msg_clean()
]]-- <=== DEBUGGING -----

function Action(env)
  
  count_points = reaper.CountEnvelopePoints(env)
  if count_points > 0 then
    for p = 0, count_points - 1 do
      point_retval, point_time, point_value, point_shape, point_tension, point_selected = reaper.GetEnvelopePoint(env, p)
      reaper.SetEnvelopePoint(env, p, point_time, point_value, point_shape, point_tension, false, false)
    end
  end

  if count_points > 2 then
    
    repeat
    
      delete_points = false
    
      br_env = reaper.BR_EnvAlloc(env, false)
      br_env_active, br_env_visible, br_env_armed, br_env_inLane, br_env_laneHeight, br_env_defaultShape, br_env_minValue, br_env_maxValue, br_env_centerValue, br_env_type, br_env_faderScaling = reaper.BR_EnvGetProperties(br_env, true, true, true, true, 0, 0, 0, 0, 0, 0, true)
      
      if br_env_visible and br_env_armed then

        for k = 1, count_points - 1 do

          point_retval, point_time, point_value, point_shape, point_tension, point_selected = reaper.GetEnvelopePoint(env, k)

          prev_retval, prev_time, prev_value, prev_shape, prev_tension, prev_selected = reaper.GetEnvelopePoint(env, k-1)

          -- IF LOOP IS BELOW THE LAST POINTS
          if k < count_points - 1 then

            next_retval, next_time, next_value, next_shape, next_tension, next_selected = reaper.GetEnvelopePoint(env, k+1)

          else -- IF LOOP REACH THE LAST POINTS
            next_time = point_time
          end

          -- IF PREVIOUS POINT IS NOT SELECTED AND IF POINT TIME - PREVIOUS POINT TIME IS UNDER TIME THRESHOLD
          if prev_selected == false and (point_time - prev_time) < time_threshold then
            
            -- IF NEXT POINT IS UNDER TIME THRESHOLD THEN SELECT THE POINT
            if (next_time - point_time) < time_threshold then
              
              if time_selection == true then -- if there is a time selection
                
                if point_time >= start_time and point_time <= end_time then -- if point is inside time selection
                  reaper.SetEnvelopePoint(env, k, point_time, point_value, point_shape, point_tension, true, false)
                end
              
              else -- if there is no time selection
                reaper.SetEnvelopePoint(env, k, point_time, point_value, point_shape, point_tension, true, false)
              end
            
            end

          end

        end
        
        -- DELETE SELECTED POINTS
        for p = 0, count_points-1 do
        
          point_retval, point_time, point_value, point_shape, point_tension, point_selected = reaper.GetEnvelopePoint(env, count_points-1-p)
          
          -- POINT SELECTED
          if point_selected == true then
            reaper.BR_EnvDeletePoint(br_env, (count_points-1-p))
            delete_points = true
          end
        
        end -- END LOOP THROUGH SAVED POINTS
        
       end -- end of check if track is visible and armed
        
      reaper.BR_EnvFree(br_env, 1)
      reaper.Envelope_SortPoints(env)
      
    until delete_points == false

  end -- END if there is more than two points on track
  

end -- END OF FUNCTION


function main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)

  if start_time ~= end_time then
    time_selection = true
  end
    
  -- LOOP TRHOUGH SELECTED TRACKS
  env = reaper.GetSelectedEnvelope(0)

  if env == nil then

    selected_tracks_count = reaper.CountSelectedTracks(0)
    if selected_tracks_count > 0 then
      
      retval, time_threshold = reaper.GetUserInputs("Envelope Smoother", 1, "Time value ? (s)", tostring(time_threshold)) -- We suppose that the user know the scale he want
      if retval then
      
        time_threshold = tonumber(time_threshold)
        if time_threshold ~= nil then
      
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

        end
        
      end
    
    end
  
  else
    
    retval, time_threshold = reaper.GetUserInputs("Envelope Smoother", 1, "Time value ? (s)", tostring(time_threshold)) -- We suppose that the user know the scale he want
    
    if retval then
      
      time_threshold = tonumber(time_threshold)
      
      if time_threshold ~= nil then
        Action(env)
      end
      
    end
  
  end -- endif sel envelope

  reaper.Undo_EndBlock("Delete envelope points below consecutive threshold (envelope smoother)", -1) -- End of the undo block. Leave it at the bottom of your main function.

end -- end main()

--msg_start() -- Display characters in the console to show you the begining of the script execution.

main() -- Execute your main function

reaper.UpdateArrange() -- Update the arrangement (often needed)

--msg_end() -- Display characters in the console to show you the end of the script execution.

