--[[
 * ReaScript Name: Insert FX
 * Description: Insert FX on selected tracks. FX name is can be edited witing the script code.
 * Instructions: Run
 * Screenshot:
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI:
 * Licence: GPL v3
 * Forum Thread: 
 * Forum Thread URI: 
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.0
--]]

reaper.Undo_BeginBlock()

FX = "Massive"

TrackIdx = 0
TrackCount = reaper.CountSelectedTracks(0)
while TrackIdx < TrackCount do
	track = reaper.GetSelectedTrack(0, TrackIdx)
	fxIdx = reaper.TrackFX_GetByName (track, FX, 1)
	isOpen = reaper.TrackFX_GetOpen(track, fxIdx)
	if isOpen ==0 then
		isOpen = 1
	else
		isOpen = 0
		end
	reaper.TrackFX_SetOpen(track, fxIdx, isOpen)
	TrackIdx =TrackIdx+1
end

reaper.Undo_EndBlock("Insert FX Plugin",-1)
