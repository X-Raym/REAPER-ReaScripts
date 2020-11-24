--[[
 * ReaScript Name: Save selected tracks grouping parameters
 * Screenshot: https://i.imgur.com/gcjhs8s.gif
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2020-11-24)
  + Initial Release
--]]

-- USER CONFIG AREA ------------------------
reset = true
--------------------------------------------

ext_name = "XR_SaveTracksGroups"

keys = {"VOLUME_LEAD" , "VOLUME_FOLLOW" , "VOLUME_VCA_LEAD" , "VOLUME_VCA_FOLLOW" , "PAN_LEAD" , "PAN_FOLLOW" , "WIDTH_LEAD" , "WIDTH_FOLLOW" , "MUTE_LEAD" , "MUTE_FOLLOW" , "SOLO_LEAD" , "SOLO_FOLLOW" , "RECARM_LEAD" , "RECARM_FOLLOW" , "POLARITY_LEAD" , "POLARITY_FOLLOW" , "AUTOMODE_LEAD" , "AUTOMODE_FOLLOW" , "VOLUME_REVERSE" , "PAN_REVERSE" , "WIDTH_REVERSE" , "NO_LEAD_WHEN_FOLLOW" , "VOLUME_VCA_FOLLOW_ISPREFX"}

function Main()
  local count_sel_tracks = reaper.CountSelectedTracks(0)
  if count_sel_tracks > 0 and reset then
    reaper.SetProjExtState( 0, ext_name, "", "" ) -- Reset
    reaper.MarkProjectDirty( 0 )
  end
  for i = 0, count_sel_tracks - 1 do
    local track = reaper.GetSelectedTrack( 0, i )
    for j, key in ipairs(keys) do
      local membership = reaper.GetSetTrackGroupMembership( track, key, 0, 0 )
      if membership > 0 then
        local retval, GUID = reaper.GetSetMediaTrackInfo_String( track, "GUID", "", false )
        retval = reaper.SetProjExtState(0, ext_name, GUID .. " " .. key, membership)
      else
        -- reaper.SetProjExtState( 0, ext_name, GUID, "" ) -- Reset
      end
    end
  end
end

reaper.defer(Main)
