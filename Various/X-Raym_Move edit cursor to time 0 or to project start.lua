--[[
 * ReaScript Name: Move edit cursor to time 0 or to project start
 * About: Move edit cursor to time 0 if project start is negative or null. Move edit cursor to project start if project start is > 0.
 * Instructions: Here is how to use it. (optional)
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Version: 1.0
 * Version Date: 2015-02-28
 * REAPER: 5.0 pre 15
 * Extensions: SWS/S&M 2.6.0 (optional)
--]]

--[[
 * Changelog:
 * v1.0 (2015-02-28)
  + Initial Release
  + Thanks to benf for the help on format_timestr_pos
  + Thanks to spk77 for his Clock.eel script
--]]

function main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  if reaper.GetPlayState() == 0 or reaper.GetPlayState == 2 then
    cursor_pos = reaper.GetCursorPosition()
    --msg_stl("proj time decimal", cursor_pos, 1)

    buf = reaper.format_timestr_pos(cursor_pos, "", 3)
    --msg_stl("proj time string", buf, 1)

    time = tonumber(buf)
    --msg_ftl("proj time decimal", time, 1)

    offset = cursor_pos - time
    --msg_ftl("offset", time, 1)

    reaper.SetEditCurPos(offset, 1, 0)
  end



  reaper.Undo_EndBlock("Move edit cursor to time 0 or to project start", 0) -- End of the undo block. Leave it at the bottom of your main function.

end



main() -- Execute your main function

reaper.UpdateArrange() -- Update the arrangement (often needed)


