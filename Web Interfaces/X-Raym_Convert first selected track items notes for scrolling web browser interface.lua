--[[
 * ReaScript Name: Convert first selected track items notes for scrolling web browser interface
 * About: Use with the X-Raym_Scrolling Lyrics.html web interface
 * Screenshot: https://i.imgur.com/z2Rv2cL.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Link: Forum https://forum.cockos.com/showthread.php?p=2127630#post2127630
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2022-06-20)
  + Initial Release
--]]

track = reaper.GetSelectedTrack( 0, 0 )
if not track then return false end

count_track_items = reaper.CountTrackMediaItems( track )
if count_track_items == 0 then return false end

function Main()

    t = {}
    for i = 0, count_track_items - 1 do
      local item = reaper.GetTrackMediaItem( track, i )
      local retval, item_notes = reaper.GetSetMediaItemInfo_String( item, "P_NOTES", "", false )
      if retval and item_notes ~= "" then
        local item_pos = reaper.GetMediaItemInfo_Value( item, "D_POSITION" )
        local item_len = reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )
        local item_end = item_pos + item_len
        table.insert( t, {text = item_notes, pos_start = item_pos, pos_end = item_end} )
      end
    end

    lines = { "{ \"entry\": [" }
    for i, v in ipairs( t ) do
      local line = "\n{\n  \"pos_start\": " .. v.pos_start .. ",\n  \"pos_end\": " .. v.pos_end  .. ",\n  \"text\": \"" .. v.text:gsub("\n", "<br>"):gsub("\r", "") .. "\"\n},"
      table.insert( lines, line )
    end
    table.insert( lines, "]\n}" )


    ext_name = "XR_Lyrics"
    json = table.concat(lines):gsub(",]", "]")
    reaper.ClearConsole()
    --reaper.ShowConsoleMsg( json )
    --reaper.CF_SetClipboard( json )
    reaper.SetExtState( "XR_Lyrics", "json", json, false )
    reaper.SetExtState( "XR_Lyrics", "need_refresh", "true", false )
end

reaper.defer(Main)
