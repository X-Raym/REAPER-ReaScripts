--[[
 * ReaScript Name: Trim left edge of item under mouse or the next one without changing fade-in end
 * About: A way to expand selected mdia item length based on edit cursor and item under mouse. Place edit cursor before an item. Place the mouse hover an item. Execute the script with a shortcut. Not that this script is also able to move left item edges if edit cursor is inside item under mouse.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts (EEL): Move L/R edge of item under mouse to edit cursor (with ripple edit)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=157698
 * REAPER: 5 pre 17
 * Extensions: SWS/S&M 2.12.2 #0
 * Version: 2.0.1
]]

--[[
 * Changelog:
 * v2.0 (2021-03-10)
  # Use SWS instead
 * v1.1.1 (2021-03-09)
  + Fix start offset is rate isn't 0
 * v1.1 (2015-08-11)
  + Stretch Markers and Envelope Points positions preserved
 * v1.0 (2015-08-11)
  + Initial Release
]]

function Msg(variable)
  reaper.ShowConsoleMsg(tostring(variable).."\n")
end

function SaveItemRipple()
  item_get_pos = reaper.GetMediaItemInfo_Value(item_get,"D_POSITION")

  if mouse_item_pos > item_get_pos then
    item[item_ar_len] = item_get
    item_ar_len = item_ar_len + 1
  end
end

--MAIN
function main()

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

  if mouse_item ~= nil then

    reaper.SetMediaItemSelected(mouse_item, true)

    mouse_item_pos = reaper.GetMediaItemInfo_Value(mouse_item,"D_POSITION")
    edit_pos = reaper.GetCursorPosition()

    mouse_item_len = reaper.GetMediaItemInfo_Value(mouse_item,"D_LENGTH")
    mouse_item_end = reaper.GetMediaItemInfo_Value(mouse_item,"D_POSITION")
    mouse_item_snap = reaper.GetMediaItemInfo_Value(mouse_item,"D_SNAPOFFSET")

    mouse_item_end = mouse_item_pos + mouse_item_len
    offset = mouse_item_pos - edit_pos
    --offset = mouse_item_pos - mouse_pos

    track = reaper.GetMediaItem_Track(mouse_item)

    mouse_item_pos = reaper.GetMediaItemInfo_Value(mouse_item,"D_POSITION")

    if mouse_item_end > edit_pos then

      item = {}
      item_ar_len = 0

      --all = GetToggleCommandState(40311)
      --one = GetToggleCommandState(40310)
      ripple = reaper.SNM_GetIntConfigVar(projripedit, -666)

      if ripple == 2 then
      --all == 1 then
        count_media_items = reaper.CountMediaItems(0)

        for i = 0, count_media_items - 1 do

          item_get = reaper.GetMediaItem(0, i)

          SaveItemRipple()

        end
      end

      if ripple == 1 then
      --one == 1 then
        count_item_on_track = reaper.CountTrackMediaItems(track)

        for i = 0, count_item_on_track - 1 do

          item_get = reaper.GetTrackMediaItem(track, i)

          SaveItemRipple()

        end

      end

      mouse_item_snap = reaper.GetMediaItemInfo_Value(mouse_item,"D_SNAPOFFSET")
      mouse_fade_get = reaper.GetMediaItemInfo_Value(mouse_item, "D_FADEINLEN")
      mouse_fade_absolute = mouse_item_pos + mouse_fade_get
      new_fadeout = (mouse_fade_absolute) - (mouse_item_pos - offset)

      reaper.BR_SetItemEdges( mouse_item, mouse_item_pos - offset, -1 )

      reaper.SetMediaItemInfo_Value(mouse_item, "D_FADEINLEN", new_fadeout)

      if ripple > 0 then
      --all == 1 || one == 1 then
        for j = 0, #item do

          item_pos = reaper.GetMediaItemInfo_Value(item[j],"D_POSITION")
          calc = item_pos - offset
          if calc < 0 then calc = 0 end
          reaper.SetMediaItemInfo_Value(item[j], "D_POSITION", calc)

        end
      end

    end

  end

end

reaper.PreventUIRefresh(1)

reaper.Undo_BeginBlock()

group_state = reaper.GetToggleCommandState(1156)
if group_state == 1 then
  reaper.Main_OnCommand(1156,0)
end

cur_pos = reaper.GetCursorPosition()

main()

reaper.SetEditCurPos( cur_pos, false, false)

if group_state == 1 then
  reaper.Main_OnCommand(1156,0)
end

reaper.Undo_EndBlock("Trim left edge of item under mouse or the next one without changing fade-in end", -1)

reaper.UpdateArrange()

reaper.PreventUIRefresh(-1)
