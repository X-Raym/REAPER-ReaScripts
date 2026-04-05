--[[
 * ReaScript Name: Refresh rate FPS clock (GFX)
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: X-Raym Premium Scripts
 * Licence: GPL v3
 * Version: 1.0.0
--]]

local refresh_rate = 0
local frame_count = 0
local last_time = 0

function main()
  local current_time = reaper.time_precise()
  frame_count = frame_count + 1

  if current_time - last_time >= 1 then
    refresh_rate = frame_count
    frame_count = 0
    last_time = current_time
  end

  gfx.setfont(1, "Arial", 24)
  gfx.set(1,1,1,1)
  gfx.x, gfx.y = 10, 10
  gfx.drawstr(string.format("Refresh Rate: %d Hz\nCurrent Frame: %d", refresh_rate, frame_count))

  gfx.update()
  reaper.defer(main)
end

gfx.init("Refresh Rate FPS", 300, 80)
last_time = reaper.time_precise()
main()