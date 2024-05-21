--[[
 * ReaScript Name: Reset selected items active take source start offset according to media source preferred position
 * Screenshot: https://i.imgur.com/LSeiYXV.gif
 * Author: X-Raym
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2024-05-21)
  + Initial Release
--]]


-- USER CONFIG AREA -----------------------------------------------------------
console = false -- true/false: display debug messages in the console

undo_text = "Reset selected items active take source start offset according to media source preferred position"
------------------------------------------------------- END OF USER CONFIG AREA


-- UTILITIES -------------------------------------------------------------

-- Save item selection
function SaveSelectedItems(t)
  local t = t or {}
  for i = 0, reaper.CountSelectedMediaItems(0)-1 do
    t[i+1] = reaper.GetSelectedMediaItem(0, i)
  end
  return t
end

function RestoreSelectedItems( items )
  reaper.SelectAllMediaItems(0, false)
  for i, item in ipairs( items ) do
    reaper.SetMediaItemSelected( item, true )
  end
end


-- Display a message in the console for debugging
function Msg(value)
  if console then
    reaper.ShowConsoleMsg(tostring(value) .. "\n")
  end
end

--------------------------------------------------------- END OF UTILITIES

function GetTakeSource(take)
  local source =  reaper.GetMediaItemTake_Source( take )
  if not source then return nil end
  local source_section = reaper.GetMediaSourceParent( source ) -- Necesseary for reversed section cause reversed section have 'SECTION' section type
  if source_section then source = source_section end
  return source
end

function SplitSTR( str, char )
  local t = {}
  local i = 0
  for line in str:gmatch("[^" ..char .. "]*") do
      i = i + 1
      t[i] = line:lower()
  end
  return t
end

function toseconds2(pos)
  if not pos then return false end
  local time_tab = SplitSTR( pos, ":|%." )
  local time_units = {"ms", "s", "m", "h"}
  time_tab_num = {}
  local z = 1
  for i = #time_tab, 1, -1 do
    Msg( time_tab[i] )
    time_tab_num[time_units[z]] = time_tab[i] and tonumber(time_tab[i])
    z = z + 1
  end
  local seconds = 0
  if time_tab_num.h then seconds = seconds + time_tab_num.h * 3600 end
  if time_tab_num.m then seconds = seconds + time_tab_num.m * 60 end
  if time_tab_num.s then seconds = seconds + time_tab_num.s end
  if time_tab_num.ms then seconds = seconds + time_tab_num.ms / 1000 end
  if time_tab_num.f then seconds = seconds + time_tab_num.f * (1/fps) end

  return seconds
end

-- Main function
function Main()

  for i, item in ipairs(init_sel_items) do
    local take = reaper.GetActiveTake( item )
    if take and not reaper.TakeIsMIDI( take ) then
      local source = GetTakeSource(take)
      if source then
        local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
        local take_offset = reaper.GetMediaItemTakeInfo_Value( take, "D_STARTOFFS" )
        local retval, metadata_str = reaper.GetMediaFileMetadata( source, "Generic:StartOffset" )
        if metadata_str == "" then metadata_str = 0 end
        -- NOTE: If timeref is 0, then metadata is ""
        -- if timeref is inferior than 1 hour, it's mm:ss.ms, ms with 3 digits
        -- else, it's h:mm:ss.ms, ms with 3 digits
        -- May need checking
        if retval and metadata_str ~= "" then
          local generic_offset = 0
          if metadata_str ~= 0 then
            generic_offset = toseconds2( metadata_str )
          end
          Msg(metadata_str)
          Msg("generic_offset = ".. generic_offset )
          Msg("take_offset = " .. take_offset)
          Msg("item_pos = " .. item_pos)
          local new_take_offset = item_pos-generic_offset
          Msg("new_take_offset = " .. new_take_offset)
          reaper.SetMediaItemTakeInfo_Value( take, "D_STARTOFFS", new_take_offset )
        end
      end
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

