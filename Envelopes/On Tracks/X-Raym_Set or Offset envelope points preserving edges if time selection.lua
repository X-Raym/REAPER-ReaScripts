--[[
 * ReaScript Name: Set or Offset envelope points preserving edges if time selection
 * About: A pop up to let you put offset values for selected item points.
 * Instructions: Write values you want. Use "+" sign for relative value (the value is added to the original), no sign for absolute Exemple: -6 is absolute, or +-6 is relative. Don't use percentage. Example: writte "60" for 60%.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: ReaScript: Set/Offset selected envelope points values
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1487882#post1487882
 * REAPER: 5.0 pre 9
 * Extensions: SWS 2.6.3 #0
 * Version: 1.6
]]

--[[
 * Changelog:
 * v1.6 (2015-09-09)
  + Fader scaling support
 * v1.5.2 (2015-08-22)
  # Bug fix
 * v1.5.1 (2015-07-16)
  # Bug fix when Cancel
 * v1.5 (2015-07-11)
  + Send support
 * v1.4 (2015-06-25)
  # Dual pan track support
 * v1.3 (2015-05-26)
  # Time selection bug fix
  + Works on multiple tracks
  # bug fix when pop up is cancelled
 * v1.2.1 (2015-05-07)
  # Time selection bug fix
 * v1.2 (2015-04-26)
  + Better edges preservation
 * v1.0 (2015-03-21)
  + Initial Release
]]

-- ------ USER AREA =====>
mod1 = "absolute" -- Set the primary mod that will be defined if no prefix character. Values are "absolute" or "relative".
mod2_prefix = "+" -- Prefix to enter the secondary mod
input_default = "" -- "" means no character aka relative per default.
-- <===== USER AREA ------


-- ----- CONFIG ====>

preserve_edges = true -- True will insert points à time selection edges before the action.

-- <==== CONFIG -----

-- INIT
time = {}
valueSource = {}
shape = {}
tension = {}
selectedOut = {}

function GetTimeLoopPoints(envelope, env_point_count, start_time, end_time)
  local set_first_start = 0
  local set_first_end = 0
  for i = 0, env_point_count do
    retval, time, valueOut, shape, tension, selectedOut = reaper.GetEnvelopePoint(envelope,i)

    if start_time == time and set_first_start == 0 then
      set_first_start = 1
      first_start_idx = i
      first_start_val = valueOut
    end
    if end_time == time and set_first_end == 0 then
      set_first_end = 1
      first_end_idx = i
      first_end_val = valueOut
    end
    if set_first_end == 1 and set_first_start == 1 then
      break
    end
  end

  local set_last_start = 0
  local set_last_end = 0
  for i = 0, env_point_count do
    retval, time, valueOut, shape, tension, selectedOut = reaper.GetEnvelopePoint(envelope,env_point_count-1-i)

    if start_time == time and set_last_start == 0 then
      set_last_start = 1
      last_start_idx = env_point_count-1-i
      last_start_val = valueOut
    end
    if end_time == time and set_last_end == 0 then
      set_last_end = 1
      last_end_idx = env_point_count-1-i
      last_end_val = valueOut
    end
    if set_last_start == 1 and set_last_end == 1 then
      break
    end
  end

  if first_start_val == nil then
    retval_start_time, first_start_val, dVdS_start_time, ddVdS_start_time, dddVdS_start_time = reaper.Envelope_Evaluate(envelope, start_time, 0, 0)
    first_end_val=first_start_val
  end
  if last_end_val == nil then
    retval_end_time, last_end_val, dVdS_end_time, ddVdS_end_time, dddVdS_end_time = reaper.Envelope_Evaluate(envelope, end_time, 0, 0)
  end

  if last_start_val == nil then
    last_start_val = first_start_val
  end
  if first_end_val == nil then
    first_end_val = last_end_val
  end

  return first_start_val, last_start_val, first_end_val, last_end_val

end

