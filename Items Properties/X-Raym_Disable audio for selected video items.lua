--[[
 * ReaScript Name: Disable Audio for selected video items
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 7.0
 * Version: 1.0.0
--]]

--[[
 * Changelog:
 * v1.0.0 (2026-02-13)
  + Initial Release
--]]

console = true

undo_text = "Disable Audio for selected video items"

function Msg( value )
  if console then
    reaper.ShowConsoleMsg( tostring( value ) .. "\n" )
  end
end

-- Main function
function Main()

  for i = 0, count_sel_items - 1 do
    local item = reaper.GetSelectedMediaItem(0, i)
    local retval, item_chunk = reaper.GetItemStateChunk( item, "", false)
    if retval then
      local line = "AUDIO 0\n"
      local matches_count = 0
      item_chunk, matches_count = item_chunk:gsub("<SOURCE VIDEO\nFILE ","<SOURCE VIDEO\n".. line .."FILE ")
      if matches_count == 0 then
        item_chunk, matches_count = item_chunk:gsub("<SOURCE VIDEO","<SOURCE VIDEO\n".. line )
      end
      reaper.SetItemStateChunk(item,item_chunk,false)
    end
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

  init_sel_items = SaveSelectedItems()

  Main()

  RestoreSelectedItems(init_sel_items)

  reaper.Undo_EndBlock(undo_text, -1)

  reaper.UpdateArrange()

  reaper.PreventUIRefresh(-1)

end

if not preset_file_init then
  Init()
end