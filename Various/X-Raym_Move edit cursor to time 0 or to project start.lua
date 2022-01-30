--[[
 * ReaScript Name: Move edit cursor to time 0 or to project start
 * About: Move edit cursor to time 0 if project start is negative or null. Move edit cursor to project start if project start is > 0.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Version: 2.0
--]]

--[[
 * Changelog:
 * v2.0 (2015-02-28)
  + More accurate
 * v1.0 (2015-02-28)
  + Initial Release
  + Thanks to benf for the help on format_timestr_pos
  + Thanks to spk77 for his Clock.eel script
--]]

function Main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  if reaper.GetPlayState() == 0 or reaper.GetPlayState == 2 then

    offset = reaper.GetProjectTimeOffset( 0, false )

    reaper.SetEditCurPos( -offset, 1, 0 )
  end

  reaper.Undo_EndBlock("Move edit cursor to time 0 or to project start", 0) -- End of the undo block. Leave it at the bottom of your main function.

end

Main() -- Execute your main function

reaper.UpdateArrange() -- Update the arrangement (often needed)


