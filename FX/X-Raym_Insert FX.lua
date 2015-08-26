-- From Viente
-- http://forum.cockos.com/showthread.php?t=111152


-- lua conversion by X-Raym


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
