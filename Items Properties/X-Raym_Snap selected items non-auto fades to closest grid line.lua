--[[
 * ReaScript Name: Snap selected items non-auto fades to closest grid line
 * Screensot: https://i.imgur.com/Z1GTLKU.gif
 * About: If closest grid line would make fade length to 0, then it chooses closest grid line inside the item.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2023-07-25)
  + Initial Release
--]]


-- USER CONFIG AREA -----------------------------------------------------------

console = true -- true/false: display debug messages in the console

undo_text = "Snap selected items non-auto fades to closest grid line"
------------------------------------------------------- END OF USER CONFIG AREA


-- UTILITIES -------------------------------------------------------------

-- Display a message in the console for debugging
function Msg(value)
  if console then
    reaper.ShowConsoleMsg(tostring(value) .. "\n")
  end
end

--------------------------------------------------------- END OF UTILITIES


-- Main function
function Main()

  for i = 0, count_sel_items - 1 do
    local item = reaper.GetSelectedMediaItem( 0, i )

    local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    local item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    local item_end = item_pos + item_len

    local fadein_len = reaper.GetMediaItemInfo_Value(item, "D_FADEINLEN")
    local fadeout_len = reaper.GetMediaItemInfo_Value(item, "D_FADEOUTLEN")

    local fadein_pos_init = item_pos + fadein_len
    local fadeout_pos_init = item_end - fadeout_len

    local fadein_auto_len = reaper.GetMediaItemInfo_Value(item, "D_FADEINLEN_AUTO")
    local fadeout_auto_len = reaper.GetMediaItemInfo_Value(item, "D_FADEOUTLEN_AUTO")

    --if fadein_auto_len == 0 then
      --Msg( item_pos )
      --Msg( fadein_len )
      --Msg( fadein_pos_init )
      fadein_pos = reaper.BR_GetClosestGridDivision( fadein_pos_init )
      --Msg( fadein_pos )
      if fadein_pos < 0 then
        fadein_pos = reaper.BR_GetNextGridDivision(fadein_pos)
      end
      reaper.SetMediaItemInfo_Value(item, "D_FADEINLEN", fadein_pos - item_pos )
    --end

    --if fadeout_auto_len == 0 then
      aaaa = fadeout_pos_init
      fadeout_pos = reaper.BR_GetClosestGridDivision( fadeout_pos_init )
      if fadeout_pos > item_end then
        fadeout_pos = reaper.BR_GetPrevGridDivision(fadeout_pos)
      end
      reaper.SetMediaItemInfo_Value(item, "D_FADEOUTLEN", item_end - fadeout_pos )
    --end

  end

end


-- INIT
function Init()
  -- See if there is items selected
  count_sel_items = reaper.CountSelectedMediaItems(0)
  if count_sel_items == 0 then return false end

  reaper.ClearConsole()

  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock()

  Main()

  reaper.Undo_EndBlock(undo_text, -1)

  reaper.UpdateArrange()

  reaper.PreventUIRefresh(-1)

end

if not preset_file_init then
  Init()
end



