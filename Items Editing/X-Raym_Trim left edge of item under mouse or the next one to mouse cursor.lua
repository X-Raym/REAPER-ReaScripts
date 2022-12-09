--[[
 * ReaScript Name: Trim left edge of item under mouse or the next one to mouse cursor
 * Screenshot: https://i.imgur.com/qt93dsZ.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 6.0
 * Extensions: SWS/S&M 2.12.2 #0
 * Version: 1.0
]]

--[[
 * Changelog:
 * v1.0 (2022-12-09)
  + Initial Release
]]

if not reaper.BR_SetItemEdges then
  reaper.ShowConsoleMsg("SWS extension is required by this script.\nPlease download it on http://www.sws-extension.org/", "Warning", 0)
  return
end

function Msg(variable)
  reaper.ShowConsoleMsg(tostring(variable).."\n")
end

--MAIN
function Main()

  mouse_item, mouse_pos = reaper.BR_ItemAtMouseCursor()

  if mouse_item == nil then -- Mouse in in arrange view

    mouse_track, track_context, mouse_pos = reaper.BR_TrackAtMouseCursor()

    if track_context == 2 then

      count_items_on_tracks = reaper.CountTrackMediaItems(mouse_track)

      for i = 0, count_items_on_tracks - 1 do

        mouse_item = reaper.GetTrackMediaItem(mouse_track, i)
        mouse_item_pos = reaper.GetMediaItemInfo_Value(mouse_item, "D_POSITION")

        if mouse_item_pos >= mouse_pos then
          break
        else
          mouse_item = nil
        end

      end

    end

  end

  if not mouse_item then return end
    
  reaper.SelectAllMediaItems( 0, false)
  reaper.SetMediaItemSelected(mouse_item, true)

  mouse_item_pos = reaper.GetMediaItemInfo_Value(mouse_item,"D_POSITION")
  mouse_item_len = reaper.GetMediaItemInfo_Value(mouse_item,"D_LENGTH")
  mouse_item_end = mouse_item_pos + mouse_item_len
  
  if reaper.GetToggleCommandState( 1157 ) then
    mouse_pos = reaper.SnapToGrid( 0, mouse_pos )
  end

  if mouse_item_end > mouse_pos then

    -- mouse_fade_get = reaper.GetMediaItemInfo_Value(mouse_item, "D_FADEINLEN")
    -- mouse_fade_absolute = mouse_item_pos + mouse_fade_get
    -- new_fadeout = math.max( 0, mouse_fade_absolute - mouse_pos)

    reaper.BR_SetItemEdges( mouse_item, mouse_pos, -1 )

    -- reaper.SetMediaItemInfo_Value(mouse_item, "D_FADEINLEN", new_fadeout)

  end

end

function Init()

  reaper.ClearConsole()
  
  reaper.PreventUIRefresh(1)
  
  reaper.Undo_BeginBlock()
  
  Main()
  
  reaper.Undo_EndBlock("Trim left edge of item under mouse or the next one to mouse cursor", -1)
  
  reaper.UpdateArrange()
  
  reaper.PreventUIRefresh(-1)
end

if not preset_file_init then
  Init()
end
