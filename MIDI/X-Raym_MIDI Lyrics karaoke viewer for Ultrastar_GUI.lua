--[[
 * ReaScript Name: MIDI Lyrics karaoke viewer for Ultrastar_GUI
 * About: Add a clock based on Lyrics tracks MIDI Lyrics events. It use Markers to determine Lines of the karaoke.
 * Screenshot: https://i.imgur.com/VnImxoP.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Creating Karaoke Songs for UltraStar and Vocaluxe
 * Forum Thread URI: https://forum.cockos.com/showthread.php?t=202430
 * REAPER: 5.0
 * Version: 1.0.4
--]]

--[[
 * Changelog:
 * v1.0.4 (2023-02-27)
  + Ignore out of items boundaries events
 * v1.0.3 (2023-02-21)
  + Ignore muted MIDI events
 * v1.0 (2023-02-10)
  + Error message correction
 * v1.0 (2023-02-09)
  + Initial Release
--]]

-----------------------------------------------------------
-- USER CONFIG AREA --
-----------------------------------------------------------

text_color = "White" -- support names (see color function) and hex values with #
background_color = "#333333" -- support names and hex values with #. REAPER defaults are dark grey #333333 and brigth grey #A4A4A4
no_lyrics_track_text = true -- set to false to desactivate "NO REGIONS UNDER PLAY CURSOR" instructions
console = true -- Display debug messages in the console

color_highlight = "Teal"

-----------------------------------------------------------
                              -- END OF USER CONFIG AREA --
-----------------------------------------------------------

-----------------------------------------------------------
-- GLOBALS --
-----------------------------------------------------------

font_size = 40
font_name = "Arial"
format = 0

vars = {}
vars.wlen = 640
vars.hlen = 270
vars.docked = 0
vars.xpos = 100
vars.ypos = 100

ext_name = "XR_MidiLyricsKaraokeViewer"

colors = {
  white = "#FFFFFF",
  silver = "#C0C0C0",
  gray = "#808080",
  black = "#000000",
  red = "#FF0000",
  maroon = "#800000",
  yellow = "#FFFF00",
  olive = "#808000",
  lime = "#00FF00",
  green = "#008000",
  aqua = "#00FFFF",
  teal = "#008080",
  blue = "#0000FF",
  navy = "#000080",
  fuchsia = "#FF00FF",
  purple = "#800080",
  orange = "#ffa500",
  trombone = "#DAA520",
}

-- Performance
local reaper = reaper

-----------------------------------------------------------
-- DEBUG --
-----------------------------------------------------------

function Msg(value)
  if console then
    reaper.ShowConsoleMsg(tostring(value) .. "\n")
  end
end

-----------------------------------------------------------
-- STATES --
-----------------------------------------------------------

function SaveState()
  vars.docked, vars.xpos, vars.ypos, vars.wlen, vars.hlen = gfx.dock(-1, 0, 0, 0, 0)
  for k, v in pairs( vars ) do
    SaveExtState( k, v )
  end
end

function SaveExtState( var, val)
  reaper.SetExtState( ext_name, var, tostring(val), true )
end

function GetExtState( var, val )
  if reaper.HasExtState( ext_name, var ) then
    local t = type( val )
    val = reaper.GetExtState( ext_name, var )
    if t == "boolean" then val = toboolean( val )
    elseif t == "number" then val = tonumber( val )
    else
    end
  end
  return val
end

function GetExtStates()
  for k, v in pairs(vars) do
     vars[k] = GetExtState( k, v )
  end
end

-----------------------------------------------------------
-- TABLE --
-----------------------------------------------------------

function TableMergeNew(...)
  local out = {}
  for i, t in ipairs{...} do
    for k,v in ipairs(t) do
      table.insert(out, v)
    end
  end
  return out
end

-----------------------------------------------------------
-- MATHS --
-----------------------------------------------------------

