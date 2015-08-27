--[[
 * ReaScript Name: GFX - Word Wrap
 * Description: See title
 * Instructions: Select an item. Use it.
 * Author: X-Raym
 * Author URl: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URl: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URl: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Lua Code Snippet: Text - String Word Wrap for GFX
 * Forum Thread URl: http://forum.cockos.com/showthread.php?t=163063
 * REAPER: 5.0 pre 36
 * Extensions: SWS/S&M 2.7.1 #0
 --]]
 
--[[
 * Changelog:
 * v0.5 (2015-06-16)
  + Beta
 --]]
 
--[[
 * To do:
  * clickable scrollbar
  * bug fix scroll bar heigth
  * navigation with arrow key
]]

font_size = 30
font_name = "Arial"
window_w = font_size * 16
window_h = font_size * 9
marge = font_size
--indentation = 100 -- for paragraph first line
line_height = font_size + font_size/5 -- is there a better way ?
done = false -- prevent calculation from script launch, but start at first click
times = {}
z = 0


function init(window_w, window_h)
  gfx.init("X-Raym's Word Wrap" , window_w, window_h)
  gfx.setfont(1, font_name, font_size, 'b')
  
  color(1)
  line = 0      
  gfx.x = marge
  gfx.y = line_height
  line_offset = 0
  
end


----- MOUSE WHEEL ZOOM ----------------------------
-- From PlanetNine EEL Item Marker Tool beta0.17 
-- === adjust font, window size, and nudge frames upon mousewheel change ===
function getMousewheel(mouse_wheel_val)
  
  -- IF CTRL => font-size
  if gfx.mouse_cap == 4 then
    
    if mouse_wheel_val > 0 then
      if font_size < 180 then
        font_size = font_size + 1
        line_height = font_size + font_size/5
      end
     end
      
    if mouse_wheel_val < 0 then
      if font_size > 10 then
        font_size = font_size - 1
        line_height = font_size + font_size/5
      end
    end
    
    gfx.setfont(1, font_name, font_size)
    gfx.mouse_wheel = 0 -- reset parameter before reusing...
    
  end -- ENDIF CTRL => font-size
  
  -- SCROLL WITH MOUSE WHEEL
  if gfx.mouse_cap == 0 then
          
    -- stop content at line 0 when scrolling up
    if gfx.y > 0 then
      line_offset =  math.floor(mouse_wheel_val/120)
    else
      line_offset = 0
      gfx.mouse_wheel = 0
    end
    line = line + line_offset -- wheel increment by 120
   
    -- Stop content at line 0 when scrolling upn
    if line >= 0 then 
      line = 0
      line_offset = 0
      gfx.mouse_wheel = 0 
    end
        
  end -- IF maj => scroll
    
end

----- WORD WRAP -----------------------------------
-- thanks to Bomb Bloke
-- http://www.computercraft.info/forums2/index.php?/topic/15790-modifying-a-word-wrapping-function/

