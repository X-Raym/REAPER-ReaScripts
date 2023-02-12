--[[
 * ReaScript Name: Insert UltraStar lyrics from project to items MIDI notes on first selected track (background)
 * Instructions: Select atrack. Run. Supports both UltraStar Creator and YASS syntax.
 * Screenshot: https://i.imgur.com/Q7tOB47.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Creating Karaoke Songs for UltraStar and Vocaluxe with REAPER
 * Forum Thread URI: https://forum.cockos.com/showthread.php?t=202430
 * REAPER: 5.0
 * Version: 1.1
--]]

--[[
 * Changelog:
 * v1.1 (2023-02-11)
  + Background real time version of the script
 * v1.0.3 (2023-02-09)
  # replace SetTrackMIDILyrics with regular MIDI functions to avoid crash and be more precized
  # add markers at lyrics break line, removing existing unamed markers (deactivable in user config area)
 * v1.0.2 (2023-02-09)
  # disable snap MIDI if activated
 * v1.0.2 (2023-02-09)
  + Fallback to Lyrics tracks is no tracks selected
 * v1.0.1 (2018-02-03)
  # "+" pattern is fixed
 * v1.0 (2018-01-25)
  + Initial Release
--]]

-- USER CONFIG AREA ---------------------------------------

console = true
add_markers = true
delete_unamed_markers = true

------------------------------- END IOF USER CONFIG AREA --

function Msg(val)
  if console then
    reaper.ShowConsoleMsg(tostring( val ) .. "\n" )
  end
end

 -- Set ToolBar Button State
function SetButtonState( set )
  local is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  reaper.SetToggleCommandState( sec, cmd, set or 0 )
  reaper.RefreshToolbar2( sec, cmd )
end

function DeleteAllUnamedMarkers()
  local i=0
  repeat
    local iRetval, bIsrgnOut, iPosOut, iRgnendOut, sNameOut, iMarkrgnindexnumberOut, iColorOur = reaper.EnumProjectMarkers3(0,i)
    if iRetval >= 1 then
      if not bIsrgnOut and sNameOut == "" then
        reaper.DeleteProjectMarkerByIndex( 0, i )
        i = i - 1
      end
      i = i+1
    end
  until iRetval == 0
end

function GetSelectLyricsTrack()
  local count_tracks = reaper.CountTracks( 0 )
  for i = 0, count_tracks - 1 do
    local track = reaper.GetTrack( 0, i )
    local r, track_name = reaper.GetTrackName( track )
    if track_name:lower() == "lyrics" then
      reaper.SetOnlyTrackSelected( track )
      return track
    end
  end
end

-- Split CSV string
function string:split(sep)
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  self:gsub(pattern, function(c) fields[#fields+1] = c end)
  return fields
end

function Main()

  local item_num = reaper.CountTrackMediaItems(track)
  
  if delete_unamed_markers then DeleteAllUnamedMarkers() end

  -- ACTIONS
  txt_evt_idx = 1
  for j = 0, item_num-1 do
    local item = reaper.GetTrackMediaItem(track, j)
    local take = reaper.GetActiveTake(item)
    if take and reaper.TakeIsMIDI( take ) then

      local retval, notes, ccs, sysex = reaper.MIDI_CountEvts(take)

      -- Remove existing lyrics events
      for k = sysex-1, 0, -1 do
        local retval, selected, muted, ppqpos, msg_type, msg = reaper.MIDI_GetTextSysexEvt( take, k )
        if msg_type == 5 then
          reaper.MIDI_DeleteTextSysexEvt( take, k )
        end
      end
      
      -- GET SELECTED NOTES (from 0 index)
      for k = 0, notes-1 do
        local retval, sel, muted, startppqposOut, endppqposOut, chan, pitch, vel = reaper.MIDI_GetNote(take, k)
        if add_markers and test[txt_evt_idx] and test[txt_evt_idx]:find("\n") then
          reaper.AddProjectMarker( 0, false, reaper.MIDI_GetProjTimeFromPPQPos( take, startppqposOut-1 ), 0, "", -1 )
        end
        reaper.MIDI_InsertTextSysexEvt( take, sel, false, startppqposOut, 5, string.gsub(test[txt_evt_idx], "\n", " ") )
        txt_evt_idx = txt_evt_idx + 1
        if txt_evt_idx > #test then break end
        --table.insert(events, reaper.MIDI_GetProjTimeFromPPQPos( take, startppqposOut ) )
      end
    end
    if txt_evt_idx > #test then break end
  end -- ENFIF Take is MIDI
  
  --[[
  str = '' -- "1.1.2\tLyric\t2.1.1\tLyric"
  for i, pos in ipairs( events ) do
    lyric = "bla"
    if test[i] then lyric = test[i] end
    console = true
    lyric = lyric:gsub('\n', '') -- Maybe not necessary
    str = str .. reaper.format_timestr_pos( pos, '', 1 ) .. '\t' .. lyric ..'\t'
  end
  str = str:sub(1, -2)
  reaper.SetTrackMIDILyrics( track, 2, str )]]

end

function Run()
  var = reaper.GetSetProjectNotes( 0, false, '' )
  if not var or var == "" then return end
  
  var = var:gsub('%+', '-')
  var = var:gsub('[ |%-|\n]', '|%1')
  
  if reaper.GetSetProjectNotes( 0, false, '' ) ~= last_proj_notes then
  
    --Msg("DIFFERENT")
    
    sep = "|"
    test = var:split(sep)
    
    -- INIT
    note_sel = 0
    events = {}
    
    reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
    
    reaper.PreventUIRefresh(1)
    
    Main() -- Execute your main function
    
    reaper.UpdateArrange() -- Update the arrangement (often needed)
    
    reaper.PreventUIRefresh(-1)
    
    reaper.Undo_EndBlock("Insert UltraStar lyrics from project to items MIDI notes on first selected track", -1) -- End of the undo block. Leave it at the bottom of your main function.
  end
  --reaper.ShowConsoleMsg(var)
  
  last_proj_notes = reaper.GetSetProjectNotes( 0, false, '' )
  
  reaper.defer( Run )
end

track = reaper.GetSelectedTrack(0,0)

if not track then
  track = GetSelectLyricsTrack()
end

if not track then return end

SetButtonState( 1 )
Run()
reaper.atexit( SetButtonState )
