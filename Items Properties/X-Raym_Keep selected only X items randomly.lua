--[[
 * ReaScript Name: Keep selected only x items randomly
 * Description: See title.
 * Instructions: Open a MIDI take in MIDI Editor. Select Notes. Run.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script: Script name
 * Forum Thread URI: http://forum.cockos.com/***.html
 * REAPER: 5.0 pre 15
 * Extensions: None
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2015-06-02)
  + Initial Release
--]]

-- ----- DEBUGGING ====>
--[[local info = debug.getinfo(1,'S');

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

msg_clean()]]
-- <==== DEBUGGING -----

-- USER AREA -----------
-- strength_percent = 0.5
-- END OF USER AREA ----

-- INIT
item_sel = 0
init_idx = {}
t = {}

-- SHUFFLE TABLE FUNCTION
-- from Tutorial: How to Shuffle Table Items by Rob Miracle
-- https://coronalabs.com/blog/2014/09/30/tutorial-how-to-shuffle-table-items/
math.randomseed( os.time() )

local function ShuffleTable( t )
  local rand = math.random 
  
  local iterations = #t
  local w
  
  for z = iterations, 2, -1 do
    w = rand(z)
    t[z], t[w] = t[w], t[z]
  end
end


function main() -- local (i, j, item, take, track)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  count_sel_items = reaper.CountSelectedMediaItems(0)

  if count_sel_items > 0 then

      -- GET SELECTED NOTES (from 0 index)
      for i = 0, count_sel_items-1 do
            
        item = reaper.GetSelectedMediaItem(0, i)

        item_sel = item_sel + 1
        init_idx[item_sel] = item
          
      end


    defaultvals_csv = item_sel
    retval, retvals_csv = reaper.GetUserInputs("Keep Selected only X Items Randomly", 1, "Number of items to keep selected", defaultvals_csv) 
      
    if retval then -- if user complete the fields

      notes_selection = tonumber(retvals_csv)
      
      if notes_selection ~= nil then
      -- SHUFFLE TABLE
      ShuffleTable( init_idx )

        for j = 1, item_sel do
        
          item = init_idx[j] 
  
          if j <= notes_selection then
              
              reaper.SetMediaItemSelected(item, true)
            
            else
            -- this allow to execute the action several times. Else, all notes end to be muted.
  
              reaper.SetMediaItemSelected(item, false)
  
            end
        
        end
        
       end
    
    end  

  end -- ENFIF Take is MIDI

  reaper.Undo_EndBlock("Keep selected only x items randomly", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

reaper.PreventUIRefresh(1)

main() -- Execute your main function

reaper.UpdateArrange() -- Update the arrangement (often needed)

reaper.PreventUIRefresh(-1)
