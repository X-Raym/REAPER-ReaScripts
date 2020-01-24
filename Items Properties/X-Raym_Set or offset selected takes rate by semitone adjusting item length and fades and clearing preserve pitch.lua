--[[
 * ReaScript Name: Set or offset selected takes rate by semitone adjusting item length and fades and clearing preserve pitch
 * Description: Contrary to native actions, this one adjust fades. It also force non preserving pitch.
 * Screenshot: https://i.imgur.com/2gGxOoH.gifv
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Properties (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1574814
 * REAPER: 5.0
 * Version: 1.0.2
--]]
 
--[[
 * Changelog:
 * v1.0.2 (2020-01-24)
  # Fade adjustement on already tweaked items fixed
 * v1.0.1 (2020-01-14)
  # Fade out fix
 * v1.0 (2020-01-14)
  + Initial Release
--]]
 
-- ------ USER AREA =====>
mod1 = "absolute" -- Set the primary mod that will be defined if no prefix character. Values are "absolute" or "relative".
mod2 = "relative"
mod2_prefix = "+" -- Prefix to enter the secondary mod
input_default = "0" -- "" means no character aka relative per default.
-- <===== USER AREA ------
 

function main()

  reaper.Main_OnCommand( 40796, 0 ) -- Item properties: Clear take preserve pitch
  
  -- INITIALIZE loop through selected items
  for i = 0, sel_items_count-1  do
    -- GET ITEMS
    item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i
  
    take = reaper.GetActiveTake(item)
  
    if take then
      
      item_length  = reaper.GetMediaItemInfo_Value( item, 'D_LENGTH')
      take_rate = reaper.GetMediaItemTakeInfo_Value(  take, 'D_PLAYRATE')
      item_fade_in = reaper.GetMediaItemInfo_Value( item, "D_FADEINLEN" )
      item_fade_out = reaper.GetMediaItemInfo_Value( item, "D_FADEOUTLEN" )
      
      rate = 2^(user_input_num/12)
      
      if set then
        original_rate = reaper.GetMediaItemTakeInfo_Value(take, "D_PLAYRATE")
        new_rate = rate
        reaper.SetMediaItemTakeInfo_Value(take, "D_PLAYRATE",new_rate)
        original_len = item_length * original_rate -- consider that original len is what item 1 should be
        reaper.SetMediaItemInfo_Value( item, 'D_LENGTH', original_len / new_rate)
        reaper.SetMediaItemInfo_Value( item, "D_FADEINLEN", item_fade_in  * original_rate / new_rate)
        reaper.SetMediaItemInfo_Value( item, "D_FADEOUTLEN", item_fade_out * original_rate / new_rate)
      else
        original_rate = reaper.GetMediaItemTakeInfo_Value(take, "D_PLAYRATE")
        new_rate = rate * original_rate
        reaper.SetMediaItemTakeInfo_Value(take, "D_PLAYRATE",new_rate)
        original_len = item_length * original_rate
        reaper.SetMediaItemInfo_Value( item, 'D_LENGTH', original_len / new_rate)
        reaper.SetMediaItemInfo_Value( item, "D_FADEINLEN", item_fade_in  * original_rate / new_rate)
        reaper.SetMediaItemInfo_Value( item, "D_FADEOUTLEN", item_fade_out * original_rate / new_rate)
      end

    end -- if take

  end -- ENDLOOP through selected items  

end

-- START
sel_items_count = reaper.CountSelectedMediaItems(0)

if sel_items_count > 0 then

  retval, user_input_str = reaper.GetUserInputs("Set/Offset Take Rate Value", 1, "Value (" .. mod2_prefix .." for " .. mod2 .. ")", input_default) 
      
  if retval then -- if user complete the fields
    
    x, y = string.find(user_input_str, mod2_prefix)
        
    if mod1 == "absolute" then
      if x ~= nil then -- set
        set = false
      else -- offset
        set = true 
      end
    end
    
    if mod1 == "relative" then
      if x ~= nil then -- set
        set = true
      else -- offset
        set = false 
      end
    end
    
    user_input_str = user_input_str:gsub(mod2_prefix, "")
    
    user_input_num = tonumber(user_input_str)

    if user_input_num then
    
      reaper.PreventUIRefresh(1)
      
      reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
  
      main() -- Execute your main function
      
      reaper.Undo_EndBlock("Set or offset selected takes rate by semitone adjusting item length and fades and clearing preserve pitch", -1) -- End of the undo block. Leave it at the bottom of your main function.
  
      reaper.PreventUIRefresh(-1)
  
      reaper.UpdateArrange() -- Update the arrangement (often needed)
    
    end

  end
  
end
