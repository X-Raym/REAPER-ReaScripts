--[[
 * ReaScript Name: Region's Clock
 * Description: Add a clock for regions, based on Play Cursor position.
 * Instructions: Run
 * Screenshot: http://i.giphy.com/3o85xpylrlY7MPzmo0.gif
 * Author: X-Raym
 * Author URl: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URl: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URl:
 * Licence: GPL v3
 * Forum Thread:   EEL: Clock (shows project time)
 * Forum Thread URl: http://forum.cockos.com/showthread.php?t=155542
 * REAPER: 5.0
 * Extensions: None
 --]]
 
--[[
 * Changelog:
 * v1.0 (2015-09-24)
  + Initial Release
 --]]

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
  fontsizefith=(gfx.h/(str_h+50))*100 -- new font size needed to fit in vertical.
  
  font_size =  math.min(fontsizefit,fontsizefith)
  gfx.setfont(1, font_name, font_size) 
  
  str_w, str_h = gfx.measurestr(string)
  gfx.x = gfx.w/2-str_w/2
  gfx.y = gfx.y
end

function PrintAndBreak(string)
  CenterAndResizeText(string)

  rgba(255, 255, 255, 255)
  gfx.printf(string)
  gfx.y = gfx.y + font_size
end

--// INIT //--
function init(window_w, window_h)
  gfx.init("Region's Clock by X-Raym" , window_w, window_h)
  gfx.setfont(1, font_name, font_size, 'b')
  rgba( 255, 255, 255 )
end

--// MAIN //--
function run()
  
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
    if gfx.mouse_y < rect_h then
      reaper.SetEditCurPos(region_start, false, true)
    else
      reaper.Main_OnCommand(40616, 0)
    end
  end
  
  -- DRAW  
  if is_region == true then
     DrawProgressBar()
     PrintAndBreak(buf)
     PrintAndBreak(region_name)
  else
     PrintAndBreak("No Region")
     PrintAndBreak("Under Play Cursor")
  end    
  
  gfx.update()
  if gfx.getchar() ~= 27 then reaper.defer(run) else gfx.quit() end

end -- END DEFER


-- RUN
init(window_w, window_h)
run()
