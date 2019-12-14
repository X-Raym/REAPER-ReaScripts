--[[
 * ReaScript Name: Export selection as SRT subtitles with offset
 * Description: Export item's note selection (or on selected track) as offset by edit cursor time SRT subtitles
 * Instructions: Select at least one item or one track with items that you want to export. You can select items accross multiple tracks. Note that the initial cursor position is very important 
 * Authors: X-Raym
 * Author URI: http://extremraym.com
 * Version: 1.4.2
 * Repository: X-Raym/REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * File URI: 
 * License: GPL v3
 * Forum Thread: Lua Script: Export/Import subtitles SubRip SRT format
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1495841#post1495841
 * REAPER: 5.0
 * Extensions: SWS 2.8.1
]]

--[[
 * Change log:
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
 * v1.0 (2015-03-06), by X-Raym
   + Multitrack export support -> every selected track can would be exported
  + Selected items on non selected track will also be exported
  + If no track selected, selected items notes can be exported anyway
  + Better track and item selection restoration
 * v0.5 (2015-03-05), by X-Raym
   # default name is track name - thanks to spk77 for split at comma
   # default folder is project folder
   # if empty fields, back to default values
 * v0.4 (2015-03-05), by X-Raym
  # contextual os-based separator
  + negative first (selected) item pos fix (consider first (selected) item start as time = 0 if cursor pos is after)
  + no item selected => export all items on first selected track as subtitles
  + item selected => export only selected items as subtitles
 * v0.3 (2015-03-04), by X-Raym
  + default folder based on OS
  + user area
 * v0.2 (2015-02-28)
  + initial cursor position offset
 * v0.1 (2015-02-27)
  + initial version

]]

------------------- INIT --------------------------------


if reaper.GetOS() == "Win32" or reaper.GetOS() == "Win64" then
  -- user_folder = buf --"C:\\Users\\[username]" -- need to be test
  separator = "\\"
else
  -- user_folder = "/USERS/[username]" -- Mac OS. Not tested on Linux.
  separator = "/"
end


--------------------------------------------- End of INIT



------------------- TOOLS --------------------------------
  
  
  function selected_items_on_tracks(track) -- local (i, j, item, take, track)
  -- from X-Raym's Add all items on selected track into item selection
    item_num = reaper.CountTrackMediaItems(track)

    for j = 0, item_num-1 do
      item = reaper.GetTrackMediaItem(track, j)
      reaper.SetMediaItemSelected(item, 1)
    end
  end
  
  function HeDaGetNote(item) 
    retval, s = reaper.GetSetItemState(item, "")  -- get the current item's chunk
    if retval then
      --dbug("\nChunk=" .. s .. "\n")
      note = s:match(".*<NOTES\n(.*)>\nIMGRESOURCEFLAGS.*")
      if note then note = string.gsub(note, "|", "") end  -- remove all the | characters
    end
    
    return note
  end
  
  function GetPath(str,sep)
    return str:match("(.*"..sep..")")
  end
  
  function tosrtformat(position)
    hour = math.floor(position/3600)
    minute = math.floor((position - 3600*math.floor(position/3600)) / 60)
    second = math.floor(position - 3600*math.floor(position/3600) - 60*math.floor((position-3600*math.floor(position/3600))/60))
    millisecond = math.floor(1000*(position-math.floor(position)) )
    
    return string.format("%02d:%02d:%02d,%03d", hour, minute, second, millisecond)
  end

-- From yfyf https://gist.github.com/yfyf/6704830
function rgbToHex(r, g, b)
    return string.format("#%0.2X%0.2X%0.2X", r, g, b)
end
  
--------------------------------------------- End of TOOLS

