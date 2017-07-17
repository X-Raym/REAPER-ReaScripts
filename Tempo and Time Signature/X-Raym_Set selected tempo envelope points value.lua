--[[
 * ReaScript Name: Set selected tempo envelope points value
 * Description: Pop up to adjust multiple tempo envelope points
 * Instructions: Run
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
]]

--[[
 * Changelog:
 * v1.0 (2017-07-17)
     + Initial Release
]]

-- USER CONFIG AREA ---------------------------------------------
-- Do you want a pop up to appear ?
prompt = true -- true/false

-- Define here your default variables values
bpm_target = 120
-----------------------------------------------------------------

function Main()

	points_id = {}

	for i = 0, reaper.CountEnvelopePoints( env ) - 1 do

		retval, time, value, shape, tension, selected = reaper.GetEnvelopePoint( env, i )

		if selected then table.insert(points_id, i) end

	end

	for j, ptidx in ipairs( points_id ) do
		retval, timepos, measurepos, beatpos, bpm, timesig_num, timesig_denom, lineartempo = reaper.GetTempoTimeSigMarker( 0, ptidx )
		test = reaper.SetTempoTimeSigMarker( 0, ptidx, timepos, measurepos, beatpos, bpm_target, timesig_num, timesig_denom, lineartempo )
	end

end

env = reaper.GetSelectedEnvelope( 0 )
if env then
	retval, env_name = reaper.GetEnvelopeName( env, '' )
	if env_name == "Tempo map" then

		if prompt == true then

			retval, retval_csv = reaper.GetUserInputs("Tempo points value", 1, "BPM", bpm_target)
			bpm_target = tonumber(retval_csv)
		end

		if retval or prompt == false then


			if bpm_target then -- if user complete the fields

				reaper.PreventUIRefresh(1)

				reaper.Undo_BeginBlock()

				Main()

				reaper.UpdateArrange()
				reaper.UpdateTimeline()

				reaper.Undo_EndBlock( "Set selected tempo envelope points value", - 1 )

				reaper.PreventUIRefresh(-1)

			end
		end
	end
end
