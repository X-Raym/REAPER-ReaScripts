------------- "class.lua" is copied from http://lua-users.org/wiki/SimpleLuaClasses -----------
-- class.lua
-- Compatible with Lua 5.1 (not 5.0).
function class(base, init)
   local c = {}    -- a new class instance
   if not init and type(base) == 'function' then
      init = base
      base = nil
   elseif type(base) == 'table' then
    -- our new class is a shallow copy of the base class!
      for i,v in pairs(base) do
         c[i] = v
      end
      c._base = base
   end
   -- the class will be the metatable for all its objects,
   -- and they will look up their methods in it.
   c.__index = c

   -- expose a constructor which can be called by <classname>(<args>)
   local mt = {}
   mt.__call = function(class_tbl, ...)
   local obj = {}
   setmetatable(obj,c)
   if init then
      init(obj,...)
   else 
      -- make sure that any stuff from the base class is initialized!
      if base and base.init then
      base.init(obj, ...)
      end
   end
   return obj
   end
   c.init = init
   c.is_a = function(self, klass)
      local m = getmetatable(self)
      while m do 
         if m == klass then return true end
         m = m._base
      end
      return false
   end
   setmetatable(c, mt)
   return c
end
----------------------------------------------------------------------------------------
--///////////////////////
--// Scaling functions //
--///////////////////////

function scale_x_to_slider_val(min_val, max_val, x_coord, x1, x2)
  local scaled_x = min_val + (max_val - min_val) * (x_coord - x1) / (x2 - x1)
  if scaled_x > max_val then scaled_x = max_val end
  if scaled_x < min_val then scaled_x = min_val end
  return scaled_x
end

function scale_slider_val_to_x(min_val, max_val, slider_val, x1, x2)
  return (x1 + (slider_val - min_val) * (x2 - x1) / (max_val - min_val))
end


--///////////////////////
--// Scaling functions //
--///////////////////////

function scale_x_to_slider_val(min_val, max_val, x_coord, x1, x2)
  local scaled_x = min_val + (max_val - min_val) * (x_coord - x1) / (x2 - x1)
  if scaled_x > max_val then scaled_x = max_val end
  if scaled_x < min_val then scaled_x = min_val end
  return scaled_x
end

function scale_slider_val_to_x(min_val, max_val, slider_val, x1, x2)
  return (x1 + (slider_val - min_val) * (x2 - x1) / (max_val - min_val))
end


--//////////////////
--// Slider class //
--//////////////////

local Slider = class(
                      function(sl, x1, y1, w, h, val, min_val, max_val, lbl, help_text)
                        sl.x1 = x1
                        sl.y1 = y1
                        sl.w = w
                        sl.h = h
                        sl.x2 = x1+w
                        sl.y2 = y1+h
                        sl.val = val
                        sl.min_val = min_val
                        sl.max_val = max_val
                        sl.lbl = lbl
                        sl.help_text = help_text
                        sl.help_text = ""
                        sl.mouse_state = 0
                        sl.lbl_w, sl.lbl_h = gfx.measurestr(lbl)
                      end
                    )
                    
function Slider:set_help_text()
  if self.help_text == "" then return false end
    gfx.set(1,1,1,1)
    gfx.x = 10
    gfx.y = 10
    gfx.printf(self.help_text)
end

function Slider:draw()
  --self:set_help_text()
  self.a = 0.6
  gfx.set(0.2,0.7,0.7,self.a)
  
  if last_mouse_state == 0 and self.mouse_state == 1 then self.mouse_state = 0 end
  
  if self.mouse_state == 1 or gfx.mouse_x > self.x1 and gfx.mouse_x < self.x2 and gfx.mouse_y > self.y1 and gfx.mouse_y < self.y2 then
    if self.help_text ~= "" then self:set_help_text() end -- Draw info/help text (if self.help_text is not "")
    if last_mouse_state == 0 and gfx.mouse_cap & 1 == 1 and self.mouse_state == 0 then
      self.mouse_state = 1
    end
    if self.mouse_state == 1 then
      self.val = scale_x_to_slider_val(self.min_val, self.max_val, gfx.mouse_x, self.x1, self.x2)
    end
  end
  gfx.set(0.2,0.7,0.7,self.a)
  self.x_coord = scale_slider_val_to_x(self.min_val, self.max_val, self.val, self.x1, self.x2)
  
  --// Draw slider
  --gfx.a = 0.5+0.5*self.x_coord/self.w
  
  gfx_a = self.a;
  gfx_a = 1;
  
  gfx.rect(self.x1, self.y1, self.x_coord-self.x1, self.h)
  
  --// Draw slider label (if "slider_label" is not an empty string)
  if self.lbl ~= "" then 
     gfx.x = self.x1+4
     gfx.y = self.y1 + 0.5*self.h - 0.5*gfx.texth
     gfx.set(1,1,1,1);
     gfx.printf(self.lbl)
  end
  
  gfx.set(0.9,0.9,0.9,0.9)

  --//gfx_a = 0.2;
  gfx.a = self.a-0.5
  gfx.rect(self.x1, self.y1, self.w, self.h)

  --// Show slider value
  
  self.val_w = gfx.measurestr(string.format("%.2f",self.val))
  gfx.a = 1
  gfx.x = self.x2 - self.val_w
  gfx.printf(string.format("%.2f",self.val))
  return self.val
