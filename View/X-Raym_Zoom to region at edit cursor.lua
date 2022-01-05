--[[
 * ReaScript Name: Zoom to region at edit cursor
 * Instructions: Place cursor inside a region. Run.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0 pre 32
 * Extensions: SWS/S&M 2.7.1
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2015-05-19)
  + Initial Release
--]]

function main()

  markeridx, regionidx = reaper.GetLastMarkerAndCurRegion(0, reaper.GetCursorPosition())

  if regionidx ~= nil then

    reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

    iRetval, bIsrgnOut, iPosOut, iRgnendOut, sNameOut, iMarkrgnindexnumberOut, iColorOur = reaper.EnumProjectMarkers3(0,regionidx)
    reaper.BR_SetArrangeView(0, iPosOut, iRgnendOut)

    reaper.Undo_EndBlock("Zoom to region at edit cursor", -1) -- End of the undo block. Leave it at the bottom of your main function.

  end

end


main() -- Execute your main function


reaper.UpdateArrange() -- Update the arrangement (often needed)


