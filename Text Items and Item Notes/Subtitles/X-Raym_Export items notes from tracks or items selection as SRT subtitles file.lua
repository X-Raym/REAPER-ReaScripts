--[[
 * ReaScript Name: Export items notes from tracks or items selection as SRT subtitles file
 * About:
     Export items notes from selected tracks (or just items selection) as offset by edit cursor time SRT subtitles
     Select at least one item or one track with items that you want to export. You can select items accross multiple tracks. Note that the initial cursor position is very important
     Based on HeDa_X-Raym_Export selection as SRT subtitles with offset.lua
 * Authors: X-Raym
 * Author URI: https://www.extremraym.com
 * Version: 2.1
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * License: GPL v3
 * Forum Thread: Lua Script: Export/Import subtitles SubRip SRT format
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1495841#post1495841
 * REAPER: 5.0
]]

--[[
 * Changelog:
 * v2.1 (2024-11-12)
  + Font color support in User Config Area
 * v2.0 (2024-11-12)
  # Refactoring
  # Renamed
  # Optimizations (remove SWS dependencies)
 * v1.5 (2022-01-12)
  # Prevent negative subtitles
  # Round milliseconds instead of truncation
 * v1.4.3 (2020-03-17)
  # Bug fix
 * v1.4.2 (2019-12-14)
  # Bug fix
 * v1.4.1 (2019-12-10)
  + Better save dialog window
 * v1.4 (2019-20-11)
  + Fork from source
  # Optimizaton
 * v1.3 (2015-10-06)
  # Bug fix if the project was not saved
 * v1.2 (2015-08-21)
  # Better path and naming
 * v1.1.1 (2015-08-02)
  # Bug fix
 * v1.1 (2015-07-29)
  # Better get notes.
 * v1.0 (2015-03-06)
   + Multitrack export support -> every selected track can would be exported
  + Selected items on non selected track will also be exported
  + If no track selected, selected items notes can be exported anyway
  + Better track and item selection restoration
 * v0.5 (2015-03-05)
   # default name is track name - thanks to spk77 for split at comma
   # default folder is project folder
   # if empty fields, back to default values
 * v0.4 (2015-03-05)
  # contextual os-based separator
  + negative first (selected) item pos fix (consider first (selected) item start as time = 0 if cursor pos is after)
  + no item selected => export all items on first selected track as subtitles
  + item selected => export only selected items as subtitles
 * v0.3 (2015-03-04)
  # X-Raym maintainter
  + default folder based on OS
  + user area
 * v0.2 (2015-02-28)
  + initial cursor position offset
 * v0.1 (2015-02-27)
  + initial version by Heda
]]

-- USER CONFIG AREA ------------------------------------------------------

-- Use Preset Script for safe moding or to create a new action with your own values
-- https://github.com/X-Raym/REAPER-ReaScripts/tree/master/Templates/Script%20Preset

export_color = false -- Export item color as font color in SRT

-------------------------------------------------- END OF USER CONFIG AREA

os_sep = package.config:sub(1,1)

cur_pos = reaper.GetCursorPosition()  -- store initial cursor position as time origin 00:00:00

if not reaper.JS_ReaScriptAPI_Version then
  reaper.MB( 'Please install or update js_ReaScriptAPI extension, available via Reapack.', 'Missing Dependency', 0 )
  return false
end

function Msg( val )
  reaper.ShowConsoleMsg( tostring( val ) .. "\n" )
end

function tosrtformat( position )
  position = position + 0.0005
  local hour = math.floor( position / 3600 )
  local minute = math.floor( ( position - 3600 * hour ) / 60)
  local second = math.floor( position - 3600 * hour - 60 * minute )
  local millisecond = math.floor( position * 1000 - math.floor( position ) * 1000 )
  local out = string.format( "%02d:%02d:%02d,%03d", hour, minute, second, millisecond )
  return out
end

-- From yfyf https://gist.github.com/yfyf/6704830
function rgbToHex( r, g, b )
  return string.format( "#%0.2X%0.2X%0.2X", r, g, b )
end

function SortTable( tab, val1, val2)
  -- SORT TABLE
  -- thanks to https://forums.coronalabs.com/topic/37595-nested-sorting-on-multi-dimensional-array/
  table.sort(tab, function( a,b )
    if (a[val1] < b[val1]) then
      -- primary sort on position -> a before b
      return true
    elseif (a[val1] > b[val1]) then
      -- primary sort on position -> b before a
      return false
    else
      -- primary sort tied, resolve w secondary sort on rank
      return a[val2] < b[val2]
    end
  end)
end

