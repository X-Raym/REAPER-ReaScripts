dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")

if not (ultraschall and ultraschall.CopyMediaItemToDestinationTrack and ultraschall.AddItemSpectralEdit) then
  reaper.ShowConsoleMsg("Please Install Ultraschall API via Reapack\nhttps://raw.githubusercontent.com/Ultraschall/ultraschall-lua-api-for-reaper/master/ultraschall_api_index.xml")
  return false
end

ultraschall.MediaExplorer_OnCommand(1010) --Preview: Pause
