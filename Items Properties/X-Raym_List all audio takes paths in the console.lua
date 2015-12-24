--[[
 * ReaScript Name: List all audio takes paths in the console
 * Description: A simple code snippet
 * Instructions: Run.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread:
 * Forum Thread URI:
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.1
--]]
 
--[[
 * Changelog:
 * v1.1 (2015-12-16)
	+ Minimalist report
	+ Possibility to delete duplicates sources
	+ User Config Area
	# All items real support (1.0 had a 250 items limitations)
 * v1.0 (2015-07-14)
	+ Initial Release
 --]]

-- USER CONFIG AREA --------------
duplicates = false -- (true/false): define if you want to have only different sources, or all takes sources.
---------------------------------- 

function Msg(val)
	reaper.ShowConsoleMsg(val.."\n")
end

-- Count the number of times a value occurs in a table 
function table_count(tt, item)
	local count
	count = 0
	for ii,xx in pairs(tt) do
		if item == xx then count = count + 1 end
	end
	return count
end

-- Remove duplicates from a table array
function table_unique(tt)
	local newtable
	newtable = {}
	for ii,xx in ipairs(tt) do
		if(table_count(newtable, xx) == 0) then
			newtable[#newtable+1] = xx
		end
	end
	return newtable
end
 
function main()

	sources = {}
	
	Msg("==========")
	Msg("List all audio item sources in the project")
	if duplicates then
		Msg("Display duplicates: true\n")
	else
		Msg("Display duplicates: false\n")
	end

	-- Loop in Items
	for i = 0, count_items - 1 do
		
		item = reaper.GetMediaItem(0, i)
		take = reaper.GetActiveTake(item)
		
		if take ~= nil then
			
			if reaper.TakeIsMIDI(take) == false then
				path = reaper.GetMediaSourceFileName(reaper.GetMediaItemTake_Source(take), "")	
				table.insert(sources, path)
			end
		
		end

	end
	
	if duplicates == false then
		sources = table_unique(sources)
	end
	
	-- Display results
	for i, source in ipairs(sources) do
		Msg(source)
	end
	
	if #sources > 0 then
		Msg("\nNumber of sources:" .. #sources)
	else
		Msg("\nNo audio items in this project.")
	end
	
	
	Msg("----------\n\n")

end


-- INIT
count_items = reaper.CountMediaItems(0)

if count_items > 0 then

	main()
	
end