--[[
 * ReaScript: Add envelope markers from selected envelope points
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0.3
--]]

--[[
 * Changelog:
 * v1.0 (2021-12-23)
  + Initial Release
--]]

env = reaper.GetSelectedTrackEnvelope(0)

if not env then return false end

count_env_points = reaper.CountEnvelopePoints(env)

for i = 0, count_env_points do
  local retval, time, value, shape, tension, selected = reaper.GetEnvelopePoint( env, i )
  if selected then
    reaper.AddProjectMarker(0, false, time, 0, value, -1)
  end
end
