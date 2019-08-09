--[[
 * ReaScript Name: Region's Clock
 * Description: Add a clock for regions, based on Play Cursor position.
 * Instructions: Run
 * Screenshot: http://i.giphy.com/3o85xpylrlY7MPzmo0.gif
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Regions and Markers (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=175819
 * REAPER: 5.0
 * Extensions: ../Functions/spk77_Save table to file and load table from file_functions.lua
 * Version: 1.2.3
--]]

--[[
 * Changelog:
 * v1.2.3 (2019-04-17)
  # Kill script if GUI closed
 * v1.2.2 (2019-04-17)
  # MacOS color fix
 * v1.2.1 (2017-03-17)
  + Project start offset support
 * v1.2 (2016-04-18)
  + Button states if action is in toolbar.
  + Save window state in an external file.
 * v1.1.2 (2016-01-27)
  + Dock the window via left click if there is no regions.
 * v1.1.1 (2016-01-19)
  # Prevent vertical truncation of the regions names
 * v1.1 (2015-09-25)
  + User config area
 * v1.0 (2015-09-24)
  + Initial Release
--]]


--// USER CONFIG AREA -->

text_color = "White" -- support names (see color function) and hex values with #
background_color = "#333333" -- support names and hex values with #. REAPER defaults are dark grey #333333 and brigth grey #A4A4A4
no_regions_text = true -- set to false to desactivate "NO REGIONS UNDER PLAY CURSOR" instructions
console = false -- Display debug messages in the console

--// -------------------- END OF USER CONFIG AREA


--// INITIAL VALUES //--
font_size = 40
font_name = "Arial"
format = 0

-- To Save in Preset filename
window_w = 640
window_h = 270

-- Performance
local reaper = reaper

-- DEBUG
function Msg(value)
  if console then
    reaper.ShowConsoleMsg(tostring(value) .. "\n")
  end
end


-- Set ToolBar Button ON
function SetButtonON()
 local is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
 local state = reaper.GetToggleCommandStateEx( sec, cmd )
 reaper.SetToggleCommandState( sec, cmd, 1 ) -- Set ON
 reaper.RefreshToolbar2( sec, cmd )
end


-- Set ToolBar Button OFF
function SetButtonOFF()
 local is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
 local state = reaper.GetToggleCommandStateEx( sec, cmd )
 reaper.SetToggleCommandState( sec, cmd, 0 ) -- Set OFF
 reaper.RefreshToolbar2( sec, cmd )
end


--// COLOR FUNCTIONS //--
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
  local R = tonumber("0x"..hex:sub(1,2))
  local G = tonumber("0x"..hex:sub(3,4))
  local B = tonumber("0x"..hex:sub(5,6))

  if R == nil then R = 0 end
  if G == nil then G = 0 end
  if B == nil then B = 0 end

  gfx.r = R/255
  gfx.g = G/255
  gfx.b = B/255

end


function color(col)
  if string.find(col, "#.+") ~= nil then
    color2 = col
    HexToRGB(color2)
  end
  if col == "White" then HexToRGB("#FFFFFF") end
  if col == "Silver" then HexToRGB("#C0C0C0") end
  if col == "Gray" then HexToRGB("#808080") end
  if col == "Black" then HexToRGB("#000000") end
  if col == "Red" then HexToRGB("#FF0000") end
  if col == "Maroon" then HexToRGB("#800000") end
  if col == "Yellow" then HexToRGB("#FFFF00") end
  if col == "Olive" then HexToRGB("#808000") end
  if col == "Lime" then HexToRGB("#00FF00") end
  if col == "Green" then HexToRGB("#008000") end
  if col == "Aqua" then HexToRGB("#00FFFF") end
  if col == "Teal" then HexToRGB("#008080") end
  if col == "Blue" then HexToRGB("#0000FF") end
  if col == "Navy" then HexToRGB("#000080") end
  if col == "Fuchsia" then HexToRGB("#FF00FF") end
  if col == "Purple" then HexToRGB("#800080") end
end


--// ELEMENTS //--
function DrawProgressBar() -- Idea from Heda's Notes Reader
  progress_percent = (play_pos-region_start)/region_duration
  rect_h = gfx.h/10

  INT2RGB(region_color)
  gfx.rect( 0, 0, gfx.w, rect_h )

  rgba( 255,255,255,200 )
  gfx.rect( 0, 0, gfx.w*progress_percent, rect_h )
  gfx.y = rect_h * 2
end


function CenterAndResizeText(string)
  gfx.setfont(1, font_name, 100)

  str_w, str_h = gfx.measurestr(string)
  fontsizefit=(gfx.w/(str_w+50))*100 -- new font size needed to fit.
  fontsizefith=((gfx.h-gfx.y)/(str_h+50))*100 -- new font size needed to fit in vertical.

  font_size =  math.min(fontsizefit,fontsizefith)
  gfx.setfont(1, font_name, font_size)

  str_w, str_h = gfx.measurestr(string)
  gfx.x = gfx.w/2-str_w/2
  gfx.y = gfx.y
end


function PrintAndBreak(string)
  CenterAndResizeText(string)

  color(text_color)
  gfx.printf(string)
  gfx.y = gfx.y + font_size
end


function DrawBackground()
  color(background_color)
  gfx.rect( 0, 0, gfx.w, gfx.h )
end


--// INIT //--
function init(window_w, window_h, window_x, window_y, docked)
  gfx.init("Region's Clock by X-Raym" , window_w, window_h, docked, window_x, window_y)  -- name,width,height,dockstate,xpos,ypos
  gfx.setfont(1, font_name, font_size, 'b')
  --color(text_color)
end


function DoExitFunctions()
  SetButtonOFF()
  SaveWindow()
end


function SaveWindow()
  docked, xpos, ypos, wlen, hlen = gfx.dock(-1, xpos, ypos, wlen, hlen)
  presets = {
             -- Preset 1
             regions_clock =
               {
                 docked = docked,
                 xpos = xpos,
                 ypos = ypos,
                 wlen = wlen,
                 hlen = hlen
               },
            }
  table.save(presets, presets_path) -- save "presets" table
end

--// MAIN //--
function run()

  offset = reaper.GetProjectTimeOffset( proj, false )

  DrawBackground()

  -- PLAY STATE
  play_state = reaper.GetPlayState()
  if play_state == 0 then play_pos = reaper.GetCursorPosition() else play_pos = reaper.GetPlayPosition() end

  -- IS REGION
  marker_idx, region_idx = reaper.GetLastMarkerAndCurRegion(0, play_pos)
  if region_idx >= 0 then -- IF LAST REGION

    retval, is_region, region_start, region_end, region_name, markrgnindexnumber, region_color = reaper.EnumProjectMarkers3(0, region_idx)
    buf = play_pos - region_start - offset
    buf = reaper.format_timestr_pos(buf, "", format)
    end_buf = region_end - play_pos - offset
    end_string = reaper.format_timestr_pos(end_buf, "", format)
    buf = buf .. " → " .. end_string
    region_duration = region_end - region_start
  else
    is_region = false
    gfx.y = 0
  end -- IF LAST REGION

  -- From SPK77's Clock script
  -- CHANGE FORMAT WITH A CLICK
  if mouse_state == 0 and gfx.mouse_cap == 2 and gfx.mouse_x > 5 and gfx.mouse_x < gfx.w - 5 and gfx.mouse_y > 5 and gfx.mouse_y < gfx.h - 5 then
    mouse_state = 1
   if format < 5 then format = format + 1 else format = 0 end
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
    else
      if gfx.dock(-1) == 0 then gfx.dock(1) else gfx.dock(0) end
    end
  end

  -- DRAW
  if is_region == true then
     DrawProgressBar()
     PrintAndBreak(buf)
     PrintAndBreak(region_name)
  else
     if no_regions_text then
       PrintAndBreak("No Region")
       PrintAndBreak("Under Play Cursor")
     end
  end

  gfx.update()
  
  char = gfx.getchar()
  if char == 27 or char == -1 then gfx.quit() else reaper.defer(run) end

end -- END DEFER


function get_script_path()
  local info = debug.getinfo(1,'S');
  local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
  return script_path
end

--// RUN //--

---------------------------------------------------
-- Get script path and create "presets.txt" file --
---------------------------------------------------

script_path = get_script_path()
presets_path = script_path .. "../X-Raym_Scripts presets.lua"

-- Get External File
dofile(script_path .. "../Functions/spk77_Save table to file and load table from file_functions.lua")

-- if "presets.txt" doesn't exist it will be created
if not reaper.file_exists(presets_path) then
  local file = io.open(presets_path, "w")
  io.close(file)

  -- Save presets according t
  presets = {
             -- Preset 1
             regions_clock =
               {
                 wlen = window_w,
                 hlen = window_h,
                 xpos = 0, -- will display at left.
                 ypos = 0, -- will display at bottom.
                 docked = 0
               },
            }
  table.save(presets, presets_path) -- save "presets" table

end

-- Restore regions_clock table
preset = table.load(presets_path).regions_clock -- load only the "other_preset" table

SetButtonON()
-- init(window_w, window_h, window_x, window_y, docked)
init(preset.wlen, preset.hlen, preset.xpos, preset.ypos, preset.docked)
run()
reaper.atexit( DoExitFunctions )
