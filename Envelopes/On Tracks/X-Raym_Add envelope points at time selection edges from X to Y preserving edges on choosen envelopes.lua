--[[
 * ReaScript Name: Add envelope points at time selection edges from X to Y preserving edges on choosen envelopes
 * Description: Insert points at time selection edges. You can deactivate the pop up window within the script.∑
 * Instructions: Make a selection area. Execute the script. Works on selected envelope or selected tracks envelope with armed visible envelope.
 * Screenshot: http://i.giphy.com/l0K7o2JPg4cpLr2Jq.gif
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI:
 * Licence: GPL v3
 * Forum Thread: Scripts (Lua): Multiple Tracks and Multiple Envelope Operations
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1499882
 * REAPER: 5.0
 * Extensions: 2.8.3
 * Version: 1.6.2
--]]

--[[
 * Changelog:
 * v1.6.2 (2018-04-10)
 	# FaderScaling support
 * v1.6.1 (2016-03-02)
   # Delete points in area
 * v1.6 (2016-03-01)
   + Independant "Inside" Parameter for X and Y (priority on X)
   # When prompt defaut envelope name is selected envelope one, if any.
 * v1.5 (2016-01-26)
   + Multitracks presets support
 * v1.4.3 (2016-01-20)
   + Units infos in prompt
   + Selected envelope as destination in prompt
   # List envelopes before prompt
 * v1.4.2 (2016-01-19)
   + Envelope scale types support (types: Volume, Pan/With, ReaSurround Gain)
   + "cursor" keyword for value
   # No popup if necessary conditions are not here
 * v1.4.1 (2016-01-19)
  # Bug fixes
 * v1.4 (2016-01-18)
  + Min, Max, Center in value input
  + Conform input value to destination envelope
 * v1.3 (2016-01-18)
  + Envelope Name in prompt
 * v1.2 (2016-01-18)
  + Time offsets
 * v1.1 (2016-01-18)
  + Optionnal infos in console
  + Value Y
 * v1.0 (2016-01-17)
  + Initial release
--]]


-- INIT TABLES ------------------

-- This is not a user area. Don't modify this.
insertions = {} -- prepare table of insertions
ins_idx = 0 -- prepare indexes of table of insertions

-------------- END OF INIT TABLES


-- USER CONFIG AREA ----------------------->

-- Notes: Copy and rename the script before moding.

-- Basic Settings
messages = true -- true/false : display infos in console
prompt = true -- true/false : display a prompt window at script run. Only envelope 1 will work in prompt mode.

-- Instructions: Copy envelope blocks below if you want to add another envelope.
-- Demo: http://quick.as/GRgDCz3l6

---- Envelope Block ----
ins_idx = ins_idx + 1 -- Prepare the index. Don't modify this.
insertions[ins_idx] = {} -- Prepare the following value. Don't modify this.

insertions[ins_idx].dest_env_name = "in 1 gain / ReaSurround" -- Name of the envelope. It will be overriden by the selected envelope name if there is one.

insertions[ins_idx].valueIn_X = 3 -- number/string : destination value OR "max", "min", "center", "cursor"
insertions[ins_idx].valueIn_Y = 0

