--[[
 * ReaScript Name: Select tracks with certain words in their SWS notes
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: https://github.com/X-Raym/REAPER-Scripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2021-02-27)
  + Initial release
--]]

-- USER CONFIG AREA -----------------------------------------------------------

console = true -- true/false: display debug messages in the console

words = {"Select", "Yes"}
full_word = true

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

  for i = 0, count_tracks - 1 do
    local track = reaper.GetTrack(0,i)
    local notes = reaper.NF_GetSWSTrackNotes(track)
    if notes then
      for z, word in ipairs(words) do
        if (full_word and notes:find( word ) and not notes:find( word .. "%a" )) or  (not full_word and notes:find( word ) ) then
          reaper.SetTrackSelected(track, true)
        end
      end
    end
  end
end

-- INIT

function Init()
  -- See if there is items selected
  count_tracks = reaper.CountTracks(0)

  if count_tracks > 0 then

    reaper.PreventUIRefresh(1)

    reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

    Main()

    reaper.Undo_EndBlock("Select tracks with certain words in their SWS notes", -1) -- End of the undo block. Leave it at the bottom of your main function.

    reaper.UpdateArrange()

    reaper.PreventUIRefresh(-1)

  end
end

if not preset_file_init then
  Init()
end

