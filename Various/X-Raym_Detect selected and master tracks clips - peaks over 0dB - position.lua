--[[
 * ReaScript Name: Detect selected and master tracks clips - peaks over 0dB - position
 * Instructions: Select items with take. Run.
 * Screenshot: http://i.giphy.com/3o8dpaSLqUezHdaVlC.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Script: Detect Tracks Clips - Peaks Over 0db - Position
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=170013
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2015-12-15)
  + Initial Release
--]]

-- USER CONFIG AREA ------------
do_tracks = "y" -- (y/n)
do_master = "y" -- (y/n)
delete_markers = "y" -- (y/n)
create_markers = "y" -- (y/n)
target_dB = "0" -- (y/n)

popup = true --(true/false)
--------------------------------

function Msg(value)
  reaper.ShowConsoleMsg(tostring(value).."\n")
end

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

function main()

  if do_tracks == "y" then

    for i, track in ipairs(tracks) do

      for j = 0, tracks_chan[i] - 1 do

        track_hold = reaper.Track_GetPeakHoldDB(track, j, false)

        if track_hold > 0 then

          peak_pos =  reaper.GetPlayPosition()
          peak_time_str = reaper.format_timestr(peak_pos, "")

          message = "0dB + "  .. tostring(track_hold*100) .. " ►  Track #" .. i .. " ► " .. tracks_name[i] .. " / channel " .. tostring((j+1))
          message_console = message .. "  ⏰ " .. peak_time_str

          overs_count = overs_count + 1
          --overs[overs_count] = {}
          --overs[overs_count].pos = peak_pos
          --overs[overs_count].msg = message
          --overs[overs_count].col = tracks_color[i]

          --reaper.AddProjectMarker2(0, false, overs[overs_count].pos , -1, overs[overs_count].msg, -1, overs[overs_count].col )
          reaper.AddProjectMarker2(0, false, peak_pos , -1, message, -1, tracks_color[i] )


          Msg(message_console)

          reaper.Track_GetPeakHoldDB(track, j, true)
          reaper.TrackList_AdjustWindows(false)

          reaper.UpdateTimeline()

        end

      end

    end

  end

  if do_master == "y" then

    for f = 0, master_chan - 1 do

      master_hold = reaper.Track_GetPeakHoldDB(master, f, false)

      if master_hold > 0 then

        peak_pos =  reaper.GetPlayPosition()
        peak_time_str = reaper.format_timestr(peak_pos, "")

        message = "0dB + "  .. tostring(master_hold*100) .. " ►  Track Master / channel " .. tostring((f+1))
        message_console = message .. "  ⏰ " .. peak_time_str

        overs_count = overs_count + 1
        --overs[overs_count] = {}
        --overs[overs_count].pos = peak_pos
        --overs[overs_count].msg = message
        --overs[overs_count].col = 0

        --reaper.AddProjectMarker2(0, false, overs[overs_count].pos , -1, overs[overs_count].msg, -1, overs[overs_count].col )
        reaper.AddProjectMarker2(0, false, peak_pos , -1, message, -1, 0 )

        Msg(message_console)

        reaper.Track_GetPeakHoldDB(master, f, true)
        reaper.TrackList_AdjustWindows(false)

        reaper.UpdateTimeline()

      end

    end

  end

  reaper.defer(main)

end

function Msg_Table (tbl, indent)
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      Msg(formatting)
      Msg(v, indent+1)
    elseif type(v) == 'boolean' then
      Msg(formatting .. tostring(v))
    else
      Msg(formatting .. v)
    end
  end
end

function Exit()

  Msg("⬑")
  Msg("End of Analysis")
  Msg("Overs Count = " .. overs_count)
  Msg("----------------")

  SetButtonOFF()

  --if overs_count > 0 and create_markers == "y" then

  --  CreateMarkers()

  --end

end

