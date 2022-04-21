--[[
 * ReaScript Name: Copy first selected item volume value into clipboard
 * Author: X-Raym
 * Author URI: https://extremraym.com
 * Repository: GitHub > X-Raym > REAPER ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2022-04-21)
  + Initial Release
--]]

function dBFromVal(val) return 20*math.log(val, 10) end

if not reaper.CF_SetClipboard then
  reaper.ShowMessageBox( 'Please Install last SWS extension.', 'Missing Dependency', 0 )
  return false
end

item = reaper.GetSelectedMediaItem(0, 0)
if not item then return false end

item_vol = reaper.GetMediaItemInfo_Value(item, "D_VOL")
reaper.CF_SetClipboard(item_vol)

mouse_x, mouse_y = reaper.GetMousePosition()
reaper.TrackCtl_SetToolTip("Item volume copied to clipboard\n" .. dBFromVal(item_vol) .. "dB", mouse_x + 17, mouse_y + 17, false)
