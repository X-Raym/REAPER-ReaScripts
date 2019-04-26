-- @description Sort all tracks alphabetically
-- @author X-Raym, MPL
-- @website http://forum.cockos.com/showpost.php?p=1574912&postcount=1078
-- @screenshot http://i.giphy.com/3oEdv7ULuP7JOEeHUQ.gif
-- @version 1.2
-- @changelog
--    # (MPL) rebuild with ReorderSelectedTracks(), require REAPER 5.90rc7+
--    # (MPL) perform comparing numbers, if they placed at the string start
--    # (MPL) fix Undo
--    # (MPL) fix response to MsgBox

--[[ * Licence: GPL v3
 * REAPER: 5.90
 * Extensions: SWS 2.8.0
--]]
	
	
	-------------------------------------------------------------------------------------
	
	
	function SortAllTracksAlphabetically()
	  -- collect selected tracks names -------------
		 tr_t = {}
		local cnt_tr = reaper.CountTracks(0)                    
		for i =1, cnt_tr do
		  local tr = reaper.GetTrack(0,i-1)
		  tr_t[#tr_t+1] = { GUID = reaper.GetTrackGUID( tr ),
						name =  ({reaper.GetSetMediaTrackInfo_String( tr, 'P_NAME', '', 0 )})[2]}   
		end
		
	  -- actually sort table -------------
		table.sort(tr_t,    function(a,b) 
							local cond = a.name<b.name 
							local p = '[%d%.]+'
							if a.name:match(p) and b.name:match(p) then
								local a_num = tonumber(a.name:match(p))
								local b_num = tonumber(b.name:match(p))
								if a_num ~= nil and b_num ~= nil then
									cond = a_num<b_num
								else
									cond = false
								end
							end
							return cond
						end )
								
	  -- move tracks -------------
	    for i =  #tr_t, 1, -1 do
		 local tr = reaper.BR_GetMediaTrackByGUID( 0, tr_t[i].GUID )
		 reaper.SetOnlyTrackSelected( tr )
		 reaper.ReorderSelectedTracks(0, 0)
	    end           
					   
	end     
	
	
	-------------------------------------------------------------------------------------
	
	
	
	if reaper.APIExists( 'ReorderSelectedTracks' ) then
		retval = reaper.MB('It is strongly recommended to make a backup.\nProcess sort tracks?', "Warning", 1)
		if retval == 1 then          
			reaper.Undo_BeginBlock()
			SortAllTracksAlphabetically()
			reaper.Undo_EndBlock( 'Sort all tracks alphabetically', -1 )
		end
	 else
	  reaper.MB('Require REAPER 5.90rc7+','Error',0)
	end
	
