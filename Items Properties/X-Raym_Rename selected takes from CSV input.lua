--[[
 * ReaScript Name: Rename selected takes from CSV input
 * Description: See title.
 * Instructions: Select items. Run.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Properties (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=166689
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2016-02-29)
	+ Initial Release
--]]

-- USER CONFIG AREA -----------------------------------------------------------

console = true -- true/false: display debug messages in the console
sep = "," -- default sep
names_csv = "" -- default name

------------------------------------------------------- END OF USER CONFIG AREA

-- CSV to Table
-- http://lua-users.org/wiki/LuaCsv
function ParseCSVLine (line,sep) 
	local res = {}
	local pos = 1
	sep = sep or ','
	while true do 
		local c = string.sub(line,pos,pos)
		if (c == "") then break end
		if (c == '"') then
			-- quoted value (ignore separator within)
			local txt = ""
			repeat
				local startp,endp = string.find(line,'^%b""',pos)
				txt = txt..string.sub(line,startp+1,endp-1)
				pos = endp + 1
				c = string.sub(line,pos,pos) 
				if (c == '"') then txt = txt..'"' end 
				-- check first char AFTER quoted string, if it is another
				-- quoted string without separator, then append it
				-- this is the way to "escape" the quote char in a quote. example:
				--   value1,"blub""blip""boing",value3  will result in blub"blip"boing  for the middle
			until (c ~= '"')
			table.insert(res,txt)
			assert(c == sep or c == "")
			pos = pos + 1
		else     
			-- no quotes used, just look for the first separator
			local startp,endp = string.find(line,sep,pos)
			if (startp) then 
				table.insert(res,string.sub(line,pos,startp-1))
				pos = endp + 1
			else
				-- no separator found -> use rest of string and terminate
				table.insert(res,string.sub(line,pos))
				break
			end 
		end
	end
	return res
end


-- UTILITIES -------------------------------------------------------------

-- Save item selection
function SaveSelectedItems (table)
	for i = 0, reaper.CountSelectedMediaItems(0)-1 do
		table[i+1] = reaper.GetSelectedMediaItem(0, i)
	end
end


-- Display a message in the console for debugging
function Msg(value)
	if console then
		reaper.ShowConsoleMsg(tostring(value) .. "\n")
	end
end

--------------------------------------------------------- END OF UTILITIES


-- Main function
function main()

	for i, item in ipairs(init_sel_items) do
		take = reaper.GetActiveTake(item)
		if take then
			name_out = names[i]
			if name_out then
				reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", name_out, true)
			else
				break
			end
		end
	end

end


-- INIT

-- See if there is items selected
count_sel_items = reaper.CountSelectedMediaItems(0)

if count_sel_items > 0 then

	retval, names_csv = reaper.GetUserInputs("Rename Item with CSV", 1, 'Names (separated by"' .. sep .. '")', "")
	
	if retval then
	
		reaper.PreventUIRefresh(1)
	
		reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
		
		init_sel_items =  {}
		SaveSelectedItems(init_sel_items)
		
		names = ParseCSVLine (names_csv,sep)
	
		main()
	
		reaper.Undo_EndBlock("Rename selected items from CSV input", -1) -- End of the undo block. Leave it at the bottom of your main function.
	
		reaper.UpdateArrange()
	
		reaper.PreventUIRefresh(-1)
		
	end
	
end
