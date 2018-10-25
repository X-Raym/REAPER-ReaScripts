--[[
 * ReaScript Name: Display sum of length of selected media items in the console
 * Instructions: Run.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2018-10-10)
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

  local len_sum = 0

  for i = 0, count_sel_items - 1 do

    local item = reaper.GetSelectedMediaItem( 0, i )
    len_sum = len_sum + reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )

  end

  Msg("Number of items selected: ")
  Msg( count_sel_items )
  Msg("")

  Msg("Total length sum (h:m:s.ms)")
  Msg( reaper.format_timestr(len_sum, 5 ) )
  Msg("")

  Msg("Average length by item (h:m:s.ms)")
  Msg( reaper.format_timestr(len_sum / count_sel_items, 5) )
  Msg("")

end

-- INIT
reaper.defer(Main)
