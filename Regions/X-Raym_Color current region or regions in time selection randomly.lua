--[[
 * ReaScript Name: Color current region or regions in time selection randomly
 * Screenshot: https://i.imgur.com/DBqWE6Y.gifv
 * Author: X-Raym
 * Author URI: htt://www.extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Forum Thread: Scripts: Regions and Markers (various)
 * Forum Thread URI: https://forum.cockos.com/showthread.php?p=1670961
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2020-01-31)
  + Initial Release
--]]

-- USER CONFIG AREA -----------------------------------------------------------

console = false -- true/false: display debug messages in the console

------------------------------------------------------- END OF USER CONFIG AREA
local reaper = reaper
math.randomseed( reaper.time_precise() )
hue = math.random( 360 ) / 360
saturation = 0.5
luminosity = 0.5

regions = {}

-- UTILITIES -------------------------------------------------------------

-- Display a message in the console for debugging
function Msg(value)
  if console then
    reaper.ShowConsoleMsg(tostring(value) .. "\n")
  end
end

function SaveRegions( start_pos, end_pos )
  local i=0
  repeat
    local iRetval = SaveRegion( i, start_pos, end_pos )
    i = i+1
  until iRetval == 0
end

function SaveRegion( i, start_pos, end_pos )
  local iRetval, bIsrgnOut, iPosOut, iRgnendOut, sNameOut, iMarkrgnindexnumberOut, iColorOur = reaper.EnumProjectMarkers3(0,i)
  if iRetval >= 1 then
    if bIsrgnOut and iPosOut >= start_pos and iRgnendOut <= end_pos then
      local region = {}
      region.pos_start = iPosOut
      region.pos_end = iRgnendOut
      region.color = iColorOur -- In case field is only $blank to clear
      region.name = sNameOut
      region.idx = iMarkrgnindexnumberOut
      table.insert( regions, region )
    end
  end
  return iRetval
end

-- COLORS -------------------------------------------------------------

-- From https://github.com/EmmanuelOga/columns/blob/master/utils/color.lua

function hue2rgb(p, q, t)
  if t < 0   then t = t + 1 end
  if t > 1   then t = t - 1 end
  if t < 1/6 then return p + (q - p) * 6 * t end
  if t < 1/2 then return q end
  if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
  return p
end

--[[
 * Converts an RGB color value to HSL. Conversion formula
 * adapted from http://en.wikipedia.org/wiki/HSL_color_space.
 * Assumes r, g, and b are contained in the set [0, 255] and
 * returns h, s, and l in the set [0, 1].
 *
 * @param   Number  r       The red color value
 * @param   Number  g       The green color value
 * @param   Number  b       The blue color value
 * @return  Array           The HSL representation
]]
function rgbToHsl(r, g, b, a)
  r, g, b = r / 255, g / 255, b / 255

  local max, min = math.max(r, g, b), math.min(r, g, b)
  local h, s, l

  l = (max + min) / 2

  if max == min then
    h, s = 0, 0 -- achromatic
  else
    local d = max - min
    if l > 0.5 then s = d / (2 - max - min) else s = d / (max + min) end
    if max == r then
      h = (g - b) / d
      if g < b then h = h + 6 end
    elseif max == g then h = (b - r) / d + 2
    elseif max == b then h = (r - g) / d + 4
    end
    h = h / 6
  end

  return h, s, l, a or 255
end

--[[
 * Converts an HSL color value to RGB. Conversion formula
 * adapted from http://en.wikipedia.org/wiki/HSL_color_space.
 * Assumes h, s, and l are contained in the set [0, 1] and
 * returns r, g, and b in the set [0, 255].
 *
 * @param   Number  h       The hue
 * @param   Number  s       The saturation
 * @param   Number  l       The lightness
 * @return  Array           The RGB representation
]]
function hslToRgb(h, s, l, a)
  local r, g, b

  if s == 0 then
    r, g, b = l, l, l -- achromatic
  else

    local q
    if l < 0.5 then q = l * (1 + s) else q = l + s - l * s end
    local p = 2 * l - q

    r = hue2rgb(p, q, h + 1/3)
    g = hue2rgb(p, q, h)
    b = hue2rgb(p, q, h - 1/3)
  end
  r = math.floor((r * 255) + 0.5)
  g = math.floor((g * 255) + 0.5)
  b = math.floor((b * 255) + 0.5)
  return r, g, b, a * 255
end

function RGB2INT ( R, G, B )
  local color = (R + 256 * G + 65536 * B)|16777216
  return color
end
--------------------------------------------------------- END OF UTILITIES
function GetRandomColor()
  hue = hue + 137 / 360
  if hue > 1 then hue = hue - 1 end
  local R, G, B, A = hslToRgb( hue, saturation, luminosity, 1 )
  Msg("\nR = " .. R .. "\nG = " .. G ..  "\nB = " .. B)
  local color_int = RGB2INT( R, G, B )
  return color_int
end

-- Main function
function main()

  for z, region in ipairs(regions) do
    local color = GetRandomColor()
    reaper.SetProjectMarker3( 0, region.idx, true, region.pos_start, region.pos_end, region.name, color )
  end

end


-- INIT -------------------------------------------------------------
--
-- GET TIME SELECTION
start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)

-- IF TIME SELECTION
if start_time ~= end_time then
  SaveRegions(start_time, end_time)
else
  cur_pos = reaper.GetCursorPosition()
  marker_idx, region_idx = reaper.GetLastMarkerAndCurRegion( 0, cur_pos )
  local iRetval, bIsrgnOut, iPosOut, iRgnendOut, sNameOut, iMarkrgnindexnumberOut, iColorOur = reaper.EnumProjectMarkers3(0,region_idx)
  if iRetval >= 1 then
    SaveRegion(region_idx, iPosOut, iRgnendOut)
  end
end


if #regions > 0 then

    reaper.PreventUIRefresh(1)

    reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

    reaper.ClearConsole()
    
    main()
    
    reaper.Undo_EndBlock("Color current region or regions in time selection randomly", -1) -- End of the undo block. Leave it at the bottom of your main function.

    reaper.UpdateArrange()
    
    reaper.UpdateTimeline()

    reaper.PreventUIRefresh(-1)

end
