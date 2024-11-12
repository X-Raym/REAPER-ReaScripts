--[[
 * ReaScript Name: Double click over item action with zoom to content if MIDI take
 * About: Action to auto zoom to content when double click MIDI items. Fallback to all other default behavior for other type of media. Meant to be put as mouse modifier item double click, but can be used in any way.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 7.0
 * Version: 1.0.1
--]]

--[[
 * Changelog:
 * v1.0 (2024-11-11)
  + Initial Release
--]]

-- USER CONFIG AREA ------------------------------------------------------

-- Use Preset Script for safe moding or to create a new action with your own values
-- https://github.com/X-Raym/REAPER-ReaScripts/tree/master/Templates/Script%20Preset

action_open_item_in_external_editor = 40109
action_show_item_properties = 40009

source_type_for_external = {
  SUBPROJECT = true,
  RPP_PROJECT = true,
  CLICK = true,
  LTC = true
}

-------------------------------------------------- END OF USER CONFIG AREA

function GetTakeSource( take )
  local source =  reaper.GetMediaItemTake_Source( take )
  local source_section = reaper.GetMediaSourceParent( source ) -- Necesseary for reversed section cause reversed section have 'SECTION' section type
  if source_section then source = source_section end
  return source
end

function OpenMIDIEditor()
  reaper.Main_OnCommand( 40153, 0 ) -- Item: Open in built-in MIDI editor (set default behavior in preferences)
  reaper.MIDIEditor_LastFocused_OnCommand( 40466, false ) -- View: Zoom to content
end

function ProcessItem(item, take)
  if take then
    if reaper.TakeIsMIDI( take ) then
      OpenMIDIEditor() -- Stop at first MIDI take
      return true
    else
      local source = GetTakeSource( take )
      local source_type = reaper.GetMediaSourceType(source)
      if source_type_for_external[ source_type ] then
        reaper.Main_OnCommand(action_open_item_in_external_editor, 0) -- Stop at first click
        return true
      end
    end
  elseif reaper.CountTakes( item ) == 0 then
    reaper.Main_OnCommand(action_open_item_in_external_editor, 0) -- Stop at first click
    return true
  end
end

function Main()
  
  local x, y = reaper.GetMousePosition()
  local item, take = reaper.GetItemFromPoint( x, y, true )
  local already_open
  
  if item then
    already_open = ProcessItem( item, take )
  else

    count_sel_items = reaper.CountSelectedMediaItems(0)
    if count_sel_items == 0 then return end

    for i = 0, count_sel_items-1 do
      local item = reaper.GetSelectedMediaItem(0, i)
      local take = reaper.GetActiveTake(item)
      already_open = ProcessItem( item, take )
    end
  
  end

  -- Items selected, but no MIDI or Subprojects
  if not already_open then
    reaper.Main_OnCommand(action_show_item_properties, 0)
  end
end

function Init()
  Main()
end

if not preset_file_init then
  Init()
end

