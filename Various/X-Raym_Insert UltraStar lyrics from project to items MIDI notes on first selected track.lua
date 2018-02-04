--[[
 * ReaScript Name: Insert UltraStar lyrics from project to items MIDI notes on first selected track
 * Description: See title.
 * Instructions: Select atrack. Run. Supports both UltraStar Creator and YASS syntax.
 * Screenshot: https://i.imgur.com/ELPdgLn.gif
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Creating Karaoke Songs for UltraStar and Vocaluxe with REAPER
 * Forum Thread URI: https://forum.cockos.com/showthread.php?t=202430
 * REAPER: 5.0
 * Version: 1.0.1
--]]

--[[
 * Changelog:
 * v1.0.1 (2018-02-03)
  # "+" pattern is fixed
 * v1.0 (2018-01-25)
  + Initial Release
--]]

track = reaper.GetSelectedTrack(0,0)

if not track then return end

-- Split CSV string
function string:split(sep)
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  self:gsub(pattern, function(c) fields[#fields+1] = c end)
  return fields
end
reaper.ClearConsole()
var = reaper.GetSetProjectNotes( 0, false, '' )

if not var or var == "" then return end

var = var:gsub('%+', '-')
var = var:gsub('[ |%-|\n]', '|%1')
--reaper.ShowConsoleMsg(var)

sep = "|"
test = var:split(sep)

-- INIT
note_sel = 0
events = {}

function main()

  local item_num = reaper.CountTrackMediaItems(track)

  -- ACTIONS
  for j = 0, item_num-1 do
    local item = reaper.GetTrackMediaItem(track, j)
    local take = reaper.GetActiveTake(item)
    if take and reaper.TakeIsMIDI( take ) then

      local retval, notes, ccs, sysex = reaper.MIDI_CountEvts(take)
      -- GET SELECTED NOTES (from 0 index)
      for k = 0, notes-1 do
        local retval, sel, muted, startppqposOut, endppqposOut, chan, pitch, vel = reaper.MIDI_GetNote(take, k)
          table.insert(events, reaper.MIDI_GetProjTimeFromPPQPos( take, startppqposOut ) )
      end
    end
  end -- ENFIF Take is MIDI

  str = '' -- "1.1.2\tLyric\t2.1.1\tLyric"
  for i, pos in ipairs( events ) do
  lyric = "bla"
  if test[i] then lyric = test[i] end
  console = true
  lyric = lyric:gsub('\n', '') -- Maybe not necessary
  str = str .. reaper.format_timestr_pos( pos, '', 1 ) .. '\t' .. lyric ..'\t'
  end
  str = str:sub(1, -2)
  reaper.SetTrackMIDILyrics( track, 2, str )

end

reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

reaper.PreventUIRefresh(1)

main() -- Execute your main function

reaper.UpdateArrange() -- Update the arrangement (often needed)

reaper.PreventUIRefresh(-1)

reaper.Undo_EndBlock("Insert UltraStar lyrics from project to items MIDI notes on first selected track", 0) -- End of the undo block. Leave it at the bottom of your main function.