end


--//////////////////
--// Button class //
--//////////////////

local Button = class(
                      function(btn,x1,y1,w,h,state_count,state,visual_state,lbl,help_text)
                        btn.x1 = x1
                        btn.y1 = y1
                        btn.w = w
                        btn.h = h
                        btn.x2 = x1+w
                        btn.y2 = y1+h
                        btn.state = state
                        btn.state_count = state_count - 1
                        btn.vis_state = visual_state
                        btn.label = lbl
                        btn.help_text = help_text
                        btn.__mouse_state = 0
                        btn.label_w, btn.label_h = gfx.measurestr(btn.label)
                        btn.__state_changing = false
                        btn.r = 0.7
                        btn.g = 0.7
                        btn.b = 0.7
                        btn.a = 0.2
                        btn.lbl_r = 1
                        btn.lbl_g = 1
                        btn.lbl_b = 1
                        btn.lbl_a = 1
                      end
                    )

-- get current state
function Button:get_state()
   return self.state
end

-- cycle through states
function Button:set_next_state()
  if self.state <= self.state_count - 1 then
    self.state = self.state + 1
  else self.state = 0 
  end
end

-- get "button label text" w and h
function Button:measure_lbl()
  self.label_w, self.label_h = gfx.measurestr(self.label)
end

-- returns true if "mouse on element"
function Button:__is_mouse_on()
  return(gfx.mouse_x > self.x1 and gfx.mouse_x < self.x2 and gfx.mouse_y > self.y1 and gfx.mouse_y < self.y2)
end

function Button:__lmb_down()
  return(last_mouse_state == 0 and gfx.mouse_cap & 1 == 1 and self.__mouse_state == 0)
  --return(last_mouse_state == 0 and self.mouse_state == 1)
end

function Button:set_help_text()
  if self.help_text == "" then return false end
    gfx.set(1,1,1,1)
    gfx.x = 10
    gfx.y = 10
    gfx.printf(self.help_text)
end

function Button:set_color(r,g,b,a)
  self.r = r
  self.g = g
  self.b = b
  self.a = a
end

function Button:set_label_color(r,g,b,a)
  self.lbl_r = r
  self.lbl_g = g
  self.lbl_b = b
  self.lbl_a = a
end


function Button:draw_label()
  -- Draw button label
  if self.label ~= "" then
    gfx.x = self.x1 + math.floor(0.5*self.w - 0.5 * self.label_w) -- center the label
    gfx.y = self.y1 + 0.5*self.h - 0.5*gfx.texth

    if self.__mouse_state == 1 then 
      gfx.y = gfx.y + 1
      gfx.a = self.lbl_a*0.5
    elseif self.__mouse_state == 0 then
      gfx.a = self.lbl_a
    end
  
    gfx.set(self.lbl_r,self.lbl_g,self.lbl_b,self.lbl_a)
    
    gfx.printf(self.label)
    if self.__mouse_state == 1 then gfx.y = gfx.y - 1 end
  end
end

-- Draw element (+ mouse handling)
function Button:draw()
  
  -- lmb released (and was clicked on element)
  if last_mouse_state == 0 and self.__mouse_state == 1 then self.__mouse_state = 0 end
  
  
  -- Mouse is on element -----------------------
  if self:__is_mouse_on() then 
    if self:__lmb_down() then -- Left mouse btn is pressed on button
    --if last_mouse_state == 0 and gfx.mouse_cap & 1 == 1 and self.mouse_state == 0 then
      self.__mouse_state = 1
      if self.__state_changing == false then
        self.__state_changing = true
      else self.__state_changing = true
      end
    end
    
    self:set_help_text() -- Draw info/help text (if 'help_text' is not "")
    
    if last_mouse_state == 0 and gfx.mouse_cap & 1 == 0 and self.__state_changing == true then
      if self.onClick ~= nil then self:onClick()
        self.__state_changing = false
      else self.__state_changing = false
      end
    end
  
  -- Mouse is not on element -----------------------
  else
    if last_mouse_state == 0 and self.__state_changing == true then
      self.__state_changing = false
    end
  end  
  --gfx.a = self.a
  
  if self.__mouse_state == 1 or self.vis_state == 1 or self.__state_changing then
    --self.a = math.max(self.a - 0.2, 0.2)
    --gfx.set(0.8,0,0.8,self.a)
    gfx.set(0.8*self.r,0.8*self.g,0.8*self.b,math.max(self.a - 0.2, 0.2)*0.8)
    gfx.rect(self.x1, self.y1, self.w, self.h)

  -- Button is not pressed
  elseif not self.state_changing or self.vis_state == 0 or self.__mouse_state == 0 then
    gfx.set(self.r+0.2,self.g+0.2,self.b+0.2,self.a)
    gfx.rect(self.x1, self.y1, self.w, self.h)
   
    gfx.a = math.max(0.4*self.a, 0.6)
    -- light - left
    gfx.line(self.x1, self.y1, self.x1, self.y2-1)
    gfx.line(self.x1+1, self.y1+1, self.x1+1, self.y2-2)
    -- light - top
    gfx.line(self.x1+1, self.y1, self.x2-1, self.y1)
    gfx.line(self.x1+2, self.y1+1, self.x2-2, self.y1+1)

    --gfx.set(0.4,0,0.4,1)
    gfx.set(0.3*self.r,0.3*self.g,0.3*self.b,math.max(0.9*self.a,0.8))
    -- shadow - bottom
    gfx.line(self.x1+1, self.y2-1, self.x2-2, self.y2-1)
    gfx.line(self.x1+2, self.y2-2, self.x2-3, self.y2-2)
    -- shadow - right
    gfx.line(self.x2-1, self.y2-1, self.x2-1, self.y1+1)
    gfx.line(self.x2-2, self.y2-2, self.x2-2, self.y1+2)
  end
  
  
  self:draw_label()