local function splitWords(Lines, limit)
    while #Lines[#Lines] > limit do
        Lines[#Lines+1] = Lines[#Lines]:sub(limit+1)
        Lines[#Lines-1] = Lines[#Lines-1]:sub(1,limit)
    end
end

local function wrap(str, limit)
    local Lines, here, limit, found = {}, 1, limit or 72, str:find("(%s+)()(%S+)()")

    if found then
        Lines[1] = string.sub(str,1,found-1)  -- Put the first word of the string in the first index of the table.
    else Lines[1] = str end

    str:gsub("(%s+)()(%S+)()",
        function(sp, st, word, fi)  -- Function gets called once for every space found.
            splitWords(Lines, limit)

            if fi-here > limit then
                here = st
                Lines[#Lines+1] = word                                             -- If at the end of a line, start a new table index...
            else Lines[#Lines] = Lines[#Lines].." "..word end  -- ... otherwise add to the current table index.
        end)

    splitWords(Lines, limit)

    return Lines
end

---------------------------------------------------
function stringWrap (text, margin_b, margin_l, margin_r)
-- str, pixel, pixel, line
  
  text = tostring(text)
  
  if indent ~= nil then text = string.rep(" ", indent) .. text end -- doesnt work with space cause space are break bu the function
  str_width, str_height = gfx.measurestr(text)
  
  if margin_l == nil then margin_l = marge end
  if margin_r == nil then margin_r = marge end
  gfx.x = margin_l
  
  text_width = str_width + margin_r + margin_l
  
  newLine()
  gfx.x = margin_l
  
  if text_width > gfx.w then
  
    color(1)
        
    m_width, m_height = gfx.measurestr("s")
    char_max = math.floor( (gfx.w - margin_r - margin_l) / m_width )
    
    myTable = wrap(text, char_max)
   
    local i
    for i=1, #myTable do 
      gfx.printf(tostring(myTable[i]), line)
      newLine()
      gfx.x = margin_l
    end
  
    line = line - 1
  
  else
    
    color(2)
    gfx.printf(text, line)
  
  end
  
  line = line - 1
  
  if margin_b == nil then margin_b = 1 end
  if margin_b >= 1 then
    newLine(margin_b)
  end
  
end

function rgba(r, g, b, a)
  if a ~= nil then 
    gfx.a = a 
  else
    a = 1
  end
  gfx.r = r/255
  gfx.g = g/255
  gfx.b = b/255
end

function color(col)
  if col == 1 then rgba(255, 255, 16) end
  if col == 2 then rgba(255, 255, 255) end
end

function newLine(number)
  gfx.x = marge
  
  if number == nil then number = 1 end
  line = line + number
  gfx.y = line * line_height
end

function scrollBar()
  newLine()
  
  doc_height = gfx.y - (line_offset * line_height)
  
  -- draw bar background
  gfx.rect(gfx.w-20,0,20,gfx.h,rgba(128,128,128,1))
  
  -- draw scrollbar
  scrollbar_height = gfx.h/(doc_height/gfx.h)
  
  doc_height_lines = doc_height / line_height
  last_visible_line = doc_height_lines + line_offset
  scrollbar_position_line = doc_height_lines - last_visible_line 
  scrollbar_position = gfx.h/(doc_height_lines / scrollbar_position_line)
  
  gfx.rect(gfx.w-20, scrollbar_position,20,scrollbar_height ,rgba(0,0,0,0.5))
  --if mouse_cap == 1 and gfx.mouse_x >= gfx.w20-20 and gfx.mouse.y > scrollbar_position and gfx.mouse_y < scrollbar_position + scrollbar_position then
  --else = truc de base
  --end
end

function average(matrix)
  local sum = 0
  for i, cell in ipairs(matrix) do
    sum = sum + cell
  end
  sum = sum / #matrix
  return sum
end

function durationToBpm(duration)
  local bpm = 60 / duration
  return bpm
end

function run()  
  
  line = 0
  if line_offset == nil then line_offset = 0 end
  char = gfx.getchar()
  
  -- Scroll with arrow
  if char == 30064 then 
    line_offset = line_offset + 1
    line = line + line_offset -- wheel increment by 120
  end
  if char == 1685026670 then
    line_offset = line_offset - 1
    line = line + line_offset -- wheel increment by 120 
  end
  
  if gfx.mouse_wheel ~= 0 then getMousewheel(gfx.mouse_wheel) end
  
  ----- BASIC TEXT DISPLAY ---
  --stringWrap(text1, 1, 50, 50)
  --stringWrap(text2, 1)
    
  if done == false then clock = os.clock() end  
  
  if gfx.mouse_cap == 1 then engaged = true end

  if gfx.mouse_cap == 0 and engaged == true then
    z = z + 1
    if z > 10 then z = 1 end
    cal = os.clock() - clock
    times[z] = os.clock() - clock
    clock = os.clock()
    engaged = false
    done = true
  end
  
  text = average(times)
  
  stringWrap(durationToBpm(text))
  
  --stringWrap("Last Logs:")
  --for i = 1, #times do
    --stringWrap(times[i])
  --end
  ----------------------------- 
  
  scrollBar()
  
  gfx.update()
  
  if char == 27 then gfx.quit() end -- esc to quit
  if char >= 0 then reaper.defer(run) end

end
  
text1 = "Word-Wrap:"
text2 = "A simple but powerful feature that will be very useful in a lot of GFX scripts !"
text3 = "In sagittis cursus velit sit amet porta. Sed eget bibendum dolor, eu ornare nisi. Donec ultrices, dui quis varius tempor, sem ex fermentum nulla, id faucibus felis velit sit amet lorem. Aliquam erat volutpat. Cras vel elementum ipsum, et ultrices libero. Phasellus condimentum imperdiet libero ac dictum. Sed consectetur nec nisi at hendrerit. Mauris efficitur libero et libero tincidunt, et lobortis ipsum mattis. In ut orci a nibh aliquet vehicula at nec enim. Donec nec dui id lectus elementum accumsan gravida eu risus. Phasellus viverra ornare justo id venenatis. Nunc semper in justo ut mattis. ."

-------------------

init(window_w, window_h)
run()
