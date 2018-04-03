--[[
 * ReaScript Name: Display list of selected media items active take names in the console
 * Instructions: Run.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: X-Raym Premium Scripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2018-04-03)
  + Initial release
--]]

-- For Dax

-- USER CONFIG AREA -----------------------------------------------------------

console = true -- true/false: display debug messages in the console

------------------------------------------------------- END OF USER CONFIG AREA

-- UTILITIES -------------------------------------------------------------

local reaper = reaper

-- Display a message in the console for debugging
function Msg(value)
  if console then
    reaper.ShowConsoleMsg(tostring(value) .. "\n")
  end
end

--------------------------------------------------------- END OF UTILITIES

-- Main function
function Main()

  -- See if there is items selected
  count_sel_items = reaper.CountSelectedMediaItems(0)

  reaper.ClearConsole()

  for i = 0, count_sel_items - 1 do

    local item = reaper.GetSelectedMediaItem( 0, i )
    local take = reaper.GetActiveTake( item )
    if take then
      local name = reaper.GetTakeName( take )
      Msg( name )
    end

  end

end

-- INIT
reaper.defer(Main)
