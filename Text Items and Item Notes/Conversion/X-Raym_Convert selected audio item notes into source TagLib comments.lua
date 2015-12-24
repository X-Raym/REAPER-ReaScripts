--[[
 * ReaScript Name: Convert selected audio item notes into source TagLib comments
 * Description: See title
 * Instructions: Select an item. Use it.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Scripts: TagLib (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1534071
 * REAPER: 5.0 pre 26
 * Extensions: SWS/S&M 2.7.1 #0
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2015-06-12)
	+ Initial Release
 --]]

--[[ ----- DEBUGGING ====>
function get_script_path()
  if reaper.GetOS() == "Win32" or reaper.GetOS() == "Win64" then
    return debug.getinfo(1,'S').source:match("(.*".."\\"..")"):sub(2) -- remove "@"
  end
    return debug.getinfo(1,'S').source:match("(.*".."/"..")"):sub(2)
end

package.path = package.path .. ";" .. get_script_path() .. "?.lua"
require("X-Raym_Functions - console debug messages")

debug = 1 -- 0 => No console. 1 => Display console messages for debugging.
clean = 1 -- 0 => No console cleaning before every script execution. 1 => Console cleaning before every script execution.

msg_clean()
]]-- <==== DEBUGGING -----

function convert() -- local (i, j, item, take, track)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  -- LOOP THROUGH SELECTED ITEMS
  reaper.Main_OnCommand(40100, 0) -- set all media offline
  selected_items_count = reaper.CountSelectedMediaItems(0)
  
  -- INITIALIZE loop through selected items
  for i = 0, selected_items_count-1  do
    -- GET ITEMS
    item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i
    take = reaper.GetActiveTake(item)

    if take ~= nil then
    
      src = reaper.GetMediaItemTake_Source(take)
      
      if src ~= nil then
        fn = reaper.GetMediaSourceFileName(src, "")

        -- MODIFY TAKE
        notes = reaper.ULT_GetMediaItemNote(item)
        
        reaper.Main_OnCommand(40440, 0) -- set offline
        reaper.SNM_TagMediaFile(fn, "Comment", notes)
        reaper.Main_OnCommand(40439, 0) -- set online
        reaper.Main_OnCommand(40441, 0) -- rebuild peak
        
        --retval, tagval = reaper.SNM_ReadMediaFileTag(fn, "Comment", "")
        
      end
    
    end

  end -- ENDLOOP through selected items
  
  reaper.Main_OnCommand(40101, 0)-- sel all items online
  
  reaper.Undo_EndBlock("Convert selected audio item notes into source TagLib comments", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

--msg_start() -- Display characters in the console to show you the begining of the script execution.

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

convert() -- Execute your main function

reaper.PreventUIRefresh(-1) -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)

--msg_end() -- Display characters in the console to show you the end of the script execution.
