--[[
 * ReaScript Name: Rename and recolor tracks created by Vordio from a Premiere Pro XML export
 * About: A way to quickly rename and recolor tracks in a REAPER project created by Vordio from a Premiere Pro project. Note that track recogbnition is based on track name, so try to avoid track name that contains a premiere pro label ID, if you don't wont them to be renamed/colorized.
 * Instructions: Edit the User Area part of the script if you want to change the default naming and colors. Run.
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Video & Sound Editors Will Really Like This
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1539710
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2015-07-01)
  + Initial Release
--]]


--> >>>>> USER AREA =========>

  -- NAMES
  -- Rename this variable with your desired name.
  -- colorName = "Track name you want"

  violet = "Violet"
  iris = "Iris"
  caribbean = "Caribbean"
  lavender = "Lavender"
  cerulean = "Cerulean"
  forest = "Forest"
  rose = "Rose"
  mango = "Mango"


  -- COLORS
  -- Put your desired Hex values here
  -- colorVal = "Hex of color you want"

  violet_hex = "#A690E0"
  iris_hex = "#729ACC"
  caribbean_hex = "#2AD698"
  lavender_hex = "#E384E3"
  cerulean_hex = "#2EBFDE"
  forest_hex = "#52B858"
  rose_hex = "#F76FA4"
  mango_hex = "#EDA63B"

--< <<<<< END OF USER AREA <=========



function ColorHexTrack(track, hex)
  hex = hex:gsub("#", "")
  R = tonumber("0x"..hex:sub(1,2))
  G = tonumber("0x"..hex:sub(3,4))
  B = tonumber("0x"..hex:sub(5,6))
  color_int = (R + 256 * G + 65536 * B)|16777216
  reaper.SetMediaTrackInfo_Value(track, "I_CUSTOMCOLOR", color_int)
end

function main(csv)

  violet, iris, caribbean, lavender, cerulean, forest, rose, mango = csv:match("([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)")

  if violet ~= nil then -- if match

  recolor = reaper.ShowMessageBox("Recolor tracks with Premiere Pro label colors?", "Recolor", 4)

  if violet == "/del" then violet = "" end
  if iris == "/del" then iris = "" end
  if caribbean == "/del" then caribbean = "" end
  if lavender == "/del" then lavender = "" end
  if cerulean == "/del" then cerulean = "" end
  if forest == "/del" then forest = "" end
  if rose == "/del" then rose = "" end
  if mango == "/del" then mango = "" end

  for i = 0, tracks_count - 1 do

    track = reaper.GetTrack(0, i)
    track_name_retval, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)

    x_violet, y_violet = track_name:find("Violet")
    if x_violet ~= nil then
    track_name = track_name:gsub("Violet", violet)
    if recolor == 6 then
      ColorHexTrack(track, violet_hex)
    end
    end

    x_iris, y_iris = track_name:find("Iris")
    if x_iris ~= nil then
    track_name = track_name:gsub("Iris", iris)
    if recolor == 6 then
      ColorHexTrack(track, iris_hex)
    end
    end

    x_caribbean, y_caribbean = track_name:find("Caribbean")
    if x_caribbean ~= nil then
    track_name = track_name:gsub("Caribbean", caribbean)
    if recolor == 6 then
      ColorHexTrack(track, caribbean_hex)
    end
    end

    x_lavender, y_lavender = track_name:find("Lavender")
    if x_lavender ~= nil then
    track_name = track_name:gsub("Lavender", lavender)
    if recolor == 6 then
      ColorHexTrack(track, lavender_hex)
    end
    end

    x_cerulean, y_cerulean = track_name:find("Cerulean")
    if x_cerulean ~= nil then
    track_name = track_name:gsub("Cerulean", cerulean)
    if recolor == 6 then
      ColorHexTrack(track, cerulean_hex)
    end
    end

    x_forest, y_forest = track_name:find("Forest")
    if x_forest ~= nil then
    track_name = track_name:gsub("Forest", forest)
    if recolor == 6 then
      ColorHexTrack(track, forest_hex)
    end
    end

    x_rose, y_rose = track_name:find("Rose")
    if x_rose ~= nil then
    track_name = track_name:gsub("Rose", rose)
    if recolor == 6 then
      ColorHexTrack(track, rose_hex)
    end
    end

    x_mango, y_mango = track_name:find("Mango")
    if x_mango ~= nil then
    track_name = track_name:gsub("Mango", mango)
    if recolor == 6 then
      ColorHexTrack(track, mango_hex)
    end
    end

    track_name_retval, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", track_name, true)

  end

  end

end


-- INIT
tracks_count = reaper.CountTracks(0)

if tracks_count > 0 then

  retval, output_csv = reaper.GetUserInputs("Vordio PPro XML Tracks Renamer", 8, "Violet (/del for deletion),Iris,Caribbean,Lavender,Cerulean,Forest,Rose,Mango", violet .. ','.. iris .. ','.. caribbean .. ','..lavender .. ','..cerulean .. ','..forest .. ','..rose .. ','..mango)

  if retval then

  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  main(output_csv)

  reaper.Undo_EndBlock("Rename and recolor tracks created by Vordio from a Premiere Pro XML export", -1) -- End of the undo block. Leave it at the bottom of your main function.

  reaper.PreventUIRefresh(-1)

  end

end
