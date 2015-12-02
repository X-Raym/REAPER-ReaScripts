--[[
 * ReaScript Name: Randomize selected envelope points value
 * Description: This script will help you randomize envelope point value.
 * Instructions: Execute the script. Select envelope point. Click and drag on Randomize.
 * Authors: X-Raym
 * Author URI: http://extremraym.com
 * Version: 1.0
 * Repository: X-Raym/REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * File URI: 
 * License: GPL v3
 * Forum Thread: v5.0pre - New ReaScript functions/IDE testing - Page 8
 * Forum Thread URI: http://forum.cockos.com/showpost.php?p=1495481&postcount=284
 * Version: 1.0
 * Version Date: 2015-03-13
 * REAPER: 5.0 pre 9
 * Extensions: None
]]

--[[99% of this is based on spk77's Quantize envelope points.lua]]
 
--[[
 * Change log:
 * v1.0 (2015-03-13)
  + Initial release
]]

function msg(m)
  return reaper.ShowConsoleMsg(tostring(m) .. "\n")
end

local info = debug.getinfo(1,'S');

local full_script_path = info.source
--msg("Full path: \n" .. full_script_path)
--msg("\n")

local script_path = full_script_path:sub(2,-5) -- remove "@" and "file extension" from file name
--msg("'@' and '.lua' removed: \n" .. script_path)
--msg("\n")

if reaper.GetOS() == "Win64" or reaper.GetOS() == "Win32" then
  package.path = package.path .. ";" .. script_path:match("(.*".."\\"..")") .. "..\\Functions\\?.lua"
else
  package.path = package.path .. ";" .. script_path:match("(.*".."/"..")") .. "../Functions/?.lua"
end
--msg(package.config)

local Slider = require "spk77_slider class"


--/////////////////////////////
--// get_set_envelope_points //
--/////////////////////////////

function get_set_envelope_points()
  env = reaper.GetSelectedEnvelope(0)
  if env == nil then
    gfx.x = gui.error_msg_x ; gfx.y = gui.error_msg_y
    gfx.set(1,0,0,1)
    gfx.printf("Please select an envelope")
  else
    local retval, env_name = reaper.GetEnvelopeName(env, "")
    local env_point_count = reaper.CountEnvelopePoints(env)
 
    -- collect points
    if gfx.mouse_cap == 1 and array_created == false then
      e_i = {}
      e_v = {}
      e_pos = {}
      local c = 1
      sel_points = 0
      for i=1, env_point_count do
        retval, timeOut, value, shape, tensionOut, selected = reaper.GetEnvelopePoint(env, i-1)
        if selected then
          e_i[c] = i-1
          e_v[c] = value
          e_pos[c] = timeOut
          c = c + 1
          sel_points = sel_points + 1
        end
      end
      array_created = true
    end
    a=e_i[sel_points-1]

    -- apply changes to selected envelope
    if array_created == true then
       -- get "snap" toggle state (and set it "on")
      if reaper.GetToggleCommandState(1157) == 0 then reaper.Main_OnCommand(1157, 0) end
      --gfx.x = gui.error_msg_x
      --gfx.y = gui.error_msg_y
      --gfx.set(0,1,0,1)
      for i=1, sel_points do
        local retval, t, v, shape, tensionOut, selected = reaper.GetEnvelopePoint(env, e_i[i])
        value = e_v[i] + math.random(-1, 1) * compress.val * 0.5
        new_pos = e_pos[i] --+ math.random(-10, 10) * compress.val * 0.5
        reaper.SetEnvelopePoint(env, e_i[i], new_pos, value, shape, tension, true, true)
      end
      --last_compress_val = compress.val
    end

    reaper.UpdateArrange()
    if add_undo_point == false then add_undo_point = true end -- a flag for "reaper.Undo_OnStateChange"
    want_sortpoints = true -- reaper.Envelope_SortPoints(env) will be called on mouse release (in "Mainloop")
  end
end


--//////////////
--// Mainloop //
--//////////////

function mainloop()
  
  mouse.lb_down = gfx.mouse_cap & 1 == 1
  
  if not mouse.lb_down and want_sortpoints == true then 
    reaper.Envelope_SortPoints(env)
    reaper.UpdateArrange()
    want_sortpoints = false
  end
  
  if last_mouse_state == 0 and mouse.lb_down then
    mouse.click_x = gfx.mouse_x
  end
  
  if mouse.lb_down then
    mouse.dx = gfx.mouse_x-mouse.click_x
    mouse.moving = mouse.dx ~= mouse.last_dx -- true if lmb is down and mouse is moving
    mouse.last_dx = mouse.dx
  end
  
  compress:draw()
  
  if compress.val ~= last_compress_val and mouse.lb_down then
    get_set_envelope_points()
  end
  
  -- Check left mouse btn state
  if not mouse.lb_down then last_mouse_state = 0 else last_mouse_state = 1 end
  
  mouse.dx = 0
  
  if gfx.mouse_cap == 0 then
    if array_created == true then array_created = false end
    if compress.mouse_state == 1 then compress.val = compress.default_val end
  end
  
  -- add undo point if necessary
  if add_undo_point and compress.mouse_state == 0 then
    add_undo_point = false
    reaper.Undo_OnStateChangeEx("Quantize envelope points to grid", -1, -1)
  end
  
  last_compress_val = compress.val
  gfx.update()
  if gfx.getchar() >= 0 then reaper.defer(mainloop) end
end

--//////////
--// Init //
--//////////

function init()
  gfx.init("Randomize selected envelope points value", 300, 100)
  gfx.setfont(1,"Arial", 15)

  gui = {}
  gui.error_msg_x = 10
  gui.error_msg_y = 10
  gui.help_text_x = 10
  gui.help_text_y = gui.error_msg_y + gfx.texth
  
  mouse = {}
  mouse.click_x = -1
  mouse.dx = 0
  mouse.last_dx = 0
  mouse.lb_down = false
  mouse.moving = false
   
  add_undo_point = false
  array_created = false
                  --(x1, y1, w, h, val, default_val, min_val, max_val, lbl, help_text)
  compress = Slider(10, gui.help_text_y + gfx.texth+10, 250, 15, 0.0, 0.0, 0, 1, "Randomize ->","")
  last_compress_val = 0.0
end

init()
mainloop()
