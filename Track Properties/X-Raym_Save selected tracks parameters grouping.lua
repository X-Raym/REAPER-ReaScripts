--[[
 * ReaScript Name: Save selected tracks grouping parameters
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
 * v1.0.2 (2020-11-25)
  + Undo
 * v1.0.1 (2020-11-25)
  + Run from preset file
 * v1.0 (2020-11-24)
  + Initial Release
--]]

-- USER CONFIG AREA ------------------------
reset = true
--------------------------------------------

ext_name = "XR_SaveTracksGroups"

keys = {"VOLUME_LEAD" , "VOLUME_FOLLOW" , "VOLUME_VCA_LEAD" , "VOLUME_VCA_FOLLOW" , "PAN_LEAD" , "PAN_FOLLOW" , "WIDTH_LEAD" , "WIDTH_FOLLOW" , "MUTE_LEAD" , "MUTE_FOLLOW" , "SOLO_LEAD" , "SOLO_FOLLOW" , "RECARM_LEAD" , "RECARM_FOLLOW" , "POLARITY_LEAD" , "POLARITY_FOLLOW" , "AUTOMODE_LEAD" , "AUTOMODE_FOLLOW" , "VOLUME_REVERSE" , "PAN_REVERSE" , "WIDTH_REVERSE" , "NO_LEAD_WHEN_FOLLOW" , "VOLUME_VCA_FOLLOW_ISPREFX"}

function Init()
  local count_sel_tracks = reaper.CountSelectedTracks(0)
  if count_sel_tracks > 0 and reset then
    reaper.SetProjExtState( 0, ext_name, "", "" ) -- Reset
    reaper.MarkProjectDirty( 0 )
  end
  for i = 0, count_sel_tracks - 1 do
    local track = reaper.GetSelectedTrack( 0, i )
    local retval, GUID = reaper.GetSetMediaTrackInfo_String( track, "GUID", "", false )
    for j, key in ipairs(keys) do
      local membership = reaper.GetSetTrackGroupMembership( track, key, 0, 0 )
      local membership_64 = reaper.GetSetTrackGroupMembershipHigh( track, key, 0, -1 ) -- Get
      if membership > 0 or membership_64 > 0 then
        retval = reaper.SetProjExtState(0, ext_name, GUID .. " " .. key, membership)
        retval = reaper.SetProjExtState(0, ext_name, GUID .. " " .. key .. " 64", membership_64)
      else
        -- reaper.SetProjExtState( 0, ext_name, GUID, "" ) -- Reset
      end
    end
  end
end

if not preset_file_init then
  reaper.Undo_BeginBlock()
  Init()
  reaper.Undo_BeginBlock("Save selected tracks grouping parameters",-1)
end
