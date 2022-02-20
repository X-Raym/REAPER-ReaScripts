--[[
 * ReaScript Name: Set FX name offline on selected tracks
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: https://github.com/X-Raym/REAPER-Scripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2022-02-20)
  + Initial release
--]]

-- USER CONFIG AREA -----------------------------------------------------------

console = true -- true/false: display debug messages in the console

names = {"ReaEQ", "ReaComp"}

------------------------------------------------------- END OF USER CONFIG AREA

-- UTILITIES -------------------------------------------------------------

-- Display a message in the console for debugging
function Msg(value)
  if console then
    reaper.ShowConsoleMsg(tostring(value) .. "\n")
  end
end

--------------------------------------------------------- END OF UTILITIES

-- Main function
function Main()

  for i = 0, count_sel_tracks - 1 do
    local track = reaper.GetSelectedTrack(0,i)
    local count_fx = reaper.TrackFX_GetCount( track )
    for j = 0, count_fx - 1 do
      local retval, fx_name = reaper.TrackFX_GetFXName(track, j, "")
      for z, name in ipairs(names) do
        if fx_name:find( name ) then
          reaper.TrackFX_SetOffline(track, j, true)
        end
      end
    end
  end
end

-- INIT

function Init()
  -- See if there is items selected
  count_sel_tracks = reaper.CountSelectedTracks(0)

  if count_sel_tracks > 0 then

    reaper.PreventUIRefresh(1)

    reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

    Main()

    reaper.Undo_EndBlock("Set FX name offline on selected tracks", -1) -- End of the undo block. Leave it at the bottom of your main function.

    reaper.UpdateArrange()

    reaper.PreventUIRefresh(-1)

  end
end

if not preset_file_init then
  Init()
end

