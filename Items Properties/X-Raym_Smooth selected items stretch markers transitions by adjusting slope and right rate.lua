--[[
 * ReaScript Name: Smooth selected items stretch markers transitions by adjusting slope and right rate
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts 
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * REAPER: 5.0
 * Version: 0.9
--]]

--[[
 * Changelog:
 * v0.9 (2021-02-04)
  + Beta
--]]


-- USER CONFIG AREA -----------------------------------------------------------

console = false -- true/false: display debug messages in the console
gui = false
dont_do_last = true

------------------------------------------------------- END OF USER CONFIG AREA

function Print(value)
  if gui then
    gfx.x = 10
    gfx.y = gfx.y + 20
    gfx.drawstr(tostring(value))
  end
end

function Msg(value)
  reaper.ShowConsoleMsg(tostring(value) .. "\n")
end

function GetSMData( take )
  local sm = {}
  local count =  reaper.GetTakeNumStretchMarkers( take )
  for i = 0, count - 1 do
    local slope = reaper.GetTakeStretchMarkerSlope( take, i )
    local retval, pos_a, srcpos_a = reaper.GetTakeStretchMarker( take, i )
    local retval, pos_b, srcpos_b = reaper.GetTakeStretchMarker( take, i+1 )
    local len_init = srcpos_b - srcpos_a
    if i == count-2 and len_init <= 0 then Msg("EDGE CASE (not fixed yet) in following take\n" .. reaper.GetTakeName( take) .. "\nSM are too close to last one.") end
    local len_after = pos_b - pos_a
    local right_rate = len_init / len_after * (1+slope)
    local left_rate = (len_init / len_after) * (1-slope)
    if i == count - 1 then
      right_rate = 1
      left_rate = 1
      slope = 0
    end
    table.insert( sm, {slope = slope, pos = pos_a, srcpos = srcpos_a, len_init = len_init, len_after = len_after, right_rate = right_rate, left_rate = left_rate})
  end
  return sm
end

function ApplySMData(take, SMs)
  local count =  reaper.GetTakeNumStretchMarkers( take )
  reaper.DeleteTakeStretchMarkers( take, 0,  reaper.GetTakeNumStretchMarkers( take ) )
  for i, sm in ipairs(SMs) do
    local id = reaper.SetTakeStretchMarker( take, -1, sm.new_pos, sm.srcpos )
    if id >= 1 then
      reaper.SetTakeStretchMarkerSlope( take, id-1, SMs[i-1].new_slope )
    end
  end
  reaper.Undo_OnStateChange("Smooth selected items stretch markers transitions by adjusting slope and right rate")
end

function Main()
  if gui then
    gfx.r, gfx.g, gfx.b = 0,0,0
    gfx.rect( 0,0,gfx.w, gfx.h)
    gfx.r, gfx.g, gfx.b = 1,1,1
    gfx.y = 0
  end
  
  count_sel_items = reaper.CountSelectedMediaItems(0)
  
  for z = 0, count_sel_items - 1 do
  
    item = reaper.GetSelectedMediaItem(0,z)
    take = reaper.GetActiveTake( item )
    if take then
      count =  reaper.GetTakeNumStretchMarkers( take )
      -- Msg(count)
      SMs = GetSMData( take )
      cumulated_offset = 0
      if count > 1 then
        for i = 0, count - 1 do
          slope = reaper.GetTakeStretchMarkerSlope( take, i )
          retval, pos_a, srcpos_a = reaper.GetTakeStretchMarker( take, i )
          retval, pos_b, srcpos_b = reaper.GetTakeStretchMarker( take, i+1 )

          Print("i+1 = " .. i+1)
          Print("pos = " .. pos_a)
          
          -- Test
          pos_a = pos_a + cumulated_offset
          pos_b = pos_b + cumulated_offset
          Print("* new_pos = " .. pos_a)
          -- if not retval for i+1 calcl will fail
          len_init = srcpos_b - srcpos_a
          len_after = pos_b - pos_a
          right_rate = len_init / len_after * (1+slope)
          left_rate = (len_init / len_after) * (1-slope)
          
          Print("srcpos = " .. srcpos_a)
          Print("len_init = " .. len_init)
          Print("slope = " .. slope)
          
          if SMs[i+2] then -- if next marker, i is 0, SM is 1 based
            ideal_right_rate = SMs[i+2].left_rate -- Next SM Left rate.  i is 1 based here, so next is 1 + 1 = 2
            ideal_rate_ratio = ideal_right_rate / left_rate
            ideal_slope = (ideal_rate_ratio-1)/(ideal_rate_ratio+1)
            if dont_do_last and i == count-2 then -- avant dernier, on fait 
              ideal_right_rate = SMs[i+1].right_rate
              ideal_rate_ratio = 1
              ideal_slope = SMs[i+1].slope
            end
            new_pos_b = (1+ideal_slope)/ideal_right_rate * (srcpos_b-srcpos_a) + pos_a
            offset = new_pos_b - pos_b
            cumulated_offset = cumulated_offset + offset
          end
          
          SMs[i+1].new_pos = pos_a
          SMs[i+1].new_slope = ideal_slope
          
          if i == count - 1 then
            SMs[i+1].new_slope = 0
          end
          
          -- LOG
          if ideal_slope then
            Print("* ideal_slope = " .. ideal_slope)
          end
          Print("* len_after = " .. len_after)
          Print('* left_rate = ' .. left_rate)
          Print('* right_rate = ' .. right_rate) -- this is rate right to stretch marker, not displayed if same as before
          if SMs[i+2] then
            Print("* ideal_rate_ratio = " .. ideal_rate_ratio)
            Print("* next_rate = " .. SMs[i+2].left_rate)
            --Print("* new_next_pos = " .. new_pos_b)
            Print("* next_cumulated_offset = " .. cumulated_offset)
          end
          Print('----------')
        end
        
        if (gui and gfx.mouse_cap == 1 and gfx.mouse_cap ~= last_cap) or not gui then
          ApplySMData(take, SMs)
          item_len = reaper.GetMediaItemInfo_Value( item, "D_LENGTH")
          reaper.SetMediaItemInfo_Value( item, "D_LENGTH", item_len + cumulated_offset)
        end
        
      end -- if more than 2 SM
    end -- if take
    
  end -- loop item
  
  if gui then
    last_cap = gfx.mouse_cap

    gfx.update()
    if gfx.getchar() ~= 27 then reaper.defer(Main) else gfx.quit() end
  end
  
end

function InitGFX(window_w, window_h, window_x, window_y, docked)
  window_w = 640
  window_h = 720
  gfx.r = 1
  gfx.init("GFX" , window_w, window_h, docked, window_x, window_y)  -- name,w,h,dockstate,xpos,ypos
  gfx.setfont(1, "Arial", 18, 'b');
end

-- INIT

-- See if there is items selected
function Init()
  count_sel_items = reaper.CountSelectedMediaItems(0)
  
  if count_sel_items > 0 then
  
    reaper.ClearConsole()
  
    reaper.PreventUIRefresh(1)
  
    reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
    
    if gui then InitGFX(window_w, window_h, 1080) end
  
    Main()
  
    reaper.UpdateArrange()
  
    reaper.PreventUIRefresh(-1)
    
  end
end

if not preset_file_init then
  Init()
end
