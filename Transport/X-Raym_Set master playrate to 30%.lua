--[[
 * ReaScript Name: Set master playrate to 30%
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > ReaScripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

reaper.Undo_BeginBlock()
local info = debug.getinfo(1,'S');
local val = string.match(info.source, "%d+")

reaper.CSurf_OnPlayRateChange( val / 100 )
reaper.Undo_EndBlock( "Set master playrate to " .. val .. "%", -1 )
