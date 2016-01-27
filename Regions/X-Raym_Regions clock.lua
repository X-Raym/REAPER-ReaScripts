--[[
 * ReaScript Name: Region's Clock
 * Description: Add a clock for regions, based on Play Cursor position.
 * Instructions: Run
 * Screenshot: http://i.giphy.com/3o85xpylrlY7MPzmo0.gif
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI:
 * Licence: GPL v3
 * Forum Thread:   EEL: Clock (shows project time)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=155542
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.1.2
--]]
 
--[[
 * Changelog:
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

--// -------------------- END OF USER CONFIG AREA 

--// INITIAL VALUES //--
font_size = 40
font_name = "Arial"
window_w = 640
window_h = 270
format = 0

--// COLOR FUNCTIONS //--
function INT2RGB(color_int)
  if color_int >= 0 then
      R = color_int & 255
      G = (color_int >> 8) & 255
      B = (color_int >> 16) & 255
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
function init(window_w, window_h)
  gfx.init("Region's Clock by X-Raym" , window_w, window_h)
  gfx.setfont(1, font_name, font_size, 'b')
  --color(text_color)
end

--// MAIN //--
function run()
  
  DrawBackground()
  
  -- PLAY STATE
  play_state = reaper.GetPlayState()
  if play_state == 0 then play_pos = reaper.GetCursorPosition() else play_pos = reaper.GetPlayPosition() end
  
  -- IS REGION
  marker_idx, region_idx = reaper.GetLastMarkerAndCurRegion(0, play_pos)
  if region_idx >= 0 then -- IF LAST REGION
    
    retval, is_region, region_start, region_end, region_name, markrgnindexnumber, region_color = reaper.EnumProjectMarkers3(0, region_idx)
    buf = play_pos - region_start
    buf = reaper.format_timestr_pos(buf, "", format)
    end_buf = region_end - play_pos
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
  if gfx.getchar() ~= 27 then reaper.defer(run) else gfx.quit() end

end -- END DEFER


-- RUN
init(window_w, window_h)
run()
