--[[
 * ReaScript Name: Set selected takes playrate keeping snap offset position and adjusting length
 * About: A way to expand items in selection without moving their synch point, determined by snap offset and content at snap offset.
 * Screenshot: https://i.imgur.com/VrDKb9h.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Editing (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=163363
 * REAPER: 5.0
 * Version: 2.1
--]]

--[[
 * Changelog:
 * v2.1 (2021-01-18)
  + Multiply support with * or / prefix
 * v2.0 (2021-01-18)
  # Support relative mode
 * v1.0.1 (2020-01-18)
  # prompt variable fix
 * v1.0 (2017-01-26)
  + Initial Release
--]]

--[[
 * Many thanks to mpl for this help on this script ! He made this possible :D Thanks man!
 * http:--forum.cockos.com/member.php?u=70694
--]]

-- ------ USER AREA =====>
mod1 = "absolute" -- Set the primary mod that will be defined if no prefix character. Values are "absolute" or "relative".
mod2 = "relative"
mod2_prefix = "+" -- Prefix to enter the secondary mod
mod2_prefix_multiply = "*" -- Prefix to enter the secondary mod multiply
input_default = "1" -- "" means no character aka relative per default.
popup = true
-- <===== USER AREA ------

ext_name = 'XR_SetTakePlayrate'

function main()

  -- INITIALIZE loop through selected items
  for i = 0, sel_items_count-1 do
    -- GET ITEMS
    item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i

    take = reaper.GetActiveTake(item)

    if take then

      item_length  = reaper.GetMediaItemInfo_Value( item, 'D_LENGTH')
      take_rate = reaper.GetMediaItemTakeInfo_Value(  take, 'D_PLAYRATE')
      item_fade_in = reaper.GetMediaItemInfo_Value( item, "D_FADEINLEN" )
      item_fade_out = reaper.GetMediaItemInfo_Value( item, "D_FADEOUTLEN" )

      item_position = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
      item_snap = reaper.GetMediaItemInfo_Value(item, "D_SNAPOFFSET")
      item_snap_absolute = item_snap + item_position

      rate = user_input_num

      if set then
        original_rate = reaper.GetMediaItemTakeInfo_Value(take, "D_PLAYRATE")
        new_rate = rate
        if new_rate > 0 then
          reaper.SetMediaItemTakeInfo_Value(take, "D_PLAYRATE",new_rate)
          original_len = item_length * original_rate -- consider that original len is what item 1 should be
          reaper.SetMediaItemInfo_Value( item, 'D_LENGTH', original_len / new_rate)
          reaper.SetMediaItemInfo_Value( item, "D_FADEINLEN", item_fade_in  * original_rate / new_rate)
          reaper.SetMediaItemInfo_Value( item, "D_FADEOUTLEN", item_fade_out * original_rate / new_rate)

          k = take_rate / new_rate
          new_snap_offset = item_snap * k
          new_pos = item_snap_absolute - new_snap_offset
          reaper.SetMediaItemInfo_Value(item, "D_POSITION", new_pos)
          reaper.SetMediaItemInfo_Value(item, "D_SNAPOFFSET", new_snap_offset)

        end
      else
        original_rate = reaper.GetMediaItemTakeInfo_Value(take, "D_PLAYRATE")
        if multiply then
          new_rate = rate * original_rate
        elseif divide then
          new_rate = original_rate / rate
        else
          new_rate = rate + original_rate
        end
        if new_rate > 0 then
          reaper.SetMediaItemTakeInfo_Value(take, "D_PLAYRATE",new_rate)
          original_len = item_length * original_rate
          reaper.SetMediaItemInfo_Value( item, 'D_LENGTH', original_len / new_rate)
          reaper.SetMediaItemInfo_Value( item, "D_FADEINLEN", item_fade_in  * original_rate / new_rate)
          reaper.SetMediaItemInfo_Value( item, "D_FADEOUTLEN", item_fade_out * original_rate / new_rate)

          k = take_rate / new_rate
          new_snap_offset = item_snap * k
          new_pos = item_snap_absolute - new_snap_offset
          reaper.SetMediaItemInfo_Value(item, "D_POSITION", new_pos)
          reaper.SetMediaItemInfo_Value(item, "D_SNAPOFFSET", new_snap_offset)

        end
      end

    end -- if take

  end -- ENDLOOP through selected items

end

-- START

function Init()

  sel_items_count = reaper.CountSelectedMediaItems(0)

  if sel_items_count > 0 then

    if popup then
      if reaper.HasExtState( ext_name, "input_default" ) then
        input_default = reaper.GetExtState( ext_name, "input_default" )
      end
      retval, user_input_str = reaper.GetUserInputs("Set/Offset Take Rate Value", 1, "Value (" .. mod2_prefix .." for " .. mod2 .. ", * and /)", input_default)
    else
      user_input_str = input_default
    end

    if not popup or retval then -- if user complete the fields

      x, y = string.find(user_input_str, mod2_prefix)

      multiply = string.find(user_input_str, "%*")
      divide = string.find(user_input_str, "/")

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

      if multiply or divide then set = false end

      user_input_num = user_input_str:gsub(mod2_prefix, "")
      user_input_num = user_input_num:gsub("%*", "")
      user_input_num = user_input_num:gsub("/", "")
      user_input_num = tonumber(user_input_num)

      if user_input_num and user_input_num ~= 0 then

        reaper.PreventUIRefresh(1)

        reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

        main() -- Execute your main function

        if popup then
          reaper.SetExtState( ext_name, "input_default", user_input_str, true )
        end

        reaper.Undo_EndBlock("Set selected takes playrate keeping snap offset position and adjusting length", -1) -- End of the undo block. Leave it at the bottom of your main function.

        reaper.PreventUIRefresh(-1)

        reaper.UpdateArrange() -- Update the arrangement (often needed)

      end

    end

  end

end

if not dofile_execution then
  Init()
end