function main()

  retval, user_input_str = reaper.GetUserInputs("Set point value", 1, "Value ?", "") -- We suppose that the user know the scale he want

  if retval then

    x, y = string.find(user_input_str, mod2_prefix)
    --reaper.ShowConsoleMsg(user_input_str)

    if mod1 == "absolute" then
      if x ~= nil then -- set
        set = false
      else -- offset
        set = true
      end
    end

    if mod1 == "relative" then
      if x ~= nil then -- set
        set = true
      else -- offset
        set = false
      end
    end

    user_input_str = user_input_str:gsub(mod2_prefix, "")

    user_input_num = tonumber(user_input_str)

    -- IF VALID INPUT
    if user_input_num ~= nil then

      -- GET LOOP
      start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
      -- IF LOOP ?
      if start_time ~= end_time then
        time_selection = true
      end

      -- GET SELECTED ENVELOPE
      sel_env = reaper.GetSelectedEnvelope(0)

      if sel_env ~= nil then
        env_point_count = reaper.CountEnvelopePoints(sel_env)
        retval, env_name = reaper.GetEnvelopeName(sel_env, "")

        -- LOOP TRHOUGH SELECTED TRACKS
        selected_tracks_count = reaper.CountSelectedTracks(0)
        for j = 0, selected_tracks_count-1  do

          -- GET THE TRACK
          track = reaper.GetSelectedTrack(0, j) -- Get selected track i

          env_count = reaper.CountTrackEnvelopes(track)

          for m = 0, env_count-1 do

            -- GET THE ENVELOPE
            env_dest = reaper.GetTrackEnvelope(track, m)
            retval, env_name_dest = reaper.GetEnvelopeName(env_dest, "")

            if env_name_dest == env_name then

              -- IF VISIBLE AND ARMED
              br_env = reaper.BR_EnvAlloc(env_dest, false)
              active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, type, faderScaling = reaper.BR_EnvGetProperties(br_env, true, true, true, true, 0, 0, 0, 0, 0, 0, true)
              if visible == true and armed == true then

                env_points_count = reaper.CountEnvelopePoints(env_dest)
                first_start_val, last_start_val, first_end_val, last_end_val = GetTimeLoopPoints(env_dest, env_points_count, start_time, end_time)

                SetValue(env_dest)

                -- PRESERVE EDGES INSERTION
                if time_selection == true and preserve_edges == true then

                  reaper.DeleteEnvelopePointRange(env_dest, start_time-0.000000001, start_time+0.000000001)
                  reaper.DeleteEnvelopePointRange(env_dest, end_time-0.000000001, end_time+0.000000001)

                  reaper.InsertEnvelopePoint(env_dest, start_time, first_start_val, 0, 0, true, true) -- INSERT startLoop point
                  reaper.InsertEnvelopePoint(env_dest, end_time, last_end_val, 0, 0, true, true) -- INSERT startLoop point

                end

                reaper.BR_EnvFree(br_env, 0)
                reaper.Envelope_SortPoints(env_dest)

              end -- ENDIF envelope passed

            end -- ENDIF envelope with same name selected

          end -- ENDLOOP selected tracks envelope

        end -- ENDLOOP selected tracks
      end
    end
  end

end -- end main()