end


--//////////
--// Main //
--//////////

function main()
--[[
  local ps = reaper.GetPlayState()
  
  -- Update "Play button" visual state
  if ps == 1 then
    play_btn.vis_state = 1 -- pressed down
  else
    play_btn.vis_state = 0 -- up
  end
--]]
   -- Update "Stop button" text
  if ps == 0 then
    stop_btn.label = "Stopped"
    stop_btn:measure_lbl()
  else
    stop_btn.label = "Stop"
    stop_btn:measure_lbl()
  end

  -- Draw buttons
  play_btn:draw()
  stop_btn:draw()
  
  sl_play_btn_r:draw()
  sl_play_btn_g:draw()
  sl_play_btn_b:draw()
  sl_play_btn_a:draw()
  
  sl_play_lbl_r:draw()
  sl_play_lbl_g:draw()
  sl_play_lbl_b:draw()
  sl_play_lbl_a:draw()
  
  --sl_stop_btn_r:draw()
  --sl_stop_btn_g:draw()
  --sl_stop_btn_b:draw()
  --sl_stop_btn_a:draw()
  
  play_btn:set_color(sl_play_btn_r.val, sl_play_btn_g.val, sl_play_btn_b.val, sl_play_btn_a.val)
  play_btn:set_label_color(sl_play_lbl_r.val, sl_play_lbl_g.val, sl_play_lbl_b.val, sl_play_lbl_a.val)
  

  -- Check left mouse btn state
  if gfx.mouse_cap & 1 == 0 then
    last_mouse_state = 0
  else last_mouse_state = 1 end
  
  gfx.update()
  if gfx.getchar() >= 0 then reaper.defer(main) end
end


--//////////
--// Init //
--//////////

function init()
  gfx.init("Play and Stop buttons", 350, 200)
  gfx.setfont(1,"Arial", 15)
  
  -- Create "instances" --
  -- parameters: Button(x1,y1,w,h,state_count,state,visual_state,lbl,help_text)
  play_btn = Button(10,30,80,20,2,0,0,"Play", "'Play' button")
  -- play_btn is pressed -> call reaper.Main_OnCommand(1007, 0)
  play_btn.onClick = function ()
                       reaper.Main_OnCommand(1007, 0)
                     end
  
  play_btn:set_color(1,1,0,0.5)
  play_btn:set_label_color(1,1,1,1)
                     
  
  stop_btn = Button(10,play_btn.y2+10,80,20,2,0,0,"Stop","'Stop' button")
  -- stop_btn is pressed -> call reaper.Main_OnCommand(1016, 0)
  stop_btn.onClick = function ()
                       reaper.Main_OnCommand(1016, 0)
                     end
                     
  sl_play_btn_r = Slider(100, 30, 100, 15, 0, 0, 1, "button R","Play button - Red")
  sl_play_btn_g = Slider(100, 30+20, 100, 15, 1, 0, 1, "button G","Play button - Green")
  sl_play_btn_b = Slider(100, 30+40, 100, 15, 0, 0, 1, "button B","Play button - Blue")
  sl_play_btn_a = Slider(100, 30+60, 100, 15, 0.1, 0, 1, "button A","Play button - Alpha")
  
  local sl_xpos = sl_play_btn_r.x2 + 10
  sl_play_lbl_r = Slider(sl_xpos, 30, 100, 15, 0, 0, 1, "label R", "Play button label - Red")
  sl_play_lbl_g = Slider(sl_xpos, 30+20, 100, 15, 1, 0, 1, "label G", "Play button label - Green")
  sl_play_lbl_b = Slider(sl_xpos, 30+40, 100, 15, 0, 0, 1, "label B","Play button label - Blue")
  sl_play_lbl_a = Slider(sl_xpos, 30+60, 100, 15, 1, 0, 1, "label A","Play button label - Alpha")
  
  
end

init()
main()