--[[
 * ReaScript Name: Prevent items overlapping on selected items tracks (shuffle edit)_background
 * Screenshot: https://i.imgur.com/Ua8jgmd.gif
 * About: A way to swap items with simple click and drags. In user config area, swap can be active if item is before the middle of the previous one. It works on tracks of selected items only for efficiency.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 6.0
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2023-07-16)
  + Initial Release
--]]

-- USER CONFIG AREA ---------------------------------------
swap_at_half = false

-------------------------------- END OF USER CONFIG AREA --

-- NOTE: It could be done only on selected items and prevent others items to be moved, or works on items groups

if not reaper.JS_ReaScriptAPI_Version then
  reaper.ShowMessageBox( 'Please install or update js_ReaScriptAPI extension, available via Reapack.', 'Missing Dependency', 0)
  return false
end
 
-- Set ToolBar Button State
function SetButtonState( set )
  local is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  reaper.SetToggleCommandState( sec, cmd, set or 0 )
  reaper.RefreshToolbar2( sec, cmd )
end


-- Main Function (which loop in background)
function Main()
  
  mouse_state =  reaper.JS_Mouse_GetState( 1 )
  if mouse_state == 0 then
    local count_selected_items = reaper.CountSelectedMediaItems( 0 )
    local tracks_by_guid = {}
    for i = 0, count_selected_items - 1 do
      local item = reaper.GetSelectedMediaItem( 0, i )
      local track = reaper.GetMediaItemTrack( item )
      local track_guid = reaper.GetTrackGUID( track )
      if not tracks_by_guid[ track_guid ] then tracks_by_guid[ track_guid ] = track end
    end
    
    for guid, track in pairs( tracks_by_guid ) do
      local count_track_items = reaper.CountTrackMediaItems( track )
      local items = {}
      for i = 0, count_track_items - 1 do
        items[i+1] = reaper.GetTrackMediaItem( track, i )
      end
      local max_end = 0
      local previous_pos = 0
      local previous_end = 0
      local has_overlap = false
      for i, item in ipairs( items ) do
        local item_pos = reaper.GetMediaItemInfo_Value( item, "D_POSITION" )
        local item_len = reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )
        local item_end = item_pos + item_len
        if item_pos < max_end then
          reaper.PreventUIRefresh(1)
          has_overlap = true
          if swap_at_half and item_pos < previous_pos + previous_len / 2 then
            reaper.SetMediaItemInfo_Value( item, "D_POSITION", previous_pos )
            reaper.SetMediaItemInfo_Value( items[i-1], "D_POSITION", previous_pos + item_len )
          else
            reaper.SetMediaItemInfo_Value( item, "D_POSITION", max_end )
          end
          max_end = max_end + item_len
        else
          max_end = item_end
        end
        previous_pos = reaper.GetMediaItemInfo_Value( item, "D_POSITION" )
        previous_len = item_len
      end
      if has_overlap then
        reaper.PreventUIRefresh(-1)
      end
    end
    
  end
  
  reaper.defer( Main )
  
end



-- RUN
function Init()
  SetButtonState( 1 )
  Main()
  reaper.atexit( SetButtonState )
end

if not preset_file_init then
  Init()
end

