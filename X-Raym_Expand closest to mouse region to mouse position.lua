-- Expand closest to mouse region to mouse position
-- EEL Script for Reaper
-- Author : X-Raym
-- Author URl : http://extremraym.com
-- Source : GitHub > X-Raym > EEL Scripts for Cockos REAPER
-- Source URl : https://github.com/X-Raym/REAPER-EEL-Scripts
-- Licence : GPL v3
-- Release Date : 05-01-2015

-- Version : 0.1
-- Version Date : 05-01-2015
-- Required : Reaper 4.76

-- Some debugg functions
function msg(m)

  reaper.ShowConsoleMsg(m)
  reaper.ShowConsoleMsg("\n")

end


function msg_d(m)

  str = string.format("%d", m)
  reaper.ShowConsoleMsg(str)
  reaper.ShowConsoleMsg("\n")

end


function msg_f(m)

  str = string.format("%f", m)
  reaper.ShowConsoleMsg(str)
  reaper.ShowConsoleMsg("\n")

end

-- The real stuff
function expand_region_to_mouse()

  reaper.ShowConsoleMsg("=====>\n")
  reaper.ShowConsoleMsg("DEBUG\n")
  reaper.ShowConsoleMsg("-----\n")
  
  cursPos = reaper.BR_PositionAtMouseCursor(true)
  msg_d(cursPos)

end

expand_region_to_mouse()
