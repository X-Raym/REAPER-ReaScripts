--[[
 * ReaScript Name: Rename tracks with first VSTi preset name
 * About: A way to quickly rename and recolor tracks in a REAPER project from its instrument.
 * Instructions: Select tracks. Run.
 * Screenshot: http://i.giphy.com/l41lMgnQVFZp2qfjW.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Video & Sound Editors Will Really Like This
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1539710
 * Version: 1.1
--]]

--[[
 * Changelog:
 * v1.1 (2020-06-15)
  # Remove other prefixes
 * v1.0 (2019-10-03)
  + Initial Release
--]]

-- ------ USER CONFIG AREA =====>

--separator = "-"

-- <===== USER CONFIG AREA ------

function main()

  for i = 0, tracks_count - 1 do

    track = reaper.GetSelectedTrack(0, i)

    vsti_id = reaper.TrackFX_GetInstrument(track)

    if vsti_id >= 0 then

      retval, fx_name = reaper.TrackFX_GetFXName(track, vsti_id, "")

      fx_name = fx_name:gsub("VSTi: ", "")

      -- Just in case
      fx_name = fx_name:gsub("VST: ", "")

      fx_name = fx_name:gsub("AU: ", "")

      fx_name = fx_name:gsub("AUi: ", "")

      fx_name = fx_name:gsub("VST3i: ", "")

      fx_name = fx_name:gsub("JS: ", "")

      fx_name = fx_name:gsub("DX: ", "")

      fx_name = fx_name:gsub(" %(.-%)", "")

      retval, presetname = reaper.TrackFX_GetPreset(track, vsti_id, "")

      if retval == 0 then

        track_name_retval, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", fx_name, true)

      else

        track_name_retval, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", presetname, true)

      end

    end

  end

end

-- INIT
tracks_count = reaper.CountSelectedTracks(0)

if tracks_count > 0 then

  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  main()

  reaper.Undo_EndBlock("Rename tracks with first VSTi preset name", -1) -- End of the undo block. Leave it at the bottom of your main function.

  reaper.PreventUIRefresh(-1)

end
