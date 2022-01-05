--[[
 * ReaScript Name: Convert tempo and time signature markers into project markers
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1564860
 * REAPER: 5.0 pre 15
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2015-07-12)
  + Initial Release
--]]



color = "#FF0000"

function HexToInt(value)
  hex = value:gsub("#", "")
  R = tonumber("0x"..hex:sub(1,2))
  G = tonumber("0x"..hex:sub(3,4))
  B = tonumber("0x"..hex:sub(5,6))

  color_int = (R + 256 * G + 65536 * B)|16777216

  return color_int

end

function main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  count_tempo_markers = reaper.CountTempoTimeSigMarkers(0)

  if count_tempo_markers > 0 then

    for i = 0, count_tempo_markers - 1 do

    retval, pos, measure_pos, beat_pos, bpm, timesig_num, timesig_denom, lineartempoOut = reaper.GetTempoTimeSigMarker(0, i)

    bpm = tostring(bpm)
    x, y = string.find(bpm, ".0")
    if y ==  string.len(bpm) - 2 then
      bpm = string.sub(bpm, 0, -3)
    end

    if timesig_num == 0 then timesig_num = 4 end
    if timesig_denom == 0 then timesig_denom = 4 end

    name = tostring(bpm).." BPM - "..tostring(timesig_num).."/"..tostring(timesig_denom)

    color_int = HexToInt(color)

    reaper.AddProjectMarker2(0, false, pos, 0, name, -1, color_int)

    end

  end

  reaper.Undo_EndBlock("Convert tempo and time signature markers into project markers", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

main() -- Execute your main function

reaper.UpdateArrange() -- Update the arrangement (often needed)