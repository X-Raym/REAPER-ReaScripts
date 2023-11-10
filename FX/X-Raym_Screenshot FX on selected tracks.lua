--[[
 * ReaScript Name: Screenshot FX on selected tracks
 * Author: X-Raym
 * Screenshot: https://i.imgur.com/QJ347SW.gif
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Taking screenshot of plugins
 * Forum Thread URI: https://forum.cockos.com/showthread.php?t=276329
 * REAPER: 6.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2023-09-11)
  + Initial Release
--]]

-----------------------------------------------------------
-- USER CONFIG AREA --
-----------------------------------------------------------

-- Use Preset Script for safe moding or to create a new action with your own values
-- https://github.com/X-Raym/REAPER-ReaScripts/tree/master/Templates/Script%20Preset

wait_time = 1 -- seconds between each screenshots

local os_sep = package.config:sub(1,1)
folder = reaper.GetProjectPath():gsub("Audio", "Screenshots") .. os_sep -- folder to save screenshots

-----------------------------------------------------------
                                   -- END OF CONFIG AREA --
-----------------------------------------------------------

-----------------------------------------------------------
-- GLOBALS --
-----------------------------------------------------------
-- count_fx = 3 -- debug: arbitrary limit
current_fx = -1

-----------------------------------------------------------
-- DEPENDENCIES --
-----------------------------------------------------------

if not reaper.JS_LICE_WritePNG then
  reaper.MB("Missing dependency: JS_reascriptAPI extension.\nDownload it via Reapack ReaTeam extension repository.\nSee Reapack.com for more infos.", "Error", 0)
  return false
end

-----------------------------------------------------------
-- MESSAGES --
-----------------------------------------------------------

function Msg( val )
  reaper.ShowConsoleMsg( tostring( val ) .. "\n" )
end

function Tooltip(message) -- DisplayTooltip() already taken by the GUI version
  local x, y = reaper.GetMousePosition()
  reaper.TrackCtl_SetToolTip( tostring(message), x+17, y+17, false )
end

-----------------------------------------------------------
-- DEFER --
-----------------------------------------------------------

function Exit()
  Tooltip("End of screenshots capture.")
end

-----------------------------------------------------------
-- MATHS --
-----------------------------------------------------------

function round( val, num )
  local mult = 10^(num or 0)
  if val >= 0 then return math.floor(val * mult + 0.5) / mult
  else return math.ceil(val * mult - 0.5) / mult end
end

-----------------------------------------------------------
-- STRING --
-----------------------------------------------------------

-- remove trailing and leading whitespace from string.
-- http://en.wikipedia.org/wiki/Trim_(programming)
function trim(s)
  -- from PiL2 20.4
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-----------------------------------------------------------
-- CAPTURE --
-----------------------------------------------------------

function GetBounds(hwnd)
  local _, left, top, right, bottom = reaper.JS_Window_GetRect(hwnd)
  return left, top, right-left, bottom-top
end

-- Thx Edgemeal!!
function CapWindowToPng(hwnd, filename, win10)
  Msg( filename )
  
  -- Not necessary but nice for seeing what is happening
  reaper.JS_Window_SetForeground( hwnd )
  reaper.JS_Window_SetFocus( hwnd )
  
  local srcx,srcy = 0,0
  local srcDC = reaper.JS_GDI_GetWindowDC(hwnd)
  local _,_,w,h = GetBounds(hwnd)

  if win10 then srcx=8 w=w-16 h=h-8 end -- * Workaround for Win10 to ignore invisible window borders

  local destBmp = reaper.JS_LICE_CreateBitmap(true,w,h)
  local destDC = reaper.JS_LICE_GetDC(destBmp)
  -- copy source to dest & write PNG
  reaper.JS_GDI_Blit(destDC, 0, 0, srcDC, srcx, srcy, w, h)
  --reaper.RecursiveCreateDirectory( filename, 0)
  reaper.JS_LICE_WritePNG(filename, destBmp, false)
  -- clean up resources
  reaper.JS_GDI_ReleaseDC(hwnd, srcDC)
  reaper.JS_LICE_DestroyBitmap(destBmp)
  --reaper.JS_GDI_FillRect( destDC, srcx, srcy, srcx+w, srcy+h )
end

-----------------------------------------------------------
                                      -- END OF CAPTURE --
-----------------------------------------------------------

-----------------------------------------------------------
-- RUN --
-----------------------------------------------------------

function Run()
  if not time or diff_time >= wait_time or current_fx == count_fx then
    current_fx = current_fx + 1
    if hwnd then
      retval, fx_name = reaper.TrackFX_GetFXName( track, current_fx - 1 )
      fx_name = fx_name:match("%: (.+) %[") or fx_name:gsub("(.+): ", "")
      fx_name = fx_name:gsub( "%(.+%)", "" )
      fx_name = fx_name:gsub( "/", "-" )
      fx_name = trim( fx_name )
      reaper.CF_SetClipboard( fx_name )
      file_path = folder .. fx_name .. ".png"
      CapWindowToPng( hwnd, file_path, true)
    end
    if current_fx > 0 then
      reaper.TrackFX_SetOpen( track, current_fx - 1, false )
    end
    if current_fx ~= count_fx then
      reaper.TrackFX_Show( track, current_fx, 3 )
      hwnd = reaper.TrackFX_GetFloatingWindow( track, current_fx )
    end
    time = reaper.time_precise()
  end
  diff_time = reaper.time_precise() - time
  
  Tooltip( "FX " .. current_fx+1 .. "/" .. count_fx .. "\nWait for: " .. round( math.max( 0, wait_time - diff_time ), 1 ) .. "s" )
  
  if current_fx ~= count_fx then
    reaper.defer( Run )
  end
end

-----------------------------------------------------------
-- INIT --
-----------------------------------------------------------

function Init()
  reaper.RecursiveCreateDirectory( folder, 0)
  
  reaper.ClearConsole()
  
  track = reaper.GetSelectedTrack( 0, 0 )
  if not track then return end
  
  count_fx = reaper.TrackFX_GetCount( track )
  if count_fx == 0 then return end
  
  reaper.defer( Run )
  reaper.atexit( Exit )
end

if not preset_file_init then
  Init()
end
