--[[
 * ReaScript Name: Toggle selected items text notes stretching
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Forum Thread: Scripts (LUA): Text Items Formatting Actions (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=156757
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0.0
--]]

--[[
 * Changelog:
 * v1.0.0 (2025-10-20)
  + Initial release
--]]


-- USER CONFIG AREA -----------------------------------------------------------
console = true -- true/false: display debug messages in the console

undo_text = "Toggle selected items text notes stretching"
------------------------------------------------------- END OF USER CONFIG AREA

if not reaper.BR_SetMediaItemImageResource then
  reaper.MB("SWS extension is required by this script.\nPlease download it on http://www.sws-extension.org/", "Warning", 0)
  return
end


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
    local item = reaper.GetSelectedMediaItem(0, i)
    local retval, image, imageflags = reaper.BR_GetMediaItemImageResource( item )

    local new_flags = force_new_flags
    if not new_flags then
      new_flags = imageflags == 3 and 0 or 3
    end

    reaper.BR_SetMediaItemImageResource(item, "", new_flags)
  end
end

-- INIT
function Init()
  reaper.ClearConsole()

  -- See if there is items selected
  count_sel_items = reaper.CountSelectedMediaItems(0)
  if count_sel_items == 0 then return false end

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
