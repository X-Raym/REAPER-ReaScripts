--[[
 * ReaScript Name: Reset audio and MIDI devices
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2024-02-07)
  + Initial release
--]]

-- This is a non defer version of Script: mpl_Reset audio and MIDI devices.lua

reaper.Audio_Quit()
reaper.Audio_Init()