function MapLinear (num, in_min, in_max, out_min, out_max)
  return (num - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

function IsInTime( s, start_time, end_time )
  if s >= start_time and s <= end_time then return true end
  return false
end

function IsInTimeSelection2( s, e, start_time, end_time )
  if (s >= start_time and s < end_time) or (e > start_time and e <= end_time) or (s<=start_time and e >= end_time) then return true end
  return false
end

-----------------------------------------------------------
-- UTILITIES --
-----------------------------------------------------------

function GetLyricsTrack()
  local count_tracks = reaper.CountTracks( 0 )
  for i = 0, count_tracks - 1 do
    local track = reaper.GetTrack( 0, i )
    local r, track_name = reaper.GetTrackName( track )
    if track_name == "Lyrics" then
      return track
    end
  end
end

-----------------------------------------------------------
-- COLORS --
-----------------------------------------------------------

function INT2RGB(color_int)
  if color_int >= 0 then
      R, G, B = reaper.ColorFromNative(color_int)
  else
      R, G, B = 255, 255, 255
  end
  rgba(R, G, B, 255)
end

function rgba(r, g, b, a)
  if a ~= nil then gfx.a = a/255 else a = 255 end
  gfx.r = r/255
  gfx.g = g/255
  gfx.b = b/255
end

function HexToRGB(value)
  local hex = value:gsub("#", "")
  gfx.r = (tonumber("0x"..hex:sub(1,2)) or 0) / 255
  gfx.g = (tonumber("0x"..hex:sub(3,4)) or 0) / 255
  gfx.b = (tonumber("0x"..hex:sub(5,6)) or 0) / 255
end

function color(col)
  if string.find(col, "#.+") ~= nil then
    color2 = col
    HexToRGB(color2)
  end
  if colors[col:lower()] then
    HexToRGB( colors[col:lower()] )
  end
end

-----------------------------------------------------------
-- DRAW --
-----------------------------------------------------------

function PrintAndBreak(string, col)
  CenterAndResizeText(string)
  if col then
    color( col )
  else
    color(text_color)
  end
  gfx.drawstr(string)
  gfx.y = gfx.y + font_size
end

function CenterAndResizeText(string)
  gfx.setfont(1, font_name, 100)

  local str_w, str_h = gfx.measurestr(string)
  local fontsizefit=(gfx.w/(str_w+50))*100 -- new font size needed to fit.
  local fontsizefith=((gfx.h-gfx.y)/(str_h+50))*100 -- new font size needed to fit in vertical.

  local font_size =  math.min(fontsizefit,fontsizefith)
  gfx.setfont(1, font_name, font_size)

  local str_w, str_h = gfx.measurestr(string)
  gfx.x = gfx.w/2-str_w/2
  gfx.y = gfx.h/2-str_h/2
  return str_w, str_h, font_size
end

function DrawBackground()
  color(background_color)
  gfx.rect( 0, 0, gfx.w, gfx.h )
end

function DrawLine( line, index )

  -- Concat Line
  str = {}
  for i, syllab in ipairs( line ) do
    table.insert( str, syllab.msg )
  end
  str = table.concat( str )
  
  gfx.x = 0; gfx.y = 0;
  
  color( color_highlight )
  
  -- Mesure Line
  -- + set font so it fit the screen
  -- + get the XY positions
  local w_text, h_text, font_size = CenterAndResizeText(str) -- x and Y are in gfx variable
  local text_x = gfx.x
  local text_y = gfx.y
  
  if font_size < 10 then
    PrintAndBreak("Too Many Words", "RED")
    return
  end
  
  --gfx.printf( str )
  -- Draw Line Syllabls per Syllabls
  -- to keep track of each syllabs position
  -- for the progress rectangle
  gfx.a = 0.1
  --rectangle_w = MapLinear(play_pos, line.line_start, line.line_end, gfx.x, gfx.x + w_text)
  --gfx.rect( gfx.x, 0, rectangle_w - gfx.x, gfx.h )
  gfx.a = 1
  syllabs_w = 0
  syllab_end_time = 0
  current_syllab = nil
  previous_x = text_x
  rectangle_w = 0
  for i, syllab in ipairs( line ) do
    if play_pos >= syllab.pos_start then -- passed or current syllab
      color( color_highlight )
    else
      color( "White" )
    end
    
    if IsInTime( play_pos, syllab.pos_start, syllab.pos_end ) then
      syllab_w, syllab_h = gfx.measurestr( syllab.msg )
      --syllabs_w = syllabs_w + syllab_w
      current_syllab = syllab
      
      color( color_highlight )
      rectangle_w = MapLinear(play_pos, syllab.pos_start, syllab.pos_end, 0, syllab_w)
      --gfx.rect( gfx.x, gfx.h - 20, rectangle_w, 20 )
      gfx.a = 1
    end
    gfx.printf( syllab.msg )
    if play_pos > syllab.pos_end then
      syllab_w, syllab_h = gfx.measurestr( syllab.msg )
      previous_x = gfx.x
    end
  end
  
  -- Draw the rectangle 
  color( color_highlight )
  local rectangle_w_2 = previous_x - text_x + (rectangle_w or 0)
  local h = 10
  gfx.rect(  text_x, gfx.h - h, rectangle_w_2, h )
  gfx.a = 0.05
  gfx.rect(  text_x, 0, rectangle_w_2, gfx.h )
  gfx.a = 1
  gfx.rect(  text_x, 0, rectangle_w_2, h )
end

-----------------------------------------------------------
-- PROCESS --
-----------------------------------------------------------

function ProcessMarkers()

  local markers = {}

  -- LOOP THROUGH REGIONS
  local count_markers_regions, num_markers, num_regions = reaper.CountProjectMarkers( 0 )
  for i = 0, count_markers_regions - 1 do
    local iRetval, bIsrgnOut, iPosOut, iRgnendOut, sNameOut, iMarkrgnindexnumberOut, iColorOur = reaper.EnumProjectMarkers3(0,i)
    if iRetval >= 1 then
      if not bIsrgnOut and sNameOut == "" then
        table.insert(markers, { pos = iPosOut, name = sNameOut } )
      end
      i = i+1
    end
  end
  
  -- Allow to not notes before first marker
  if #markers > 0 and markers[1].pos > 0 then
    table.insert( markers, 1, {pos = 0} )
  end

  return markers
end

function ProcessTakeMIDI( take, item )

  local retval, count_notes, count_ccs, count_textsyx = reaper.MIDI_CountEvts( take )
  if count_notes == 0 or count_textsys == 0 then return end
  
  local item_pos = reaper.GetMediaItemInfo_Value( item, "D_POSITION" )
  local item_len = reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )
  local item_end = item_pos + item_len
  
  local notes_end_by_pos = {}
  for i = 0, count_notes - 1 do
    local retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote( take, i )
    local note_start_pos = reaper.MIDI_GetProjTimeFromPPQPos( take, startppqpos )
    local note_end_pos = reaper.MIDI_GetProjTimeFromPPQPos( take, endppqpos )
    if not muted and IsInTimeSelection2( note_start_pos, note_end_pos, item_pos, item_end ) then
      note_start_pos = (note_start_pos < item_pos and item_pos) or note_start_pos
      --startppqpos = reaper.MIDI_GetPPQPosFromProjTime( take, note_start_pos ) -- TOFIX: if note start is before item start.
      note_end_pos = (note_end_pos > item_end and item_end) or note_end_pos
      notes_end_by_pos[startppqpos] = note_end_pos
    end
  end

  -- First Filter Text Event by Lyrics
  local take_lyrics = {}
  local text_evts_ppq = {} -- for debug
  for i = 0, count_textsyx - 1 do
    local retval, selected, muted, ppqpos, evt_type, msg = reaper.MIDI_GetTextSysexEvt( take, i, true, true, 0, 0, "" )
    if evt_type == 5 and not muted then
      msg = msg:gsub("\r", "")  -- remove carriage return
      msg = msg:gsub("^%-", "") -- remove hyphen at the begining
      if strip_spaces_and_tilds then
        msg = msg:gsub("%s+", "") -- remove space characters
        msg = msg:gsub("~", "")   -- remove tildes
      end
      text_evts_ppq[ppqpos] = msg
      if msg:len()==0 then msg = "~" end
      local evt_pos = reaper.MIDI_GetProjTimeFromPPQPos( take, ppqpos )
      if notes_end_by_pos[ppqpos] and IsInTime( evt_pos, item_pos, item_end ) then
        table.insert(take_lyrics,{ pos_start = evt_pos, msg = msg, pos_end = notes_end_by_pos[ppqpos] })
      end
    end
  end
  return take_lyrics
