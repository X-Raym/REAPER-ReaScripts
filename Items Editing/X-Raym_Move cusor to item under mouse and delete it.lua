--[[
 * ReaScript Name: Move cusor to item under mouse and delete it
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Editing (various)
 * Forum Thread URI: https://forum.cockos.com/showthread.php?t=163363
 * REAPER: 5.0
 * Version: 1.0.0
--]]

--[[
 * Changelog:
 * v1.0.0 (2026-06-12)
  + Initial Release
--]]


-- USER CONFIG AREA -----------------------------

-- Use Preset Script for safe moding or to create a new action with your own values
-- https://github.com/X-Raym/REAPER-ReaScripts/tree/master/Templates/Script%20Preset

unselect_items = true
undo_text = "Move cusor to item under mouse and delete it"

console = true
-------------------------------------------------

function Msg(value)
  if console then
    reaper.ShowConsoleMsg(tostring(value) .. "\n")
  end
end

-- Main function
function Main()
  local x, y = reaper.GetMousePosition()
  local item, take = reaper.GetItemFromPoint( x, y, true )
  if not item then return end
  local item_pos = reaper.GetMediaItemInfo_Value( item, "D_POSITION" )
  if unselect_items then
    reaper.SelectAllMediaItems(0, false)
  end
  reaper.DeleteTrackMediaItem( reaper.GetMediaItemTrack( item ), item )
  reaper.SetEditCurPos( item_pos, false, false )
end

-- INIT
function Init()
  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  Main()

  reaper.Undo_EndBlock(undo_text, -1) -- End of the undo block. Leave it at the bottom of your main function.

  reaper.UpdateArrange()

  reaper.PreventUIRefresh(-1)
end

if not preset_file_init then
  Init()
end


