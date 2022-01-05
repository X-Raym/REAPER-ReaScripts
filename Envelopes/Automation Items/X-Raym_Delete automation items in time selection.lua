--[[
 * ReaScript Name: Delete automation items in time selection
 * Author: X-Raym
 * Author URI: https://extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2020-12-08)
  + Initial Release
--]]

-- USER CONFIG AREA ----------------------
also_hidden_envelopes = false
preserve_points = false
------------------------------------------

ultraschall_path = reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua"
if reaper.file_exists( ultraschall_path ) then
  dofile( ultraschall_path )
end

if not ultraschall or not ultraschall.AutomationItem_Delete then -- If ultraschall loading failed of if it doesn't have the functions you want to use
  reaper.MB("Please install Ultraschall API, available via Reapack. Check online doc of the script for more infos.\nhttps://github.com/Ultraschall/ultraschall-lua-api-for-reaper", "Error", 0)
  return
end

function IsInTimeSelection( s, e, start_time, end_time )
  if s >= start_time and e <= end_time then return true end
  return false
end

function Msg(val)
  reaper.ShowConsoleMsg(tostring(val) .. "\n")
end

function GetTracks() -- Get selected tracks, or all tracks if none
  local tracks = {}
  local count_tracks = reaper.CountTracks(0)
  local count_sel_tracks = reaper.CountSelectedTracks(0)

  if count_sel_tracks > 0 then
    for i = 0, count_sel_tracks - 1 do
      table.insert( tracks, reaper.GetSelectedTrack(0, i ) )
    end
  else
    for i = 0, count_tracks - 1 do
      table.insert( tracks, reaper.GetTrack(0, i ) )
    end
  end
  return tracks
end

function Main()

  tracks = GetTracks()

  for i, track in ipairs( tracks ) do

    count_track_env = reaper.CountTrackEnvelopes( track )

    for j = 0, count_track_env - 1 do
      count_env = reaper.CountTrackEnvelopes( track )
      for e = 0, count_env - 1 do
        env = reaper.GetTrackEnvelope(track, e)
        count_auto_item = reaper.CountAutomationItems( env )
        if count_auto_item then

          visible, lane, unknown = ultraschall.GetEnvelopeState_Vis(env)
          init_visible = visible
          if visible == 0 and also_hidden_envelopes then
            retval = ultraschall.SetEnvelopeState_Vis(env, 1, lane, unknown)
          end

          if visible == 1 or also_hidden_envelopes then

            for idx = count_auto_item-1, 0, -1 do
              auto_item_pos = reaper.GetSetAutomationItemInfo( env, idx, "D_POSITION", 0, false )
              auto_item_end = auto_item_pos + reaper.GetSetAutomationItemInfo( env, idx, "D_LENGTH", 0, false )
              if IsInTimeSelection( auto_item_pos, auto_item_end, time_start, time_end ) then
                if visible == 0 then
                  retval = ultraschall.SetEnvelopeState_Vis(env, 1, lane, unknown)
                  visible = 1
                end
                retval = ultraschall.AutomationItem_Delete(env, idx, preserve_points)
              end
            end

            retval = ultraschall.SetEnvelopeState_Vis(env, init_visible, lane, unknown)

          end

        end
      end

    end

  end

end -- of main

function Init()
  count_tracks = reaper.CountTracks(0)
  time_start, time_end = reaper.GetSet_LoopTimeRange( false, false, 0, 0, false )

  if count_tracks > 0 and time_start ~= time_end then -- if user complete the fields

    reaper.ClearConsole()

    reaper.PreventUIRefresh(1)

    reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

    Main() -- Execute your main function

    reaper.Undo_EndBlock("Delete automation items in time selection", -1) -- End of the undo block. Leave it at the bottom of your main function.

    reaper.PreventUIRefresh(-1)

    reaper.UpdateArrange() -- Update the arrangement (often needed)

  end
end

if not preset_file_init then
  Init()
end
