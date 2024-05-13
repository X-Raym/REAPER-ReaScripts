--[[
 * ReaScript Name: Snap closest stretch marker to mouse position
 * About: Put this on a keyboard shortcut. Run.
 * Screenshot: https://i.imgur.com/AagpwDy.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: REQ: Snap stretch marker closest to mouse cursor to grid
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=166702
 * REAPER: 5.0
 * Extensions: SWS 2.9.1
 * Version: 1.1.1
--]]

--[[
 * Changelog:
 * v1.1.1 (2024-05-13)
  + Fix Rate
 * v1.1 (2021-03-30)
  + Snap to grid
 * v1.0 (2021-03-30)
  + Initial Release
--]]

function GetClosestStretchMarker( take, pos )
  local retval = false
  local closest = -1
  local last_diff
  for i = 0,  reaper.GetTakeNumStretchMarkers( take ) - 1 do
    local idx, pos_out, src_pos = reaper.GetTakeStretchMarker( take, i )
    local diff = math.abs( pos - pos_out )
    if not last_diff or  diff <= last_diff then
      closest = i
    else
      break
    end
    last_diff = diff
  end
  return closest
end

function main()

  -- Fallback to first selected item and edit cursor pos if not found, to allow debug within IDE
  take, mouse_pos = reaper.BR_TakeAtMouseCursor()
  if not take then
    item = reaper.GetSelectedMediaItem(0,0)
    if item then take = reaper.GetActiveTake(item) end
  end

  if mouse_pos == -1 then mouse_pos = reaper.GetCursorPosition() end

  if reaper.GetToggleCommandState( 1157 ) then
    mouse_pos = reaper.SnapToGrid( 0, mouse_pos )
  end

  if take then

    item = reaper.GetMediaItemTake_Item(take)
    item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")

    mouse_pos_item = mouse_pos - item_pos

    idx = GetClosestStretchMarker( take, mouse_pos_item)

    if idx ~= nil and idx > -1 then

      retval, strech_pos, srcpos = reaper.GetTakeStretchMarker( take, idx )

      rate = reaper.GetMediaItemTakeInfo_Value(take, "D_PLAYRATE")

      strech_pos = mouse_pos_item * rate

      reaper.SetTakeStretchMarker(take, idx, strech_pos, srcpos)

      group_state = reaper.GetToggleCommandState(1156, 0)

      if group_state == 1 then

        -- Get Item Take
        item = reaper.GetMediaItemTake_Item( take )

        -- Get Group
        group = reaper.GetMediaItemInfo_Value( item, "I_GROUPID" )

        if group > 0 then

          -- Loop others item in in items group
          for j = 0, reaper.CountMediaItems( 0 ) - 1 do
            item_next = reaper.GetMediaItem( 0, j )

            group_next = reaper.GetMediaItemInfo_Value( item_next, "I_GROUPID" )

            if group_next == group then
              take_next = reaper.GetActiveTake( item_next )
              idx, srcpos = GetStretchMarkerAtPosition( take_next, strech_pos )
              if idx then
                reaper.SetTakeStretchMarker(take_next, idx, srcpos)
              end
            end
          end

        end

      end

    end

  end

end

reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

reaper.UpdateArrange() -- Update the arrangement (often needed)

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.Undo_EndBlock("Snap closest stretch marker to mouse position", -1) -- End of the undo block. Leave it at the bottom of your main function.
