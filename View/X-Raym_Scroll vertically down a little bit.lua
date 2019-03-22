--[[
 * ReaScript Name: Scroll vertically down a little bit
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > ReaScripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

function Main()
	reaper.CSurf_OnScroll( 0, 1 )
end

reaper.defer(Main)