-- CREATE MARKERS
--[[
function CreateMarkers()

  reaper.Undo_BeginBlock()

  reaper.PreventUIRefresh(1)

  for z, over in ipairs(overs) do
    reaper.AddProjectMarker2(0, false, overs[z].pos , -1, overs[z].msg, -1, overs[z].col )
  end

  reaper.PreventUIRefresh(-1)

  reaper.Undo_EndBlock("Create markers from Tracks Overs Detection", -1)

end
]]--
-- CREATE MARKERS
function DeleteMarkers()

  reaper.Undo_BeginBlock()

  reaper.PreventUIRefresh(1)

  markers_id = {}

  i=0
  repeat
    iRetval, bIsrgnOut, iPosOut, iRgnendOut, sNameOut, iMarkrgnindexnumberOut, iColorOur = reaper.EnumProjectMarkers3(0,i)
    if iRetval >= 1 then
      x, y = string.find(sNameOut, "0dB +")
      if x ~= nil then
        table.insert(markers_id, iMarkrgnindexnumberOut)
      end
      i = i+1
    end
  until iRetval == 0

  for i, marker_id in ipairs(markers_id) do
    reaper.DeleteProjectMarker(0, marker_id, false)
  end

  reaper.PreventUIRefresh(-1)

  reaper.Undo_EndBlock("Delete markers created by Tracks Peaks Detection", -1)

end

function init()

  overs= {}
  overs_count = 0

  if do_tracks == "y" then

    -- VARIABLES
    tracks = {}
    tracks_chan = {}
    tracks_name = {}
    tracks_color = {}

    -- LOOP SELECTED TRACKS
    for i = 0, count_sel_tracks - 1 do

      -- SAVE TRACK INFOS
      track = reaper.GetSelectedTrack(0, i)
      track_chan = reaper.GetMediaTrackInfo_Value(track, "I_NCHAN")
      table.insert( tracks, track )
      table.insert( tracks_chan, track_chan)
      table.insert( tracks_color, reaper.GetMediaTrackInfo_Value(track, "I_CUSTOMCOLOR") )
      retval, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
      table.insert( tracks_name, track_name )

      -- RESET PEAK HOLD
      for j = 0, track_chan - 1 do
        reaper.Track_GetPeakHoldDB(track, j, true)
      end

    end

  end

  if do_master == "y" then
    -- MASTER TRACK
    master = reaper.GetMasterTrack(0)
    master_chan = reaper.GetMediaTrackInfo_Value(master, "I_NCHAN")

    for j = 0, master_chan - 1 do
      reaper.Track_GetPeakHoldDB(master, j, true)
    end

  end

  if delete_markers == "y" then
    DeleteMarkers()
  end

  SetButtonON()

  -- MESSAGES
  Msg("\n===============================>")
  Msg("Hot peaks Tracks analysis started.")
  Msg("----------------")
  Msg("Tracks:")
  if do_tracks == "y" then
    Msg_Table(tracks_name)
  end
  if do_master == "y" then
    Msg("Master")
  end
  Msg("----------------")
  Msg("Analysis:")
  Msg("↴")

  -- DEFER
  main()

  -- EXIT
  reaper.atexit( Exit )

end

-- INIT
count_sel_tracks = reaper.CountSelectedTracks(0)

-- IF track selection
if count_sel_tracks > 0 then

  if popup == true then

    retval, retval_csv = reaper.GetUserInputs("Detect tracks clips position", 4, "Do Selected Tracks? (y/n),Do Master Tracks? (y/n),Delete Previous Markers? (y/n),Create Markers at Overs (y/n)", do_tracks .. "," .. do_master .. "," .. delete_markers .. "," .. create_markers)

    if retval then

        do_tracks, do_master, delete_markers, create_markers = retval_csv:match("([^,]+),([^,]+),([^,]+),([^,]+)")

        if do_tracks ~= nil then

        init()

        end

    end

  else

    init()

  end

end