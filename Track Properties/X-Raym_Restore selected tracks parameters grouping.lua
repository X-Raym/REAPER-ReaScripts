--[[
 * ReaScript Name: Restore selected tracks grouping parameters
 * Screenshot: https://i.imgur.com/gcjhs8s.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.1
--]]

--[[
 * Changelog:
 * v1.1 (2020-11-28)
  # 64 groups
 * v1.0.1 (2020-11-25)
  + Run from preset file
 * v1.0 (2020-11-24)
  + Initial Release
--]]

-- USER CONFIG AREA ------------------------
reset = true -- reset current tracks groups
--------------------------------------------

ext_name = "XR_SaveTracksGroups"

keys = {"VOLUME_LEAD" , "VOLUME_FOLLOW" , "VOLUME_VCA_LEAD" , "VOLUME_VCA_FOLLOW" , "PAN_LEAD" , "PAN_FOLLOW" , "WIDTH_LEAD" , "WIDTH_FOLLOW" , "MUTE_LEAD" , "MUTE_FOLLOW" , "SOLO_LEAD" , "SOLO_FOLLOW" , "RECARM_LEAD" , "RECARM_FOLLOW" , "POLARITY_LEAD" , "POLARITY_FOLLOW" , "AUTOMODE_LEAD" , "AUTOMODE_FOLLOW" , "VOLUME_REVERSE" , "PAN_REVERSE" , "WIDTH_REVERSE" , "NO_LEAD_WHEN_FOLLOW" , "VOLUME_VCA_FOLLOW_ISPREFX"}

function Init()
  local count_sel_tracks = reaper.CountSelectedTracks(0)
  if count_sel_tracks > 0 and reset then
    reaper.Main_OnCommand( reaper.NamedCommandLookup("_S&M_REMOVE_TR_GRP"), 0 ) -- SWS/S&M: Remove track grouping for selected tracks
  end
  for i = 0, count_sel_tracks - 1 do
    local track = reaper.GetSelectedTrack( 0, i )
    local retval, GUID = reaper.GetSetMediaTrackInfo_String( track, "GUID", "", false )
    for j, key in ipairs(keys) do
      local retval, val = reaper.GetProjExtState(0, ext_name, GUID .. " " .. key)
      if retval == 1 and val and val ~= "" then
        val = tonumber(val)
        if val then
          local membership = reaper.GetSetTrackGroupMembership( track, key, -1, val ) -- TRICKY: -1 for all
        end
      end
      local retval, val = reaper.GetProjExtState(0, ext_name, GUID .. " " .. key .. " 64")
      if retval == 1 and val and val ~= "" then
        val = tonumber(val)
        if val then
          local membership_64 = reaper.GetSetTrackGroupMembershipHigh( track, key, -1, val ) -- TRICKY: -1 for all
        end
      end
    end
  end
  reaper.TrackList_AdjustWindows(false)
end

if not preset_file_init then
  reaper.Undo_BeginBlock()
  Init()
  reaper.Undo_BeginBlock("Restore selected tracks grouping parameters",-1)
end
