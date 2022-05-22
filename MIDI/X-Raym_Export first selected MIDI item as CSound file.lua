--[[
 * ReaScript Name: Export first selected MIDI items as CSound file
 * About: For now it just displays the MIDI note in the console iN CSound format, as nothing more was needed.
 * Author: X-Raym
 * Author URI: http://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2022-05-22)
  + Initial Release
--]]

reaper.ClearConsole()

-- Add Leading Zeros to A Number
function AddLeadingSpaces(str, spaces)
  str = tostring( str )
  for i = #str + 1, spaces do
    str = " " .. str
  end
  return str
end

-- Add Traling Zeros to A Number
function AddDecimalTrailingZeros(number, zeros)
  local zeros_str = ""
  number = round( number, 4 )
  local str = tostring( number )
  local integer, decimal = str:match("(.+)%.(.+)")
  for i = #decimal, zeros do
    zeros_str = zeros_str .. "0"
  end
  return integer .. "." .. decimal .. zeros_str
end

-- Round at two decimal
-- By Igor Skoric
function round( val, num )
  local mult = 10^(num or 0)
  if val >= 0 then return math.floor(val * mult + 0.5) / mult
  else return math.ceil(val*mult-0.5) / mult end
end

function AddLeadingAndTraling( str, leading, trailing )
  return AddLeadingSpaces( AddDecimalTrailingZeros(str, trailing), leading )
end

messages = {}
function Msg( val )
  reaper.ShowConsoleMsg( tostring( val ) .. "\n" )
end

function Msg2( val )
  table.insert( messages, tostring( val ) )
end

item = reaper.GetSelectedMediaItem(0,0)
if not item then return false end

take = reaper.GetActiveTake( item )
if not take or not reaper.TakeIsMIDI( take ) then return false end

retval, count_notes = reaper.MIDI_CountEvts( take )

for i = 0, count_notes - 1 do
  -- Get notes
  retval, selected, muted, startppqpos, endppqpos, chan, pitch, vel = reaper.MIDI_GetNote( take, i )
  
  -- Conversion in seconds
  pos_start =  reaper.MIDI_GetProjTimeFromPPQPos( take, startppqpos )
  pos_end = reaper.MIDI_GetProjTimeFromPPQPos( take, endppqpos )
  length = pos_end - pos_start
  
  Msg2("i 1\t" .. AddLeadingAndTraling(pos_start, 10, 3 ) .. "\t" .. AddLeadingAndTraling(length, 10, 3 ) .. "\t" .. AddLeadingSpaces(pitch, 3) .. "\t" .. AddLeadingSpaces(vel, 3) )
end

Msg( table.concat(messages, "\n") )