function export_txt(file)

  initialtime = reaper.GetCursorPosition()  -- store initial cursor position as time origin 00:00:00
  cursor_pos = initialtime
  
  items = {}
  for i = 0, new_item_selection_count - 1 do
    local entry = {}
    entry.item = reaper.GetSelectedMediaItem(0, i)
    entry.pos_start = reaper.GetMediaItemInfo_Value(entry.item, "D_POSITION") - initialtime --get itemstart
    entry.len = reaper.GetMediaItemInfo_Value(entry.item, "D_LENGTH") --get length
    entry.pos_end = entry.pos_start + entry.len
    entry.color = reaper.GetDisplayedMediaItemColor(entry.item)
    local r, v, b = reaper.ColorFromNative( entry.color )
    entry.color_hex = rgbToHex(r,v,b)
    entry.notes = reaper.ULT_GetMediaItemNote(entry.item)
    items[i+1] = entry
  end
  
  table.sort(items, function( a,b )
      if (a.pos_start < b.pos_start) then
        -- primary sort on position -> a before b
        return true
      elseif (a.pos_start > b.pos_start) then
        -- primary sort on position -> b before a
        return false
      else
        -- primary sort tied, resolve w secondary sort on rank
        return a.pos_end < b.pos_end
      end
    end)
  
  local f = io.open(file, "w")
  
  for i, item in ipairs( items ) do

    -- write item number 
    -- f:write(i+1 .. "\n" .. item.color_hex .. "\n")
    f:write(i+1 .. "\n")
    
    -- write start and end   00:04:22,670 --> 00:04:26,670
    str_start = tosrtformat(item.pos_start)
    str_end = tosrtformat(item.pos_end)
    f:write(str_start .. " --> " ..  str_end .. "\n")

    -- write text
    f:write(item.notes .. "\n")
    
    -- break line
    f:write("\n")

  end
  
  f:close() -- never forget to close the file
  
  if initialtime > 0 then
    offsetmsg= "\n\nThe file has been exported with an offset time of " .. initialtime .." seconds, relative to cursor project time."
  else
    offsetmsg=""
  end
  
  if no_selected_track == false then
    reaper.ShowMessageBox("\"" .. track_label .. "\" track has been exported to: " .. file .. offsetmsg, "Information",0)
  else
    reaper.ShowMessageBox("Items have been exported to: " .. file .. offsetmsg, "Information",0)
  end
end


--[[ ----- INITIAL SAVE AND RESTORE ====> ]]

-- ITEMS
-- SAVE INITIAL SELECTED ITEMS
init_sel_items = {}
local function SaveSelectedItems (table)
  for i = 0, reaper.CountSelectedMediaItems(0)-1 do
    table[i+1] = reaper.GetSelectedMediaItem(0, i)
  end
end

-- RESTORE INITIAL SELECTED ITEMS
local function RestoreSelectedItems (table)
  reaper.Main_OnCommand(40289, 0) -- Unselect all items
  for _, item in ipairs(table) do
    reaper.SetMediaItemSelected(item, true)
  end
end

--[[ <==== INITIAL SAVE AND RESTORE ----- ]]

-- START -----------------------------------------------------

reaper.PreventUIRefresh(-1) -- prevent refreshing
SaveSelectedItems(init_sel_items)

-- the thing
selected_items_count = reaper.CountSelectedMediaItems(0)
selected_tracks_count = reaper.CountSelectedTracks(0)

if selected_tracks_count > 0 or selected_items_count > 0 then -- if there is a track selected or an item selected
  
  if selected_tracks_count > 0 then
  
    -- loop through all tracks
    for i = 0, selected_tracks_count-1 do
      track = reaper.GetSelectedTrack(0, i)
      selected_items_on_tracks(track)
    end -- end loop through all tracks
    track = reaper.GetSelectedTrack(0, 0)
  
  else
  
    item = reaper.GetSelectedMediaItem(0, 0)
    track = reaper.GetMediaItemTrack(item)
    no_selected_track = true
  
  end

  new_item_selection_count = reaper.CountSelectedMediaItems(0) -- item selection count with all items to be export

  if new_item_selection_count > 0 then -- if there is something to export
    
    retval, track_label = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
    retval, project_path_name = reaper.EnumProjects(-1, "")
    default_path = GetPath(project_path_name, separator) -- default folder export is project path
    default_filename = project_path_name:gsub(".RPP", "") .. " - " .. track_label -- default file name is track name
    defaultvals_csv = default_path .."," .. default_filename:gsub(default_path, "") --default values

    if not reaper.JS_Dialog_BrowseForSaveFile then
      Msg("Please install JS_ReaScript REAPER extension.")
    else
    
     retval, file = reaper.JS_Dialog_BrowseForSaveFile( "Export to SRT", default_path, "", 'SRT files (.srt)\0*.srt\0All Files (*.*)\0*.*\0' )
      
     if retval and file ~= '' then
      
      filenamefull = file:gsub('.srt', '') .. ".srt" -- contextual separator based on user inputs and regex can be nice
      
      filenamefull = filenamefull:gsub(separator..separator, separator)
      
      export_txt(filenamefull) -- export the file
    
    end -- enf if user completed the dialog box
    
    end

  else -- if there is no item to export

    reaper.ShowMessageBox("No items to export", "Information",0)
  
  end -- if there is item to export

else -- there is no selected track

  reaper.ShowMessageBox("Select at least one track or one item","Please",0)

end -- end if there is selected track

-- restoration
RestoreSelectedItems(init_sel_items)

reaper.PreventUIRefresh(-1) -- can refresh again
