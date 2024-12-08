--[[
 * ReaScript Name: Save all open project tabs
 * About: Mod of Script: TJF Save all open dirty projects.lua, but marking all projets dirty within the loop
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0.1
--]]

--[[
 * Changelog:
 * v1.0 (2024-12-06)
  + Initial Release
--]]

 reaper.PreventUIRefresh(1)

      local cur_proj = reaper.EnumProjects( -1)

      local projIdx = 0
      local proj, _ = reaper.EnumProjects( projIdx)


      while proj ~= nil
      do
            reaper.MarkProjectDirty( proj ) -- X-Raym mod here
            if reaper.IsProjectDirty( proj ) > 0 then reaper.Main_SaveProject( proj, false ) end

            projIdx = projIdx + 1
            proj, _ = reaper.EnumProjects( projIdx)
      end

      reaper.SelectProjectInstance(cur_proj)

 reaper.PreventUIRefresh(-1)