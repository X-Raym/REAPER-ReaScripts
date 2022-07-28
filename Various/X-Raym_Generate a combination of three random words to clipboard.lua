--[[
 * ReaScript Name: Generate a combination of three random words to clipboard
 * Screenshot: https://i.imgur.com/8ypsGkC.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0.2
--]]

-- USER CONFIG AREA ------------------------------------------------------

strings = {}
strings[1] = {"Nice", "Fancy", "Great", "Awesome", "Cool", "Extra", "Super", "Hyper"}
strings[2] = {"Blue", "Red", "Green", "Orange", "Yellow", "Black", "White", "Pink", "Purple", "Brown"}
strings[3] = {"Jabies", "Chird", "Sleaty", "Mactor", "Rade", "Cawn", "Fung", "Cruckles", "Squair", "Hotters", "Pooden", "Glottle", "Mokerel", "Creppermint", "Cound", "Pimming", "Tooden", "Slace", "Jicking", "Smottle", "Moggling", "Florse", "Molice", "Rorse", "Mippery", "Wate", "Micy", "Wosty", "Snealthy", "Skilk", "Plups", "Fingling", "Sluddy", "Bluck", "Mocolate", "Soods", "Flordon", "Soast", "Castic", "Lindow", "Clottery", "Wheeth", "Wipped", "Chorton", "Yine", "Boad", "Miscuits", "Pippers", "Stimb", "Fiff"} -- https://jimpix.co.uk/words/word-generator.asp#results made up workds

console = true

-------------------------------------------------- END OF USER CONFIG AREA

math.randomseed( reaper.time_precise() * 1000 )

function Msg(val)
  if console then
    reaper.ShowConsoleMsg( tostring(val) .. "\n" )
  end
end

function Init() -- The Init function of the script.
  str = ""
  for i, v in ipairs( strings ) do
    str = str .. "" .. v[ math.random( #v ) ]
  end
  Msg(str)
  reaper.CF_SetClipboard( str )
end

if not preset_file_init then -- If the file is run directlyn it will execute Init(), else it will wait for Init() to be called explicitely from the preset scripts (usually after having modified some global variable states).
  Init()
end
