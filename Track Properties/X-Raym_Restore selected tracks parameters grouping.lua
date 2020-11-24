--[[
 * ReaScript Name: Restore selected tracks grouping parameters
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
reset = true -- reset current tracks groups
--------------------------------------------

ext_name = "XR_SaveTracksGroups"

keys = {"VOLUME_LEAD" , "VOLUME_FOLLOW" , "VOLUME_VCA_LEAD" , "VOLUME_VCA_FOLLOW" , "PAN_LEAD" , "PAN_FOLLOW" , "WIDTH_LEAD" , "WIDTH_FOLLOW" , "MUTE_LEAD" , "MUTE_FOLLOW" , "SOLO_LEAD" , "SOLO_FOLLOW" , "RECARM_LEAD" , "RECARM_FOLLOW" , "POLARITY_LEAD" , "POLARITY_FOLLOW" , "AUTOMODE_LEAD" , "AUTOMODE_FOLLOW" , "VOLUME_REVERSE" , "PAN_REVERSE" , "WIDTH_REVERSE" , "NO_LEAD_WHEN_FOLLOW" , "VOLUME_VCA_FOLLOW_ISPREFX"}

function Main()
  local count_sel_tracks = reaper.CountSelectedTracks(0)
  if count_sel_tracks > 0 and reset then
    reaper.Main_OnCommand( reaper.NamedCommandLookup("_S&M_REMOVE_TR_GRP"), 0 ) -- SWS/S&M: Remove track grouping for selected tracks
  end
  for i = 0, count_sel_tracks - 1 do
    local track = reaper.GetSelectedTrack( 0, i )
    for j, key in ipairs(keys) do
      local retval, GUID = reaper.GetSetMediaTrackInfo_String( track, "GUID", "", false )
      local retval, val = reaper.GetProjExtState(0, ext_name, GUID .. " " .. key)
      if retval == 1 and val and val ~= "" then
        val = tonumber(val)
        local membership = reaper.GetSetTrackGroupMembership( track, key, -1, val ) -- TRICKY: -1 for all
      end
    end
  end
  reaper.TrackList_AdjustWindows(false)
end

reaper.defer(Main)
