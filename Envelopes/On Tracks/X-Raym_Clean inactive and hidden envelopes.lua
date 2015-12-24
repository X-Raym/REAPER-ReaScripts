--[[
 * ReaScript Name: Clean inactive and hidden envelopes
 * Description: A way to reset clean envelopes.
 * Instructions: Select tracks with visible and armed envelopes. Execute the script. Note that if there is an envelope selected, it will work only for it.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI:
 * Licence: GPL v3
 * Forum Thread: Scripts (Lua): Multiple Tracks and Multiple Envelope Operations
 * Forum Thread URI: http://forum.cockos.com/showthread.php?t=157483
 * REAPER: 5.0 RC5
 * Extensions: SWS 2.7.3 #0
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2015-07-22)
  + Initial release
 --]]

function Msg(var)
	reaper.ShowConsoleMsg(tostring(var))
end

function Action(env)
  retval, xml_env = reaper.GetEnvelopeStateChunk(env, "", false)
  xml_env = xml_env:gsub("\n", "¤¤")
  retval, xml_env = reaper.SetEnvelopeStateChunk(env, xml_env, false)
return xml_env

end

function main() -- local (i, j, item, take, track)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
  
  edit_pos = reaper.GetCursorPosition()

 selected_tracks_count = reaper.CountSelectedTracks(0)
    
    -- if selected_tracks_count > 0 and UserInput() then
    if selected_tracks_count > 0 then
      for i = 0, selected_tracks_count-1  do
        
        -- GET THE TRACK
        track = reaper.GetSelectedTrack(0, i) -- Get selected track i

        -- LOOP THROUGH ENVELOPES
        env_count = reaper.CountTrackEnvelopes(track)
        for j = 0, env_count-1 do

          -- GET THE ENVELOPE
          env = reaper.GetTrackEnvelope(track, j)
      
      if env ~= nil then
      br_env = reaper.BR_EnvAlloc(env, false)
      
      active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, type, faderScaling = reaper.BR_EnvGetProperties(br_env, true, true, true, true, 0, 0, 0, 0, 0, 0, true)

    -- IF ENVELOPE IS A CANDIDATE
    if visible == false and active == false then
          
          retval, xml_track = reaper.GetTrackStateChunk(track, "", false)
          
          xml_track = xml_track:gsub("\n", "¤¤")
          
          xml_env =  Action(env)
          
          -- xml_track = xml_track:gsub(xml_env, "")
          
          -- xml_track = xml_track:gsub("¤¤", "\n")
		   -- Msg(xml_track)
          
          --retval = reaper.SetTrackStateChunk(track, xml_env, false)
      
    end
      
      reaper.BR_EnvFree(br_env, 0)

        end -- ENDLOOP through envelopes
    
    end

      end -- ENDLOOP through selected tracks
  
  end -- endif sel envelope
  
  reaper.Undo_EndBlock("Clean inactive and hidden envelopes", 0) -- End of the undo block. Leave it at the bottom of your main function.

end -- end main()

reaper.PreventUIRefresh(-1)
main()
reaper.UpdateArrange()
reaper.PreventUIRefresh(1)

function HedaRedrawHack()
  reaper.PreventUIRefresh(1)

  track=reaper.GetTrack(0,0)

  trackparam=reaper.GetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT")  
  if trackparam==0 then
    reaper.SetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT", 1)
  else
    reaper.SetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT", 0)
  end
  reaper.SetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT", trackparam)

  reaper.PreventUIRefresh(-1)
  
end

HedaRedrawHack()
