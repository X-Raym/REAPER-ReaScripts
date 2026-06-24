--[[
 * ReaScript Name: Save current project only if marked as dirty
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0.0
--]]

--[[
 * Changelog:
 * v1.0.0 (2026-06-24)
  + Initial Release
--]]

proj, proj_fn = reaper.EnumProjects(-1)
if reaper.IsProjectDirty( proj ) > 0 or proj_fn == "" then reaper.Main_SaveProject( proj, false ) end
