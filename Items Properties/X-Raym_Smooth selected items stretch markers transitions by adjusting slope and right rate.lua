--[[
 * ReaScript Name: Smooth selected items stretch markers transitions by adjusting slope and right rate
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2021-02-04)
  + Initial Release
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
    local rate_right = len_init / len_after * (1+slope)
    local rate_left = (len_init / len_after) * (1-slope)
    if i == count - 1 then
      rate_right = 1
      rate_left = 1
      slope = 0
    end
    table.insert( sm, {slope = slope, pos = pos_a, srcpos = srcpos_a, len_init = len_init, len_after = len_after, rate_right = rate_right, rate_left = rate_left})
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

    local item = reaper.GetSelectedMediaItem(0,z)
    local take = reaper.GetActiveTake( item )
    if take then
      SMs = GetSMData( take )
      cumulated_offset = 0
      if #SMs >= 2 then
        for i, sm in ipairs( SMs ) do
          local slope = sm.slope
          local pos_a, srcpos_a = sm.pos, sm.srcpos
          pos_a = pos_a + cumulated_offset

          sm.new_pos = pos_a

          Print("i = " .. i)
          Print("srcpos = " .. srcpos_a)
          Print("pos = " .. pos_a)
          Print("* new_pos = " .. pos_a)

          if SMs[i+1] then -- if next marker
            local pos_b, srcpos_b = SMs[i+1].pos, SMs[i+1].srcpos
            pos_b = pos_b + cumulated_offset

            local len_init = srcpos_b - srcpos_a
            local len_after = pos_b - pos_a
            local rate_right = (len_init / len_after) * (1+slope)
            local rate_left = (len_init / len_after) * (1-slope)

            Print("len_init = " .. len_init)
            Print("slope = " .. slope)

            local ideal_rate_right = SMs[i+1].rate_left -- Next SM Left rate.  i is 1 based here, so next is 1 + 1 = 2
            local ideal_rate_ratio = ideal_rate_right / rate_left
            local ideal_slope = (ideal_rate_ratio-1)/(ideal_rate_ratio+1)
            if dont_do_last and i == #SMs - 1 then -- avant dernier, on fait
              ideal_rate_right = sm.rate_right
              ideal_rate_ratio = 1
              ideal_slope = sm.slope
            end

            sm.new_slope = ideal_slope

            local new_pos_b = (1+ideal_slope)/ideal_rate_right * (srcpos_b-srcpos_a) + pos_a
            local offset = new_pos_b - pos_b
            cumulated_offset = cumulated_offset + offset

            Print("* ideal_slope = " .. ideal_slope)
            Print("* len_after = " .. len_after)
            Print('* rate_left = ' .. rate_left)
            Print('* rate_right = ' .. rate_right) -- this is rate right to stretch marker, not displayed if same as before
            Print("* ideal_rate_ratio = " .. ideal_rate_ratio)
            Print("* next_rate = " .. SMs[i+1].rate_left)
            Print("* new_next_pos = " .. new_pos_b)
            Print("* next_cumulated_offset = " .. cumulated_offset)

          else -- laster marker
            sm.new_slope = 0
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
    if gfx.getchar() ~= 27 or gfx.getchar() == -1 then reaper.defer(Main) else gfx.quit() end
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