function SetValue(envelope)

  already_set = false

  if env_name == "Volume" or env_name == "Volume (Pre-FX)" or env_name == "Send Volume" then
    already_set = true

    for i = 0, env_point_count - 1 do

      -- IDX 0 doesnt seem to work
      retval, time, valueOut, shape, tension, selectedOut = reaper.GetEnvelopePoint(envelope,i)

      if faderScaling == true then valueOut = reaper.ScaleFromEnvelopeMode(1, valueOut) end

      if set == true then
        valueOut = math.exp(0*0.115129254)
      end

      -- CALC
      OldVol = valueOut
      OldVolDB = 20*(math.log(OldVol, 10)) -- thanks to spk77!

      --msg_ftl("Old vol db:", OldVolDB, 1)

      calc = OldVolDB + user_input_num
      --msg_ftl("Calc", calc, 1)
      --reaper.ShowConsoleMsg(tostring(calc))

      if calc <= -146 then
        valueIn = 0
        --msg_s("Volume <= -146")
      end
      if calc >= 6 then
        valueIn = 2
        --msg_s("+12 <= Volume")
      end
      if calc < 6 and calc > -146 then
        valueIn = math.exp(calc*0.115129254)
        --msg_s("-146 < Volume < +12")
      end


      if faderScaling == true then valueIn = reaper.ScaleToEnvelopeMode(1, valueIn) end

      ----msg_ftl("Value ouput", valueIn, 1)
      -- SET POINT VALUE
      if time_selection == true then
        if time >= start_time and time <= end_time then
          reaper.SetEnvelopePoint(envelope, i, time, valueIn, shape, tension, 1, noSortInOptional)
        end
      else
        reaper.SetEnvelopePoint(envelope, i, time, valueIn, shape, tension, 1, noSortInOptional)
      end

    end -- END Loop
  end -- ENDIF Volume

  if env_name == "Mute" or env_name == "Send Mute" then
    already_set = true

    for i = 0, env_point_count - 1 do

      -- IDX 0 doesnt seem to work
      retval, time, valueOut, shape, tension, selectedOut = reaper.GetEnvelopePoint(envelope,i)
      if set == true then
        valueOut = 0
      end

      -- CALC
      calc = valueOut + user_input_num

      if calc < 0 then
        valueIn = 0
        --msg_s("Mute = 0")
      end
      if calc >= 1 then
        valueIn = 1
        --msg_s("Mute = 1")
      end
      if calc < 0.5 then
        valueIn = 0
        --msg_s("Mute Floor < 0.5")
      end
      if calc >= 0.5 then
        valueIn = 1
        --msg_s("0.5 <= Mute Floor")
      end

      -- SET POINT VALUE
      if time_selection == true then
        if time >= start_time and time <= end_time then
          reaper.SetEnvelopePoint(envelope, i, time, valueIn, shape, tension, 1, noSortInOptional)
        end
      else
        reaper.SetEnvelopePoint(envelope, i, time, valueIn, shape, tension, 1, noSortInOptional)
      end

    end -- END Loop
  end -- ENDIF Mute

  if env_name == "Width" or env_name == "Width (Pre-FX)" or env_name == "Pan" or env_name == "Pan (Pre-FX)" or env_name == "Pan (Left)" or env_name == "Pan (Right)" or env_name == "Pan (Left, Pre-FX)" or env_name == "Pan (Right, Pre-FX)" or env_name == "Send Pan" then
    already_set = true

    for i = 0, env_point_count - 1 do

      -- IDX 0 doesnt seem to work
      retval, time, valueOut, shape, tension, selectedOut = reaper.GetEnvelopePoint(envelope,i)
      if set == true then
        valueOut = 0

      end

      -- CALC
      calc = valueOut*100 - user_input_num

      if calc <= -100 then
        valueIn = - 1.0
        --msg_s("Pan/Width <= -100")
      end
      if calc >= 100 then
        valueIn = 1.0
        --msg_s("Pan/Width >= 100")
      end
      if calc < 100 and calc > -100 then
        valueIn = calc / 100
        --msg_s("-100 < Pan/Width < 100")
      end

      -- SET POINT VALUE
      if time_selection == true then
        if time >= start_time and time <= end_time then
          reaper.SetEnvelopePoint(envelope, i, time, valueIn, shape, tension, 1, noSortInOptional)
        end
      else
        reaper.SetEnvelopePoint(envelope, i, time, valueIn, shape, tension, 1, noSortInOptional)
      end

    end -- END Loop
  end -- ENDIF Pan or Width

  if already_set == false then -- IF ENVELOPE HAS NO NAME PAS ICI LA BOUCL !!

    for i = 0, env_point_count - 1 do

      -- IDX 0 doesnt seem to work
      retval, time, valueOut, shape, tension, selectedOut = reaper.GetEnvelopePoint(envelope,i)

      if set == true then
        valueOut = 0
      end

      -- CALC
      calc = valueOut*100 + user_input_num

      if calc <= 0 then
        valueIn = 0
        --msg_s("FX <= 0")
      end
      if calc >= 100 then
        valueIn = 1.0
        --msg_s("100 <= FX")
      end
      if calc < 100 and calc > -100 then
        valueIn = calc / 100
        --msg_s("0 < FX < 100")
      end

      -- SET POINT VALUE
      if time_selection == true then
        if time >= start_time and time <= end_time then
          reaper.SetEnvelopePoint(envelope, i, time, valueIn, shape, tension, 1, noSortInOptional)
        end
      else
        reaper.SetEnvelopePoint(envelope, i, time, valueIn, shape, tension, 1, noSortInOptional)
      end

    end -- END Loop
  end -- ENDIF Fx

end -- END OF FUNCTION


reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
main() -- Execute your main function
reaper.Undo_EndBlock("Set or Offset envelope point value", -1) -- End of the undo block. Leave it at the bottom of your main function.
reaper.UpdateArrange() -- Update the arrangement (often needed)

reaper.TrackList_AdjustWindows( false )

