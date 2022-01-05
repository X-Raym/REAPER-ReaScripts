 --[[
 * ReaScript Name: Display first selected track width and height
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2021-05-21)
  # Initial release
--]]


-- Ultra Basic GFX
-- For quick testing purposes

ini = reaper.get_ini_file()

window_w = 500
window_h = 200

function init(window_w, window_h, window_x, window_y, docked)
  gfx.setfont(1, "Arial", 36)
  gfx.init("GFX" , window_w, window_h, docked, window_x, window_y)  -- name,w,h,dockstate,xpos,ypos
end

function GetTCPSize()
  local retval, str = reaper.BR_Win32_GetPrivateProfileString("reaper", "leftpanewid", "", ini)
  return tonumber(str)
end

function SetTrackHeight( track, height )
  reaper.SetMediaTrackInfo_Value(track, "I_HEIGHTOVERRIDE", math.max(height, 10) )
  reaper.TrackList_AdjustWindows(false)
end

function DrawStr(str)
  gfx.x = 20
  gfx.y = gfx.y + 36
  gfx.drawstr( str )
end
-- DRAW IN GFX WINDOW
function run()
  gfx.x = 0
  gfx.y = 0

  char = gfx.getchar()
  reaper.SNM_SetIntConfigVar( "leftpanewid", 300 )
  track = reaper.GetSelectedTrack(0,0)
  if track then
    retval, layout = reaper.GetSetMediaTrackInfo_String( track, "P_TCP_LAYOUT", "", false )
    height = reaper.GetMediaTrackInfo_Value(track, "I_TCPH")
    width = GetTCPSize()
    DrawStr("Layout = " .. layout)
    DrawStr("Width = " .. width)
    DrawStr("Height = " .. tostring(height):sub(0,-3))
  end
  gfx.update()
  if gfx.mouse_cap == 4 then offset = 10 else offset = 1 end
  if char == 30064 then
    SetTrackHeight(track, height-offset)
  end -- Up
  if char == 1685026670 then
    SetTrackHeight(track, height+offset)
  end -- Down
  if char ~= 27 or char < 0 then reaper.defer(run) else gfx.quit() end

end -- END DEFER

init(window_w, window_h)
run()

