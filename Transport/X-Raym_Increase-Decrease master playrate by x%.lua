--[[
 * ReaScript Name: Increase-Decrease master playrate by x%
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > ReaScripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

local info = debug.getinfo(1,'S');
local retval, val = reaper.GetUserInputs("Increase-Decrease master playrate by...", 1, "Speed (%)", "100")
if retval then
	val = tonumber( val )
	if val then
		reaper.Undo_BeginBlock()
		local playrate = reaper.Master_GetPlayRate( project )
		reaper.CSurf_OnPlayRateChange( playrate + val / 100 )
		reaper.Undo_EndBlock( "Increase-Decrease master playrate by " .. val .. "%", -1 )
	end
end
