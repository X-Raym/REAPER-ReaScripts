--[[
 * ReaScript Name: Create markers at selected items snap offset
 * Description: See title
 * Instructions: Select item. Run.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script: Script name
 * Forum Thread URI: http://forum.cockos.com/***.html
 * REAPER: 5.0 pre 15
 * Extensions: SWS/S&M 2.7.1
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2015-06-09)
  + Initial Release
 --]]

--[[ ----- DEBUGGING ====>
local info = debug.getinfo(1,'S');

local full_script_path = info.source

local script_path = full_script_path:sub(2,-5) -- remove "@" and "file extension" from file name

if reaper.GetOS() == "Win64" or reaper.GetOS() == "Win32" then
  package.path = package.path .. ";" .. script_path:match("(.*".."\\"..")") .. "..\\Functions\\?.lua"
else
  package.path = package.path .. ";" .. script_path:match("(.*".."/"..")") .. "../Functions/?.lua"
end

require("X-Raym_Functions - console debug messages")


debug = 1 -- 0 => No console. 1 => Display console messages for debugging.
clean = 1 -- 0 => No console cleaning before every script execution. 1 => Console cleaning before every script execution.

msg_clean()
]]-- <==== DEBUGGING -----

function main() -- local (i, j, item, take, track)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
  
  retval, name = reaper.GetUserInputs("Name markers", 1, "Cancel => take name", "") -- We suppose that the user know the scale he want

  -- INITIALIZE loop through selected items
  for i = 0, reaper.CountSelectedMediaItems(0) - 1 do
  
    -- GET ITEMS
    item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i
    
    item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    item_snap = reaper.GetMediaItemInfo_Value(item, "D_SNAPOFFSET")
    
    take = reaper.GetActiveTake(item)
    if take == nil then
      item_color = reaper.GetDisplayedMediaItemColor(item)
    else
      item_color = reaper.GetDisplayedMediaItemColor2(item, take)
    end
    
    if retval == false then
      if take ~= nil then
        name = reaper.GetTakeName(take)
      else
        name = reaper.ULT_GetMediaItemNote(item)
      end
    end
    
    snap = item_pos + item_snap
    reaper.AddProjectMarker2(0, false, snap, 0, name, -1, item_color)

    
  end -- ENDLOOP through selected items
  --

  reaper.Undo_EndBlock("Create markers at selected items snap offset", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

--msg_start() -- Display characters in the console to show you the begining of the script execution.

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)

--msg_end() -- Display characters in the console to show you the end of the script execution.
