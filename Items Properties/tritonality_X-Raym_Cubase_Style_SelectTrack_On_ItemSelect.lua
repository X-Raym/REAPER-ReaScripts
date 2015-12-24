--[[
 * ReaScript Name: Select Tracks Fom Item Selection (Cubase Style)
 * Description:
 * Instructions: Run
 * Screenshot: http://i.giphy.com/3o85xpylrlY7MPzmo0.gif
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI:
 * Licence: GPL v3
 * Forum Thread: EEL: "Cubase style" select tracks from item selection
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=143470
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.0
--]]
 
--[[
  This script is a mod of Cubase_Style_SelectTrack_On_ItemSelect.eel.js
  by tritonality on 2014-07-31
  https://github.com/tritonality/ReaStuff/blob/master/Cubase_Style_SelectTrack_On_ItemSelect.eel.js
--]]

--[[
  Requested by Sexan
--]]

--[[
 * Changelog:
 * v1.0 (2015-10-04)
  + Initial Release
 --]]


function SelectTrack_OnItemSelect_Monitor()
	stored={}
	stored_t={}
	stored_total = 0
	
	-- Clear old items.
	if stored_total > 0 then
		for i=0, stored_total - 1 do

			re_do=false
			has_selected=false
			new_stored=false
			deleted=false
			
			selected=reaper.IsMediaItemSelected(stored[i])
			t = reaper.GetMediaItem_Track(stored[i])
			if t == nil then deleted = true end
			
			if t ~= stored_t[i] then
				new_stored=true
			end
			
			--Deselect the track if it moved or it no longer has selected items and there's >=1 other track(s) selected.
			if reaper.IsTrackSelected(stored_t[i]) and (new_stored or (not selected and stored_total > 1) ) then
				t_items=reaper.CountTrackMediaItems(stored_t[i])
				if t_items > 0 then
					k=0
					sel_count=reaper.CountSelectedMediaItems(0)
					while (k<=sel_count and not has_selected) do
						si=reaper.GetSelectedMediaItem(0, k)
						if stored[i]~=si then 
							if stored_t[i]==reaper.GetMediaItem_Track(si) then has_selected=true end
						    end
						k = k + 1
					end		
				end
				
				if not has_selected then reaper.SetMediaTrackInfo_Value(stored_t[i], "I_SELECTED", 0) end
			end
				
			if new_stored then
				stored_t[i]=t
				reaper.SetMediaTrackInfo_Value(stored_t[i], "I_SELECTED", 1)
			end
			
			if not selected then
				if stored_total == 1 then
					
					thenstored[i]=0
					stored_t[i]=0
					
				else
					-- Inline the list.
					stored[i] = stored[stored_total-1] 
					stored_t[i] = stored_t[stored_total-1] 
					
					stored[stored_total-1] = 0 
					stored_t[stored_total-1] = 0 
					
					re_do=true
				end
				stored_total=stored_total-1
			end
		if re_do then i = i - 1 end
		end
	end
	
	-- Find and evaluate new items.
	items = reaper.CountSelectedMediaItems(0)
	if items == 0 then
		stored_total=0
	else

		for i = 0, items - 1 do
			
			sel_item = reaper.GetSelectedMediaItem(0, i)
			found=false
			
			-- Check for old item
			if stored_total > 0 then
				j=0 
				while (j<=stored_total and not found) do
					if sel_item == stored[j] then found=true end	
					j=j+1
				end
			end
			
			-- Found new item
			if found == false then
				stored[stored_total]=sel_item
				stored_t[stored_total]=reaper.GetMediaItem_Track(sel_item)
				
				if stored_total+1 > 1 then 
					reaper.SetMediaTrackInfo_Value(stored_t[stored_total], "I_SELECTED", 1)
				else
					reaper.Main_OnCommand(40297, 0)
					reaper.SetMediaTrackInfo_Value(stored_t[stored_total], "I_SELECTED", 1)
				end
				
				stored_total = stored_total + 1
			end
			
		end
		
	end
	reaper.defer(SelectTrack_OnItemSelect_Monitor)
end

SelectTrack_OnItemSelect_Monitor()
