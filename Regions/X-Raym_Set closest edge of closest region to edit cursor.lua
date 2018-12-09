--[[
 * ReaScript Name: Set closest edge of closest region to edit cursor
 * Screenshot: https://i.imgur.com/ZZJOmr9.gif
 * Author: X-Raym
 * Author URI: http://www.extremraym.com/
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Regions and Markers (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=175819
 * REAPER: 5.0
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2018-12-09)
  + Initial Release
--]]


-- Main function
function main()

  cur_pos = reaper.GetCursorPosition()
  
  regions_edges = {}

  -- LOOP THROUGH REGIONS and get edges
  i=0
  repeat
    iRetval, bIsrgnOut, iPosOut, iRgnendOut, sNameOut, iMarkrgnindexnumberOut, iColorOur = reaper.EnumProjectMarkers3(0,i)
    if iRetval >= 1 then
      if bIsrgnOut then
        -- ACTION ON MARKERS HERE
          regions_edge = { pos = iPosOut, idx = iRetval }
          table.insert( regions_edges, regions_edge )
          regions_edge = { pos = iRgnendOut, idx = iRetval }
          table.insert( regions_edges, regions_edge )
      end
      i = i+1
    end
  until iRetval == 0
  
  -- Sort by Edges Pos
  table.sort(regions_edges, function( a,b )
    if (a.pos < b.pos) then
      -- primary sort on position -> a before b
      return true
    elseif (a.pos > b.pos) then
      -- primary sort on position -> b before a
      return false
    else
      -- primary sort tied, resolve w secondary sort on rank
      return a.idx < b.idx
    end
  end)
  
  -- Find closest edges
  dist = -1
  
  dest_edge = {}
  
  for i, edge in ipairs( regions_edges ) do
    if dist == -1 or math.abs( cur_pos - edge.pos ) < dist then
      dest_edge = edge
      dist = math.abs( cur_pos - edge.pos )
    end
    if math.abs( cur_pos - edge.pos ) > dist then break end
  end
  
  -- Set edge
  retval, isrgn, pos, rgnend, name, markrgnindexnumber, color = reaper.EnumProjectMarkers( dest_edge.idx -1 )
  if pos == dest_edge.pos then pos = cur_pos else rgnend = cur_pos end
  reaper.SetProjectMarker( markrgnindexnumber, true, pos, rgnend, name )
    
end

-- INIT ---------------------------------------------------------------------

total, num_markers, num_regions = reaper.CountProjectMarkers( -1 )

if num_regions > 0 then
  
  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
  
  main()
  
  reaper.Undo_EndBlock("Set closest edge of closest region to edit cursor", -1) -- End of the undo block. Leave it at the bottom of your main function.
  
  reaper.UpdateArrange()
  
end


