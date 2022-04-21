--[[
 * ReaScript Name: Paste value in clipboard as selected items volume
 * Author: X-Raym
 * Author URI: https://extremraym.com
 * Repository: GitHub > X-Raym > REAPER ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Version: 1.0.1
--]]

--[[
 * Changelog:
 * v1.0.1 (2022-04-21)
  + Limit value
 * v1.0 (2022-04-21)
  + Initial Release
--]]

-----------------------------------------------------------

min_limit = 0
max_limit = 2

-----------------------------------------------------------

undo_text = "Paste value in clipboard as selected items volume"

function ValFromdB(dB_val) return 10^(dB_val/20) end

function LimitNumber( val, min, max )
  if not val then return nil end
  return math.min(math.max(min, val), max)
end

if not reaper.CF_GetClipboard then
  reaper.ShowMessageBox( 'Please Install last SWS extension.', 'Missing Dependency', 0 )
  return false
end

-- Main function
function Main()

  for i = 0, count_sel_items - 1 do
    local item = reaper.GetSelectedMediaItem( 0, i )
    reaper.SetMediaItemInfo_Value(item, "D_VOL", vol)
  end

end


-- INIT
function Init()
  -- See if there is items selected
  count_sel_items = reaper.CountSelectedMediaItems(0)
  if count_sel_items == 0 then return false end

  vol = reaper.CF_GetClipboard()
  if not vol then return false end

  vol = tonumber( vol )
  if not vol then return false end

  vol = LimitNumber( vol, min_limit, max_limit ) 

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
