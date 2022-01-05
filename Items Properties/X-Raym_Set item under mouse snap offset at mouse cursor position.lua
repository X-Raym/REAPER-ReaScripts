--[[
 * ReaScript Name: Set item under mouse snap offset at mouse cursor position
 * Instructions: Select items with take. Run.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Script (Lua): Shuffle Items
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1524014
 * REAPER: 5.0 pre 31
 * Extensions: SWS 2.7.1 #0
 * Version: 1.1
--]]

--[[
 * Changelog:
 * v1.1 (2015-24-06)
  + Snap to stretch marker if mouse over it
 * v1.0 (2015-05-20)
  + Initial Release
--]]


function main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  -- MOUSE CONTEXT
  window, segment, details = reaper.BR_GetMouseCursorContext()
  mouse_pos = reaper.BR_GetMouseCursorContext_Position()

  if window == "arrange" and details == "item_stretch_marker" then

    item = reaper.BR_GetMouseCursorContext_Item()
    take = reaper.GetActiveTake(item)

    idx = reaper.BR_GetMouseCursorContext_StretchMarker()

    retval, pos, srcpos = reaper.GetTakeStretchMarker(take, idx)

    -- GET INFOS
    item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")

    reaper.SetMediaItemInfo_Value(item, "D_SNAPOFFSET", pos)

  end

  if window == "arrange" and details == "item" then

    item = reaper.BR_GetMouseCursorContext_Item()
    take = reaper.GetActiveTake(item)

    -- GET INFOS
    item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    item_end =  item_pos + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")

    if reaper.GetToggleCommandState(1157) == 1 then

      mouse_pos =  reaper.SnapToGrid(0, mouse_pos)

      if mouse_pos < item_pos then mouse_pos = item_pos end

      if mouse_pos > item_end then mouse_pos = item_end end

    end

    reaper.SetMediaItemInfo_Value(item, "D_SNAPOFFSET", mouse_pos - item_pos)

  end -- ENDLOOP through selected items

  reaper.Undo_EndBlock("Set item under mouse snap offset at mouse cursor position", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

main() -- Execute your main function

reaper.UpdateArrange() -- Update the arrangement (often needed)
