--[[
 * ReaScript Name: Play selected items once from first snap offset position
 * About: Just like the SWS action Xenakios/SWS: Play selected items once but from snap offset pos
 * Screenshot: https://i.imgur.com/80v4gQk.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > ReaScripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

play_action = 1007 -- Transport: Play
move_view = true
seek_play = false

function Main_OnCommand( val )
  if not tonumber(val) then 
    val = reaper.NamedCommandLookup(val)
  end
  reaper.Main_OnCommand( val, 0 )
end

function GetItemsEdges()
	local max, min = 0, math.huge
	for i = 0, count_sel_items - 1 do
		local item = reaper.GetSelectedMediaItem(0,i)
		local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")          
		local item_snap = reaper.GetMediaItemInfo_Value(item, "D_SNAPOFFSET")
		local item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
		max = math.max( max, item_pos + item_len )
		min = math.min( min, item_pos + item_snap)
	end
	return max, min
end

function Run()
	local cur_play = reaper.GetPlayPosition() 
	local play_state = reaper.GetPlayState()
	if cur_play < max and play_state == 1 then
		reaper.defer(Run)
	else
		reaper.OnStopButton()
	end
end

function Init()
	count_sel_items = reaper.CountSelectedMediaItems(0)
	if count_sel_items > 0 then
		max, min = GetItemsEdges()
		reaper.SetEditCurPos( min, move_view, seek_play)
		Main_OnCommand( play_action )
		reaper.defer(Run)
	end
end

if not preset_file_init then
	if not reaper.BR_TrackAtMouseCursor then
		reaper.ShowMessageBox("Please install SWS extension", "Warning", 1)
	else
		reaper.defer(Init)
	end
end
