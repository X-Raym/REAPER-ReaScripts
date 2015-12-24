--[[
 * ReaScript Name: Display notes length at edit cursor.lua
 * Description:
 * Instructions: Run
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Tempo Calculator tool for Extensions menu?
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=116061
 * REAPER: 5.0 pre 36
 * Extensions: None
 * Version: 1.0
--]]
 
--[[ CREDITS
  This script is an adaptation in Lua of Note Lengths at Cursor.py by michaeltonight
  http://stash.reaper.fm/v/14427/Note%20Lengths%20at%20Cursor.py
  It has been moded by Dax, and converted in Lua by X-Raym.
 --]]

--[[
 * Changelog:
 * v1.0 (2015-25-06)
  + Initial Release (in Lua), moded by Dax
 * v1.0 (2012-10-26)
  + Initial Release (in Python)
 --]]

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

position = reaper.GetCursorPosition()

bpm = reaper.TimeMap2_GetDividedBpmAtTime(0, position)

bpmrounded = round(bpm, 3)

whole = round(240000/bpm)
half = round(120000/bpm)
quarter = round(60000/bpm)
eighth = round(30000/bpm)
sixteenth = round(15000/bpm)
--triplets
halftrip = round(80000/bpm)
quartertrip = round(40000/bpm)
eighthtrip = round(20000/bpm)
sixteenthtrip = round(10000/bpm)
--dotted
halfdot = round(180000/bpm)
quarterdot = round(90000/bpm)
eighthdot  = round(45000/bpm)
sixteenthdot = round(22500/bpm)

text = "BPM:                        "..tostring(bpmrounded).."\n\nWhole:                     "..tostring(whole).."\nHalf:                         "..tostring(half).."\nQuarter:                   "..tostring(quarter).."\nEighth:                     "..tostring(eighth).."\nSixteenth:                "..tostring(sixteenth).."\n_____________________________________\n".."\nHalf Triplet:             ".. tostring(halftrip).."\nQuarter Triplet:       ".. tostring(quartertrip).."\nEighth Triplet:         ".. tostring(eighthtrip).."\nSixteenth Triplet:     " .. tostring(sixteenthtrip).."\n_____________________________________\n".."\nHalf Dotted:            ".. tostring(halfdot).."\nQuarter Dotted:      ".. tostring(quarterdot).."\nEighth Dotted:        ".. tostring(eighthdot).."\nSixteenth Dotted:   " .. tostring(sixteenthdot)

reaper.ShowMessageBox(text, "Note Lengths(ms) at "..tostring(bpmrounded).." BPM", 0)
