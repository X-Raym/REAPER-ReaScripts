-- Version: 0.1

require "spk77_class"

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
                function(sl, x1, y1, w, h, val, default_val, min_val, max_val, lbl, help_text)
                  sl.x1 = x1
                  sl.y1 = y1
                  sl.w = w
                  sl.h = h
                  sl.x2 = sl.x1+w
                  sl.y2 = sl.y1+h
                  
                  sl.val = val
                  sl.default_val = default_val
                  sl.min_val = min_val
                  sl.max_val = max_val
                  sl.lbl = lbl
                  sl.help_text = help_text
                  sl.mouse_state = 0
                  sl.lbl_w, sl.lbl_h = gfx.measurestr(lbl)
                  
                  sl.x_coord = scale_slider_val_to_x(sl.min_val, sl.max_val, sl.val, sl.x1, sl.x2)
                  sl.last_x_coord = sl.x_coord
                end
              )
                    
function Slider:set_help_text()
  --if self.help_text == "" then return false end
  gfx.set(1,1,1,1)
  gfx.x = gui.help_text_x
  gfx.y = gui.help_text_y
  gfx.printf(self.help_text)
end

function Slider:draw()
  --self.x2 = self.x1+self.w
  --self.y2 = self.y1+self.h
  
  self.x_coord = scale_slider_val_to_x(self.min_val, self.max_val, self.val, self.x1, self.x2)
  
  self.a = 0.6
  gfx.set(0.2,0.7,0.7,self.a)
  
  if last_mouse_state == 0 and self.mouse_state == 1 then self.mouse_state = 0 end
  
  if self.mouse_state == 1 or gfx.mouse_x > self.x1 and gfx.mouse_x < self.x2 and gfx.mouse_y > self.y1 and gfx.mouse_y < self.y2 then
    if self.help_text ~= "" then self:set_help_text() end -- Draw info/help text (if self.help_text is not "")
    if last_mouse_state == 0 and gfx.mouse_cap & 1 == 1 and self.mouse_state == 0 then
      self.mouse_state = 1
    end
    if self.mouse_state == 1 then --and mouse.moving then
      self.x_coord = math.min(math.max(0, self.last_x_coord+mouse.dx),self.x2)
      --self.x_coord = math.min(math.max(0, self.last_x_coord+mouse.dx),self.x2)
      --self.val = scale_x_to_slider_val(self.min_val, self.max_val, self.x_coord, self.x1, self.x2)
    end
  end
  self.val = scale_x_to_slider_val(self.min_val, self.max_val, self.x_coord, self.x1, self.x2)
  
  gfx.set(0.2,0.7,0.7,self.a)
  
  --gfx.a = 0.5+0.5*self.x_coord/self.w
  --gfx_a = self.a;
  gfx_a = 1;
  
  gfx.rect(self.x1, self.y1, self.x_coord-self.x1, self.h)
  
  -- Draw slider label (if "slider_label" is not an empty string)
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
  gfx.x = self.x1 + 0.5*self.w
  --gfx.printf(string.format("%.2f",self.val))
  gfx.printf(tostring(math.floor(100*self.val)) .. "%%")
  
  if self.mouse_state == 0 then self.last_x_coord = self.x_coord end
  
  --return self.val
  
end

return Slider
