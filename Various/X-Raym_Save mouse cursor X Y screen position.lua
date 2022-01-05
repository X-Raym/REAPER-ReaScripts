--[[
 * ReaScript Name: Save mouse cursor X Y screen position
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version:  1.0
 * MetaPackage: true
 * Provides:
 *   [main] . > X-Raym_Save mouse cursor X Y screen position_slot 1.lua
 *   [main] . > X-Raym_Save mouse cursor X Y screen position_slot 2.lua
 *   [main] . > X-Raym_Save mouse cursor X Y screen position_slot 3.lua
 *   [main] . > X-Raym_Save mouse cursor X Y screen position_slot 4.lua
--]]

ext_name = "XR_MousePositions"

script_name = ({reaper.get_action_context()})[2]:match("([^/\\_]+)%.lua$")

slot = script_name:match("slot (%d+)")
if slot then
  slot = tonumber(slot)
  if slot then slot = math.max(math.min(32, slot), 1) else slot = 1 end
else
  slot = 1
end

function runloop()
  local newtime=os.time()

  if (loopcount < 1) then
    if newtime-lasttime >= wait_time_in_seconds then
   lasttime=newtime
   loopcount = loopcount+1
    end
  else
    ----------------------------------------------------
    -- PUT ACTION(S) YOU WANT TO RUN AFTER WAITING HERE

    reaper.TrackCtl_SetToolTip( "", x, y, true )

    ----------------------------------------------------
    loopcount = loopcount+1
  end
  if
    (loopcount < 2) then reaper.defer(runloop)
  end
end

function DisplayTooltip(message)
  wait_time_in_seconds = 2
  lasttime=os.time()
  loopcount=0

  x, y = reaper.GetMousePosition()
  reaper.TrackCtl_SetToolTip( message, x, y, false )

  runloop()
end


function Init()
  x, y = reaper.GetMousePosition()
  retval_x, x = reaper.SetExtState(ext_name, "x" .. slot, x, true)
  retval_y, y = reaper.SetExtState(ext_name, "y" .. slot, y, true)
  DisplayTooltip("Mouse position saved to slot " .. slot .. ".")
end

if not preset_file_init then
  Init()
end
