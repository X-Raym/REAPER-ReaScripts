--[[
 * ReaScript Name: Offset selected items active take pan left -5%
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Properties (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1574814
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2023-12-06)
  + Initial Release
--]]

input_pan = -5
undo_text = "Offset selected items active take pan"

script_name = ({reaper.get_action_context()})[2]:match("([^/\\_]+)%.lua$")

pan_value = script_name:match("(-?%d+)")
if pan_value then
  pan_value = tonumber(pan_value)
  if pan_value then pan_value = math.max(math.min(-100, pan_value), 100) else pan_value = input_pan end
else
  pan_value = input_pan
end

undo_text = undo_text .. " " .. tostring( pan_value ) .. "%"


function main()

  pan_value = pan_value / 100

  -- INITIALIZE loop through selected items
  for i = 0, sel_items_count-1  do
    
    local item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i
  
    local take = reaper.GetActiveTake(item)
  
    if take then
  
        local offset = reaper.GetMediaItemTakeInfo_Value(take, "D_PAN")
        reaper.SetMediaItemTakeInfo_Value(take, "D_PAN", pan_value + offset)
  
    end
    
  end

end

-- START
function Init()
  sel_items_count = reaper.CountSelectedMediaItems(0)
  if sel_items_count == 0 then return false end
  
  reaper.PreventUIRefresh(1)
  
  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
  
  main() -- Execute your main function
  
  reaper.Undo_EndBlock(undo_text, -1) -- End of the undo block. Leave it at the bottom of your main function.
  
  reaper.PreventUIRefresh(-1)
  
  reaper.UpdateArrange() -- Update the arrangement (often needed)
end

if not preset_file_init then
  Init()
end
