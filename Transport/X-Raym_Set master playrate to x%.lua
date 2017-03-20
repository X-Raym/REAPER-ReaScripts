--[[
 * ReaScript Name: Set master playrate to x%
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > ReaScripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

local info = debug.getinfo(1,'S');
local retval, val = reaper.GetUserInputs("Set master playrate to...", 1, "Speed (%)", "100")
if retval then
	val = tonumber( val )
	if val then
		reaper.Undo_BeginBlock()
		reaper.CSurf_OnPlayRateChange( val / 100 )
		reaper.Undo_EndBlock( "Set master playrate to " .. val .. "%", -1 )
	end
end
