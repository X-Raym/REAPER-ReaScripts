--[[
 * ReaScript Name: Copy filtered action names list to clipboard
 * About: Copy actions names to clipboard if they pass the filter.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > REAPER ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 6.0
 * Version: 1.1
--]]
 
--[[
 * Changelog:
 * v1.1 (2023-01-24)
  + Prevent duplicates
  + Sort table
 * v1.0 (2022-12-14)
  + Initial Release
 --]]
 
contexts = { ["Main"] = 0, ["Main (alt recording)"]=100, ["MIDI Editor"] = 32060, ["MIDI Event List Editor"] = 32061, ["MIDI Inline Editor"] = 32062, ["Media Explorer"] = 32063 }

lines = {}

function Msg( val )
  reaper.ShowConsoleMsg( tostring( val ) .. "\n" )
end

function GetTableOfSortedKeys( t )
  if not t or type(t) ~= "table" then return end
  local keys = {}
  for k, v in pairs( t ) do
    table.insert( keys, k )
  end
  table.sort( keys )
  return keys
end

function Main()
  for k, v in pairs( contexts ) do
    local i = 0
    repeat
      local retval, name = reaper.CF_EnumerateActions( v, i )
      -- Filter actions starting with "beta_" or having "test" in their name
      if retval > 0 and not name:lower():find("beta_") and not name:lower():find("test") then
        lines[name] = true
      end
      i = i + 1
    until retval <= 0
  end
  
  reaper.CF_SetClipboard( table.concat( GetTableOfSortedKeys(lines), "\n" ) )
end

if not reaper.CF_GetClipboard then
  reaper.ShowMessageBox( 'Please Install last SWS extension.', 'Missing Dependency', 0 )
  return false
end

reaper.defer(Main)
