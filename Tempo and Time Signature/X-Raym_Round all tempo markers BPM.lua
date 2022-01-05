--[[
 * ReaScript Name: Round all tempo markers BPM
 * About: Tempo markers imported from another app at 109.98 BPM instead of 110? This script is for you!
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
]]

--[[
 * Changelog:
 * v1.0 (2017-07-16)
   + Update
 * v0.9 (2016-11-16)
  + Initial Release
]]

reaper.PreventUIRefresh(1)

reaper.Undo_BeginBlock()

for ptidx = 0, reaper.CountTempoTimeSigMarkers( 0 ) - 1 do
  local retval, timepos, measurepos, beatpos, bpm, timesig_num, timesig_denom, lineartempo = reaper.GetTempoTimeSigMarker( 0, ptidx )
  --TIMEPOS HAVE TO BE ADJUSTED
  bpm = math.floor( bpm + 0.5 )
  reaper.SetTempoTimeSigMarker( 0, ptidx, timepos, measurepos, beatpos, bpm, timesig_num, timesig_denom, lineartempo )
end

reaper.UpdateArrange()
reaper.UpdateTimeline()

reaper.Undo_EndBlock( "Round all tempo markers BPM", -1 )

reaper.PreventUIRefresh(-1)