insertions[ins_idx].offset_X = 1 -- number (seconds) : offset time selection left (create a linear ramp between the two left points
insertions[ins_idx].offset_Y = 2 -- number (seconds) : offset time selection right (create a linear ramp between the two right points

insertions[ins_idx].inside_X = 0 -- bolean (true/false) : offset time inside left in time selection
insertions[ins_idx].inside_Y = 0 -- bolean (true/false) : offset time inside right time selection

-------------------- End of envelope block

---- Envelope Block ----
ins_idx = ins_idx + 1 -- Prepare the index. Don't modify this.
insertions[ins_idx] = {} -- Prepare the following value. Don't modify this.

insertions[ins_idx].dest_env_name = "in 2 gain / ReaSurround" -- Name of the envelope. It will be overriden by the selected envelope name if there is one.

insertions[ins_idx].valueIn_X = 0 -- number/string : destination value OR "max", "min", "center", "cursor"
insertions[ins_idx].valueIn_Y = 3

insertions[ins_idx].offset_X = 1 -- number (seconds) : offset time selection left (create a linear ramp between the two left points
insertions[ins_idx].offset_Y = 2 -- number (seconds) : offset time selection right (create a linear ramp between the two right points

insertions[ins_idx].inside_X = 0 -- bolean (true/false) : offset time inside left in time selection
insertions[ins_idx].inside_Y = 0 -- bolean (true/false) : offset time inside right time selection

-------------------- End of envelope block

------------------- END OF USER CONFIG AREA



-- DEBUG -----------------------------------

-- Display Messages in the Console
function Msg(value)
  if messages == true then
    reaper.ShowConsoleMsg(tostring(value).."\n")
  end
end


--------------------------------END OF DEBUG



-- ENVELOPE FUNCTIONS ----------------------

-- Update points in time selection
function GetDeleteTimeLoopPoints(envelope, env_point_count, start_time, end_time)
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

  reaper.DeleteEnvelopePointRange(envelope, start_time-0.000000001, end_time+0.000000001)

  return first_start_val, last_start_val, first_end_val, last_end_val

end


-- Unselect all envelope points
function UnselectAllEnvelopePoints(envelope, env_points_count)

  -- UNSELECT POINTS
  if env_points_count > 0 then
    for k = 0, env_points_count+1 do
      reaper.SetEnvelopePoint(envelope, k, timeInOptional, valueInOptional, shapeInOptional, tensionInOptional, false, true)
    end
  end

end


-- dB to Val
function ValFromdB(dB_val) return 10^(dB_val/20) end


-- Conform value
function ConformValueToEnvelope(number, envelopeType)

  -- Volume
  if envelopeType == 0 then
    number = ValFromdB(number)
  end

  -- Pan/Width
  if envelopeType == 2 then
    number = (-number)/100
  end

  -- ReaSurround Gain
  if envelopeType == 11 then
    number = 10^((number-12.0)/20)
  end

  return number

end


-- Get envelope scale type
function GetEnvelopeScaleType(envelopeName)

  local dest_env_type = -1

  -- Volume log
  if envelopeName == "Volume" or envelopeName == "Volume (Pre-FX)" or envelopeName == "Send Volume" then
    dest_env_type = 0
  end

  -- Pan/Width
  if envelopeName == "Width" or envelopeName == "Width (Pre-FX)" or envelopeName == "Pan" or envelopeName == "Pan (Pre-FX)" or envelopeName == "Pan (Left)" or envelopeName == "Pan (Right)" or envelopeName == "Pan (Left, Pre-FX)" or envelopeName == "Pan (Right, Pre-FX)" or envelopeName == "Send Pan" then
    dest_env_type = 2
  end

  -- ReaSurround gain
  if string.find(envelopeName, "gain / ReaSurround") ~= nil then
    dest_env_type = 11
  end

  return dest_env_type

end


-- Update the TCP envelope value at edit cursor position
function HedaRedrawHack()
  reaper.PreventUIRefresh(1)

  track=reaper.GetTrack(0,0)

  trackparam=reaper.GetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT")
  if trackparam==0 then
    reaper.SetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT", 1)
  else
    reaper.SetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT", 0)
  end
  reaper.SetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT", trackparam)

  reaper.PreventUIRefresh(-1)

end


-------------------END OF ENVELOPE FUNCTIONS



-- MAIN FUNCTIONS --------------------------

-- Add Points
function AddPoints(env, valueIn_X, valueIn_Y, offset_X, offset_Y, inside_X, inside_Y)

  -- GET THE ENVELOPE
  br_env = reaper.BR_EnvAlloc(env, false)

  active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, type, faderScaling = reaper.BR_EnvGetProperties(br_env, true, true, true, true, 0, 0, 0, 0, 0, 0, true)

  if visible == true and armed == true then

    if faderScaling == true then
      minValue = reaper.ScaleToEnvelopeMode(1, minValue)
      maxValue = reaper.ScaleToEnvelopeMode(1, maxValue)
     centerValue = reaper.ScaleToEnvelopeMode(1, centerValue)
    end

    env_points_count = reaper.CountEnvelopePoints(env)

    -- UNSELECT ENVELOPE POINTS
    UnselectAllEnvelopePoints(env, env_points_count)

    -- CLEAN TIME SELECTION
	if start_time_offset < start_time then start_clean = start_time_offset else start_clean = start_time end
	if end_time_offset > end_time then end_clean = end_time_offset else end_clean = end_time end
    first_start_val, last_start_val, first_end_val, last_end_val = GetDeleteTimeLoopPoints(env, env_points_count, start_clean, end_clean)


    -- EDIT CURSOR VALUE EVALUATION
    retval_cursor_time, cursor_val, dVdS_cursor_time, ddVdS_cursor_time, dddVdS_cursor_time = reaper.Envelope_Evaluate(env, cursor_pos, 0, 0)
    Msg("Value at Edit Cursor:")
    Msg(cursor_val)

    -- CONFORM VALUE ACCORDING TO ENVELOPE
    valueOut_X = valueIn_X
    valueOut_Y = valueIn_Y

	if valueIn_X == "min"    then valueOut_X = minValue    end
	if valueIn_X == "max"    then valueOut_X = maxValue    end
    if valueIn_X == "center" then valueOut_X = centerValue end
	if valueIn_X == "cursor" then valueOut_X = cursor_val  end
	if valueIn_Y == "min"    then valueOut_Y = minValue    end
	if valueIn_Y == "max"    then valueOut_Y = maxValue    end
    if valueIn_Y == "center" then valueOut_Y = centerValue end
	if valueIn_Y == "cursor" then valueOut_Y = cursor_val  end

    -- SANITIZE VALUE X & Y
    if valueOut_X < minValue then valueOut_X = minValue end
    if valueOut_X > maxValue then valueOut_X = maxValue end
    if valueOut_Y < minValue then valueOut_Y = minValue end
    if valueOut_Y > maxValue then valueOut_Y = maxValue end

    -- FADER SCALE
    if env_scale == 1 then valueIn_X = reaper.ScaleToEnvelopeMode(1, valueOut_X) end
    if env_scale == 1 then valueIn_Y = reaper.ScaleToEnvelopeMode(1, valueOut_Y) end

	    -- INSERT RIGHT POINT
	if inside_X == 0 then
      reaper.InsertEnvelopePoint(env, start_time_offset, first_start_val, 0, 0, true, true) -- INSERT startLoop point
	  reaper.InsertEnvelopePoint(env, start_time, valueOut_X, 0, 0, true, true) -- INSERT X point
	else
	  reaper.InsertEnvelopePoint(env, start_time_offset, valueOut_X, 0, 0, true, true) -- INSERT startLoop point
	  reaper.InsertEnvelopePoint(env, start_time, first_start_val, 0, 0, true, true) -- INSERT X point
	end

    -- INSERT RIGHT POINT
	if inside_Y == 0 then
	  reaper.InsertEnvelopePoint(env, end_time_offset, last_end_val, 0, 0, true, true) -- INSERT startLoop point
	  reaper.InsertEnvelopePoint(env, end_time, valueOut_Y, 0, 0, true, true) -- INSERT Y point
	else
	  reaper.InsertEnvelopePoint(env, end_time_offset, valueOut_Y, 0, 0, true, true) -- INSERT startLoop point
	  reaper.InsertEnvelopePoint(env, end_time, last_end_val, 0, 0, true, true) -- INSERT Y point
	end

	-- RELEASE ENVELOPE
    reaper.BR_EnvFree(br_env, 0)
    reaper.Envelope_SortPoints(env)

  end

end



function main(dest_env_name, valueIn_X, valueIn_Y, offset_X, offset_Y, inside_X, inside_Y)

  -- GET CURSOR POS
  cursor_pos = reaper.GetCursorPosition()

  -- ROUND LOOP TIME SELECTION EDGES
  start_time = math.floor(start_time * 100000000+0.5)/100000000
  end_time = math.floor(end_time * 100000000+0.5)/100000000

  -- OFFSETS
  if inside_X == 0 then
	start_time_offset = start_time - offset_X
  else
	start_time_offset = start_time + offset_X
  end

  if inside_Y == 0 then
	end_time_offset = end_time + offset_Y
  else
	end_time_offset = end_time - offset_Y
	if end_time_offset < start_time_offset then end_time_offset = start_time_offset end
  end

  -- LOOP TRHOUGH SELECTED TRACKS
  if sel_env == nil then

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
          AddPoints(env, valueIn_X, valueIn_Y, offset_X, offset_Y, inside_X, inside_Y)
        end

      end -- ENDLOOP through envelopes

    end -- ENDLOOP through selected tracks

  else

    retval, envName = reaper.GetEnvelopeName(sel_env, "")

    if envName == dest_env_name then
      AddPoints(sel_env, valueIn_X, valueIn_Y, offset_X, offset_Y, inside_X, inside_Y)
    end

  end -- endif sel envelope

end -- end main()


-----------------------END OF MAIN FUNCTIONS



-- INIT ------------------------------------

-- GET SELECTED ENVELOPE
sel_env = reaper.GetSelectedEnvelope(0)

-- COUNT SELECTED TRACKS
selected_tracks_count = reaper.CountSelectedTracks(0)

-- GET TIME SELECTION EDGES
start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)

-- IF TIME SELECTION
if start_time ~= end_time and (sel_env or selected_tracks_count > 0) then

  -- CLEAR CONSOLE
  if messages then reaper.ClearConsole() end

  Msg("INSTRUCTIONS")
  Msg("------------")
  Msg("This script can be moded. Copy the file and edit the default values in the User Config Area at the top of the script code.")
  Msg("------------")
  Msg("Avaible Value keywords:")
  Msg("min, max, center, cursor")
  Msg("------------")

  -- SELECTED ENVELOPE NAME
  if sel_env then

    retval, dest_env_name = reaper.GetEnvelopeName(sel_env, "")

    if messages == true then
      Msg("Selected envelope: ")
      Msg(dest_env_name)
    end

  else

    -- LIST ALL ENVELOPES
    for i = 0, selected_tracks_count-1  do
      -- GET THE TRACK
      track = reaper.GetSelectedTrack(0, i) -- Get selected track i
      track_name_retval, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
      Msg("\nSelected Track #"..i.." :")
      Msg(track_name)

      -- LOOP THROUGH ENVELOPES
      env_count = reaper.CountTrackEnvelopes(track)
      for j = 0, env_count-1 do

        -- GET THE ENVELOPE
        env = reaper.GetTrackEnvelope(track, j)

        retval, envName = reaper.GetEnvelopeName(env, "")
        if messages == true then
          Msg("Envelope #"..j.." :")
          Msg(envName)
        end

      end -- ENDLOOP through envelopes

    end -- ENDLOOP through selected tracks

  end

  -- PROMPT
  if prompt then
    insertions[1].valueIn_X = tostring(insertions[1].valueIn_X)
    insertions[1].valueIn_Y = tostring(insertions[1].valueIn_Y)
	if not sel_env then dest_env_name = insertions[1].dest_env_name end
	retval, retvals_csv = reaper.GetUserInputs("Set Envelope Points", 7, "Envelope Name,Value X (number),Value Y (number),Time Offset X (s),Time Offset Y (s),Inside TS Left (0/1),Inside TS Right(0,1)", dest_env_name .. "," .. insertions[1].valueIn_X .. "," .. insertions[1].valueIn_Y .. "," .. insertions[1].offset_X .. "," .. insertions[1].offset_Y .. "," .. insertions[1].inside_X .. "," .. insertions[1].inside_Y)
  end

  if retval or prompt == false then -- if user complete the fields

    reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

    reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

    if prompt then
      insertions[1].dest_env_name, insertions[1].valueIn_X, insertions[1].valueIn_Y, insertions[1].offset_X, insertions[1].offset_Y, insertions[1].inside_X, insertions[1].inside_Y = retvals_csv:match("([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)")
    end

    for i, insert in ipairs(insertions) do

      if insert.dest_env_name and insert.valueIn_X and insert.valueIn_Y and insert.offset_X and insert.offset_Y and insert.inside_X and insert.inside_Y then

        insert.dest_env_type = GetEnvelopeScaleType(insert.dest_env_name)

        if insert.valueIn_X ~= "min" and insert.valueIn_X ~= "max" and insert.valueIn_X ~= "center" and insert.valueIn_X ~= "cursor" then
          insert.valueIn_X = tonumber(insert.valueIn_X)
          insert.valueIn_X = ConformValueToEnvelope(insert.valueIn_X, insert.dest_env_type)
        end

        if insert.valueIn_Y ~= "min" and insert.valueIn_Y ~= "max" and insert.valueIn_Y ~= "center" and insert.valueIn_Y ~= "cursor" then
          insert.valueIn_Y = tonumber(insert.valueIn_Y)
          insert.valueIn_Y = ConformValueToEnvelope(insert.valueIn_Y, insert.dest_env_type)
        end

        insert.offset_X = tonumber(insert.offset_X)
        insert.offset_Y = tonumber(insert.offset_Y)

		insert.inside_X = tonumber(insert.inside_X)
		insert.inside_Y = tonumber(insert.inside_Y)

		if insert.valueIn_X and insert.valueIn_Y and insert.offset_X and insert.offset_Y and insert.inside_X and insert.inside_Y then

			main(insert.dest_env_name, insert.valueIn_X, insert.valueIn_Y, insert.offset_X, insert.offset_Y, insert.inside_X, insert.inside_Y) -- Execute your main function

        end

        if prompt then break end

      end -- ENDIF values

    end -- LOOP insertions

    reaper.Undo_EndBlock("Add envelope points at time selection edges from X to Y preserving edges on choosen envelopes", -1) -- End of the undo block. Leave it at the bottom of your main function.

    HedaRedrawHack()

    reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

    reaper.UpdateArrange() -- Update the arrangement (often needed)

  end -- ENDIF retval or Prompt

end -- ENDIF time selection
