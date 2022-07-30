--[[
 * ReaScript Name: Open most recent project
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > ReaScripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0.1
--]]

--[[
 * Changelog:
  * v1.0.1 (2022-07-30)
    # maxrecent taken into account
--]] 

function DisplayTooltip(message)
  local x, y = reaper.GetMousePosition()
  reaper.TrackCtl_SetToolTip( tostring(message), x+17, y+17, false )
end

function Msg( val )
  reaper.ShowConsoleMsg( tostring(val)..'\n' )
end

reaper.ClearConsole()

-- based on ReaScript name: Open recent projects in new tab by BuyOne
-- collect recent project paths
recent_pojs = {}
for line in io.lines(reaper.get_ini_file()) do
  if line:match('maxrecent=(%d+)') then -- we check max cause if max was higher at some point, there may still be some residual .rpp reference which are not replaced.
    maxrecent = tonumber( line:match('maxrecent=(%d+)') )
  end
  if line == '[Recent]' then
    found = true 
  elseif found and line:match('%[.-%]') and line ~= '[Recent]' then
    break
  end 
  
  if found and line ~= '[Recent]' then -- collect paths excluding the section name
    local id = tonumber( line:match( 'recent(%d+)=' ) )
    if id then
      if not maxrecent or id <= maxrecent then
        recent_pojs[id] = line:gsub('recent%d+=','')
      end
    end -- or line:match('=(.+)') // strip away the key          
  end

end

if #recent_pojs == 0 then return end

if reaper.file_exists( recent_pojs[#recent_pojs] ) then
  reaper.Main_openProject( recent_pojs[#recent_pojs] )
else
  DisplayTooltip( recent_pojs[#recent_pojs] .. "\nFile not found." )
end
