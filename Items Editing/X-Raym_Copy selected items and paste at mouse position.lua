--[[
 * ReaScript Name: Copy selected items and paste at mouse cursor
 * About: A quick way to duplicate items
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0 pre 27
 * Extensions: SWS/S&M 2.7.1 #0
 * Version: 1.2
--]]

--[[
 * Changelog:
 * v1.2 (2021-12-16)
  # Select new items after copy
 * v1.1 (2015-05-08)
  + Snap
 * v1.0 (2015-05-08)
  + Initial Release
--]]

-- USER CONFIG AREA ----------------------------------------
select_new_items = true
------------------------------------ END OF USER CONFIG AREA

function main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  -- YOUR CODE BELOW
  reaper.BR_ItemAtMouseCursor()

  track, context, position = reaper.BR_TrackAtMouseCursor()

  if context == 2 then

    reaper.Main_OnCommand(40297, 0) -- Unselect all tracks (so that it can copy items)
    reaper.Main_OnCommand(40698, 0) -- COpy selected items

    -- GET SNAP
    if reaper.GetToggleCommandState(1157) == 1 then
      position = reaper.SnapToGrid(0, position)
    end

    reaper.SetEditCurPos2(0, position, false, false)
    reaper.SetOnlyTrackSelected(track)
    reaper.Main_OnCommand(40914,0) -- Set first sleected track as last touched
    reaper.Main_OnCommand(40058,0) -- Paste

  end

  reaper.Undo_EndBlock("Copy selected items and paste at mouse cursor", 0) -- End of the undo block. Leave it at the bottom of your main function.

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

-- TRACKS
-- SAVE INITIAL TRACKS SELECTION
init_sel_tracks = {}
local function SaveSelectedTracks (table)
  for i = 0, reaper.CountSelectedTracks(0)-1 do
    table[i+1] = reaper.GetSelectedTrack(0, i)
  end
end

-- RESTORE INITIAL TRACKS SELECTION
local function RestoreSelectedTracks (table)
  reaper.Main_OnCommand(40297, 0) -- Unselect all tracks
  for _, track in ipairs(table) do
    reaper.SetTrackSelected(track, true)
  end
end

-- CURSOR
-- SAVE INITIAL CURSOR POS
function SaveCursorPos()
  init_cursor_pos = reaper.GetCursorPosition()
end

-- RESTORE INITIAL CURSOR POS
function RestoreCursorPos()
  reaper.SetEditCurPos(init_cursor_pos, false, false)
end

-- VIEW
-- SAVE INITIAL VIEW
function SaveView()
  start_time_view, end_time_view = reaper.BR_GetArrangeView(0)
end


-- RESTORE INITIAL VIEW
function RestoreView()
  reaper.BR_SetArrangeView(0, start_time_view, end_time_view)
end

--[[ <==== INITIAL SAVE AND RESTORE ----- ]]

function Init()
  reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

  SaveView()
  SaveCursorPos()

  SaveSelectedItems(init_sel_items)
  SaveSelectedTracks(init_sel_tracks)

  main() -- Execute your main function

  RestoreCursorPos()

  if not select_new_items then
    RestoreSelectedItems(init_sel_items)
  end
  RestoreSelectedTracks(init_sel_tracks)
  RestoreView()

  reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

  reaper.UpdateArrange() -- Update the arrangement (often needed)
end

if not preset_init_file then
  Init()
end
