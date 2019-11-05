--[[
 * ReaScript Name: Explode selected subprojects to child tracks
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Links
    Forum Thread https://forum.cockos.com/showthread.php?t=193482
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2019-11-06)
	+ Child Track
	+ Mute item
	+ Prevent UI Refresh
	+ Multi item selected
--]]

-- From first Snooks version

--[[
    Explode Subproject To Tracks

    Instructions:
        Select a subproject item
        Run script

    Result:
        The tracks from the subproject will replace the
        track that the subproject item was on
    
    v0.3 - adds replacement TrackChunk functions from eugen2777/me2beats
           to avoid issue with chunks > 4MB with API functions

    v0.2 - streamlines parsing project file for tracks

    v0.1 - initial release
--]]

-- TODO:
-- + Position Offset and edge

child = true
delete_items = false -- true or false to only mute

-- Save item selection
function SaveSelectedItems (table)
  for i = 0, reaper.CountSelectedMediaItems(0)-1 do
    table[i+1] = reaper.GetSelectedMediaItem(0, i)
  end
end

local function DBG(str)
  reaper.ShowConsoleMsg(tostring(str) .. "\n")
end

local reaper = reaper

function CountChildTrack( track )

  local count = 0

  local depth = reaper.GetTrackDepth( track )
  local track_index = reaper.GetMediaTrackInfo_Value(track, 'IP_TRACKNUMBER')

  local count_tracks = reaper.CountTracks(0)
  for i = track_index, count_tracks-1 do
    local tr = reaper.GetTrack(0,i)
    if reaper.GetTrackDepth( tr ) > depth then count = count + 1 else break end
  end

  return count
end


local function getFilenameTrackActiveTake(item)
  if item ~= nil then
    local tk = reaper.GetActiveTake(item)
    if tk ~= nil then
      local pcm_source = reaper.GetMediaItemTake_Source(tk)
      local filenamebuf = ""
      filenamebuf = reaper.GetMediaSourceFileName(pcm_source, filenamebuf)
      local track = reaper.GetMediaItemTrack(item)
      return filenamebuf, track
    end
  end
  return nil, nil
end


local function getFileExtension(filename)
  return filename:sub(-3):upper()
end


--[[
      Returns table of tables containing the track_start and
      track_end table/line positions of tracks in the supplied
      project tabke
--]]
local function getTrackTablePositions(project_table)
  local track_table_positions = {}
  local track_start = 0
  local track_count, track_closers = 0,0
  local s
  for i = 1, #project_table do
    s = project_table[i]
    if s:sub(3,8) == "<TRACK" then
      track_count = track_count + 1
      track_start = i
    end
    if s:sub(3,3) == ">" then -- section end
      if track_count > track_closers then
        track_closers = track_closers + 1
        track_table_positions[#track_table_positions+1] = {track_start = track_start,
                                                         track_end = i}
      end
    end
  end
  return track_table_positions
end


local function fileToTable()
  local t = {}
  for line in io.lines() do
    table.insert(t, line)
  end
  table.insert(t, "")
  return t
end


local function tableToString(t)
  local s = table.concat(t, "\n")
  return s
end


-- functions from eugen2777/me2beats to handle issues
-- with API functions for big chunks > 4MB
local function GetTrackChunk(track)
  if not track then return end
  local fast_str, track_chunk
  fast_str = reaper.SNM_CreateFastString("")
  if reaper.SNM_GetSetObjectState(track, fast_str, false, false) then
    track_chunk = reaper.SNM_GetFastString(fast_str)
  end
  reaper.SNM_DeleteFastString(fast_str)  
  return track_chunk
end


local function SetTrackChunk(track, track_chunk)
  if not (track and track_chunk) then return end
  local fast_str, ret
  fast_str = reaper.SNM_CreateFastString("")
  if reaper.SNM_SetFastString(fast_str, track_chunk) then
    ret = reaper.SNM_GetSetObjectState(track, fast_str, true, false)
  end
  reaper.SNM_DeleteFastString(fast_str)
  return ret
end


local function explodeSubproject(filename, track, item)
  local file = io.open(filename)
  io.input(file)
  local t = fileToTable()
  io.close(file)
  
  local start_time = 0
  local end_time = 0
  for i, v in ipairs( t ) do
    local start_time_str = v:match("([%.|%d]+) =START")
    if start_time_str then start_time = tonumber(start_time_str);break end
  end
  
  -- Position Offset
  local take = reaper.GetActiveTake( item )
  local take_offs = reaper.GetMediaItemTakeInfo_Value( take, "D_STARTOFFS" )
  local item_pos = reaper.GetMediaItemInfo_Value( item, "D_POSITION" )
  local item_len = reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )
  reaper.Main_OnCommand(40289, 0) -- Item: Unselect all items
  reaper.SetMediaItemSelected( item, true )
  reaper.Main_OnCommand( 42228, 0 ) -- Item: Set item start/end to source media start/end
  local item_pos_2 = reaper.GetMediaItemInfo_Value( item, "D_POSITION" )
  local item_len_2 = reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )
  reaper.BR_SetItemEdges( item, item_pos, item_pos+item_len )

  local track_number = reaper.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
  local track_index = reaper.GetMediaTrackInfo_Value(track, 'IP_TRACKNUMBER')
  local dep = reaper.GetMediaTrackInfo_Value(track, 'I_FOLDERDEPTH')
  reaper.SetMediaTrackInfo_Value(track, 'I_FOLDERDEPTH', 1)
  local count_child = CountChildTrack( track )
  local last_depth = reaper.GetMediaTrackInfo_Value(reaper.GetTrack(0,track_index + count_child - 1 ), 'I_FOLDERDEPTH')

  local track_table_positions = getTrackTablePositions(t)

  local new_tracks = {}
  
  local tmp_t = {} ; local s
  for i = 1, #track_table_positions do
    reaper.InsertTrackAtIndex(track_number+i-1, false)
    local tptr = reaper.GetTrack(0, track_number+i-1)
    table.insert(new_tracks, tptr )
    local s, e = track_table_positions[i].track_start, track_table_positions[i].track_end
    for ii = s, e do
      tmp_t[#tmp_t+1] = t[ii]
    end
    s = tableToString(tmp_t)
    tmp_t = {}
    SetTrackChunk(tptr, s)
  end
  reaper.SetMediaTrackInfo_Value(reaper.GetTrack(0, count_child + #new_tracks+1)  , 'I_FOLDERDEPTH', last_depth)
  if not child then
    reaper.DeleteTrack(track)
  else
  
  end
  reaper.UpdateArrange()
end


local function main()
  for i, item in ipairs( init_sel_items ) do
    local filename, track = getFilenameTrackActiveTake(item)
    if filename ~= nil then 
      if getFileExtension(filename) == "RPP" then
        explodeSubproject(filename, track, item)
        if child then
          if delete_item then
            reaper.DeleteTrackMediaItem( track, item )
          else
            reaper.SetMediaItemInfo_Value( item, "B_MUTE", 1 )
          end
        end
      end
    end
  end
end


reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock()
reaper.ClearConsole()
init_sel_items = {}
SaveSelectedItems( init_sel_items )
main()
reaper.Undo_BeginBlock("Explode selected subprojects as child tracks",-1)
reaper.UpdateArrange()
reaper.PreventUIRefresh(-1)