end

function Process( markers, lyrics )
  -- Get table pages and its notes
  local lines = {}
  local last_lyric = 1
  local has_been_created = 0
  for i = 1, #markers - 1 do
    local marker = markers[i]
    for j = last_lyric, #lyrics do
      local lyric = lyrics[j]
      if IsInTime( lyric.pos_start, marker.pos, markers[i+1].pos ) then
        if i ~= has_been_created then
          table.insert( lines, { line_start = marker.pos, line_end = markers[i+1].pos } )
          has_been_created = i
        end
        table.insert( lines[#lines], lyric )
      end
      if lyric.pos_start > markers[i+1].pos then
        last_lyric = j
        break
      end
    end
  end
  
  return lines
end

function GetLineFromPos( lines, pos )
  for i, line in ipairs( lines ) do
    if IsInTime( pos, line.line_start, line.line_end ) then
      return line, i
    end
  end
  if #lines == 0 or pos > lines[#lines].line_end then
    return nil, nil, "The END: No Marker or Lyrics Beyond"
  end
end

-----------------------------------------------------------
-- MAIN --
-----------------------------------------------------------

function Run()

  DrawBackground()

  -- PLAY STATE
  play_state = reaper.GetPlayState()
  if play_state == 0 then play_pos = reaper.GetCursorPosition() else play_pos = reaper.GetPlayPosition() end
  
  -- GET MARKERS
  markers = ProcessMarkers()
  
  local lyrics = {}
  track = (track and reaper.ValidatePtr( track, 'MediaTrack*' ) and track) or GetLyricsTrack()
  if track then
    count_track_items = reaper.CountTrackMediaItems( track )
    for i = 0, count_track_items - 1 do
      item = reaper.GetTrackMediaItem( track, i )
      take = reaper.GetActiveTake( item )
      if take and reaper.TakeIsMIDI( take ) then
        lyrics = TableMergeNew( lyrics, ProcessTakeMIDI( take, item ) )
      end
    end
    
    if #markers > 0 and #lyrics > 0 then
      lines = Process( markers, lyrics )
      if #lines > 0 then
        lines_to_draw_x = 0
        line_to_draw, line_to_draw_index, err = GetLineFromPos( lines, play_pos )
        if line_to_draw then
          DrawLine( line_to_draw, line_to_draw_index )
        end
        if err then
          PrintAndBreak( err, "RED" )
        end
      else
        if markers[#markers].pos < play_pos then
          PrintAndBreak(  "No Marker Beyond", "RED" )
        end
      end
    else
      if #markers == 0 then
        PrintAndBreak("No Markers", "RED")
      elseif #lyrics == 0 then
        PrintAndBreak("No Lyrics", "RED")
      end
    end
  end
  
  if gfx.mouse_cap == 2 and (not is_region or gfx.mouse_y < rect_h) then
    local dock = gfx.dock(-1) == 0 and "Dock" or "Undock"
    gfx.x = gfx.mouse_x
    gfx.y = gfx.mouse_y
    if gfx.showmenu( dock ) == 1 then
      if gfx.dock(-1) == 0 then gfx.dock(1) else gfx.dock(0) end
    end
  end

  if gfx.mouse_cap == 0 then mouse_state = 0 end

  -- Left clik return cursor at the begining of the region smooth seek
  if gfx.mouse_cap == 1 then
    if is_region then
      if gfx.mouse_y < rect_h then
        reaper.SetEditCurPos(region_start, false, true)
      else
        reaper.Main_OnCommand(40616, 0)
      end
    end
  end

  -- DRAW
  if not track then
    PrintAndBreak("No Lyrics Tracks", "RED")
  end

  gfx.update()

  char = gfx.getchar()
  if char == 32 then reaper.Main_OnCommand(40044, 0) end -- Space: play
  if char == 100 then if gfx.dock(-1) == 0 then gfx.dock(1) else gfx.dock(0) end end -- D
  if char == 27 or char == -1 then gfx.quit() else reaper.defer(Run) end

end -- END DEFER


-----------------------------------------------------------
-- INIT --
-----------------------------------------------------------

-- Set ToolBar Button State
function SetButtonState( set )
  local is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  reaper.SetToggleCommandState( sec, cmd, set or 0 )
  reaper.RefreshToolbar2( sec, cmd )
end

function Init()
  SetButtonState( 1 )
  GetExtStates()
  gfx.init("XR - MIDI Lyrics Clock" , vars.wlen, vars.hlen, vars.docked, vars.xpos, vars.ypos)  -- name,width,height,dockstate,xpos,ypos
  gfx.setfont(1, font_name, font_size, 'b')
  Run()
  reaper.atexit( DoExitFunctions )
end

function DoExitFunctions()
  SetButtonState( -1 )
  SaveState()
end

-----------------------------------------------------------
-- RUN --
-----------------------------------------------------------
if not preset_file_init then
  Init()
end