function ExportSRT( file )

  local f = io.open( file, "w" )
  if not f then return reaper.ShowMessageBox( "Impossible to write file: " .. file, "Error", 0 ) end

  local count = 0 -- Written in SRT
  for i, item in ipairs( items ) do
    if item.pos_end > 0 then

      if item.pos_start < 0 then item.pos_start = 0 end

      -- write item number
      count = count + 1
      f:write( count .. "\n" )

      -- write start and end   00:04:22,670 --> 00:04:26,670
      str_start = tosrtformat( item.pos_start )
      str_end = tosrtformat( item.pos_end )
      f:write( str_start .. " --> " ..  str_end .. "\n")
      
      if export_color then
        f:write( '<font color="' .. item.color_hex .. '">' )
      end

      -- write text
      f:write( item.notes )
      
      if export_color then
         f:write( "</font>" .. "\n" )
      end

      -- break line
      f:write( "\n\n" )
    end
  end

  f:close() -- never forget to close the file

  -- Confirmation Messages
  local offsetmsg = ""
  if cur_pos > 0 then
    offsetmsg= "\n\nThe file has been exported with an offset time of " .. cur_pos .." seconds, relative to cursor project time."
  end

  if selected_tracks_count == 0 then
    reaper.ShowMessageBox( "Items have been exported to: " .. file .. offsetmsg, "Information", 0 )
  else
    reaper.ShowMessageBox( "\"" .. track_name .. "\" track has been exported to: " .. file .. offsetmsg, "Information", 0 )
  end
end

function SaveItem( t, item )
  local entry = {}
  entry.item = item
  entry.pos_start = reaper.GetMediaItemInfo_Value( entry.item, "D_POSITION" ) - cur_pos
  entry.len = reaper.GetMediaItemInfo_Value( entry.item, "D_LENGTH" )
  entry.pos_end = entry.pos_start + entry.len
  entry.color = reaper.GetDisplayedMediaItemColor( entry.item )
  local r, v, b = reaper.ColorFromNative( entry.color )
  entry.color_hex = rgbToHex( r, v, b )
  local retval, item_notes = reaper.GetSetMediaItemInfo_String( item, "P_NOTES", "", false )
  entry.notes = item_notes

  table.insert( t, entry )
end

function Main()

  -- Check if there is something to export
  items = {}

  if selected_tracks_count > 0 then

    for i = 0, selected_tracks_count-1 do
      local track = reaper.GetSelectedTrack(0, i)
      local count_track_items = reaper.CountTrackMediaItems( track )
      for j = 0, count_track_items - 1 do
        local item = reaper.GetTrackMediaItem( track, j )
        SaveItem( items, item )
      end
    end

    -- for file name
    track = reaper.GetSelectedTrack(0, 0)

  else

    -- For file name
    item = reaper.GetSelectedMediaItem(0, 0)
    track = reaper.GetMediaItemTrack(item)

    count_sel_items = reaper.CountSelectedMediaItems( 0 )
    for j = 0, count_sel_items - 1 do
      local item = reaper.GetSelectedMediaItem( 0, j )
      SaveItem( items, item )
    end

  end

  if #items == 0 then return reaper.ShowMessageBox( "No items to export", "Information", 0 ) end

  -- Prepare file name for export
  retval, track_name = reaper.GetSetMediaTrackInfo_String( track, "P_NAME", "", false )
  retval, project_path_name = reaper.EnumProjects(-1)
  default_folder = project_path_name:match( "(.*".. os_sep ..")" ) -- GetPath: default folder export is project path
  default_filename = project_path_name:lower():gsub( ".RPP", "" ) .. " - " .. track_name -- default file name is first track name
  default_folder = default_folder or ""
  defaultvals_csv = default_folder .."," .. default_filename:gsub(default_folder, "") --default values

  retval, file = reaper.JS_Dialog_BrowseForSaveFile( "Export to SRT", default_folder, "", 'SRT files (.srt)\0*.srt\0All Files (*.*)\0*.*\0' )
  if not retval or file == '' then return end

  -- Sanitize file name and prepare export
  filenamefull = file:lower():gsub( '.srt', '' ) .. ".srt" -- contextual separator based on user inputs and regex can be nice
  filenamefull = filenamefull:gsub( os_sep..os_sep, os_sep ) -- remove double separators

  SortTable( items, "pos_start", "pos_end" )

  ExportSRT( filenamefull ) -- export the file
end


function Init()
  selected_items_count = reaper.CountSelectedMediaItems(0)
  selected_tracks_count = reaper.CountSelectedTracks(0)

  if selected_tracks_count == 0 and selected_items_count == 0 then
    return reaper.ShowMessageBox( "Select at least one track or one item","Please", 0 )
  end

  reaper.ClearConsole()

  reaper.PreventUIRefresh(-1)

  Main()

  reaper.PreventUIRefresh(-1)
end

if not preset_file_init then
  Init()
end
