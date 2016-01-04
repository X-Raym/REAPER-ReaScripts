--[[
 * ReaScript Name: Insert CC linear ramp events between selected ones if consecutive
 * Description: See title.
 * Instructions: Open a MIDI take in MIDI Editor. Select Notes. Run.
 * Screenshot: http://i.giphy.com/3o6UB8vDPviM8jbXlC.gif
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script Request Sticky? - Page 32
 * Forum Thread URI: http://forum.cockos.com/showpost.php?p=1617117&postcount=1265
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2016-01-04)
	+ Initial Release
 --]]

-- USER CONFIG AREA ---------------------

interval = "2"
prompt = true -- User input dialog box
selected = false -- new notes are selected

----------------- END OF USER CONFIG AREA


-- Console Message
function Msg(g)
  reaper.ShowConsoleMsg(tostring(g).."\n")
end


function main() -- local (i, j, item, take, track)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive())

  if take ~= nil then

    retval, notes, ccs, sysex = reaper.MIDI_CountEvts(take)

    cc_events = {}
    cc_events_len = 0

    -- GET SELECTED NOTES (from 0 index)
    for k = 0, ccs-2 do

      a_retval, a_selected, a_muted, a_ppqpos, a_chanmsg, a_chan, a_msg2, a_msg3 = reaper.MIDI_GetCC(take, k)
      b_retval, b_selected, b_muted, b_ppqpos, b_chanmsg, b_chan, b_msg2, b_msg3 = reaper.MIDI_GetCC(take, k+1)

      if a_selected == true and b_selected == true then

        time_interval = (b_ppqpos - a_ppqpos) / interval
        cc_interval = math.floor(((b_msg3 - a_msg3) / interval)+0.5)

        for z = 1, interval - 1 do

          cc_events_len = cc_events_len + 1
          cc_events[cc_events_len] = {}

          c_ppqpos = a_ppqpos + time_interval * z
          c_msg3 = a_msg3 + cc_interval * z

          cc_events[cc_events_len].ppqpos = c_ppqpos
          cc_events[cc_events_len].chanmsg = a_chanmsg
          cc_events[cc_events_len].chan = a_chan
          cc_events[cc_events_len].msg2 = a_msg2
          cc_events[cc_events_len].msg3 = c_msg3

        end

      end

    end

    for i, cc in ipairs(cc_events) do
      reaper.MIDI_InsertCC(take, selected, false, cc.ppqpos, cc.chanmsg, cc.chan, cc.msg2, cc.msg3)
    end

    end -- ENFIF Take is MIDI

    reaper.Undo_EndBlock("Insert CC linear ramp events between selected ones if consecutive", -1) -- End of the undo block. Leave it at the bottom of your main function.

  end

if prompt == true then
  retval, interval = reaper.GetUserInputs("Insert CC Events", 1, "Number of Events to insert?", interval)
end

if retval or prompt == false then -- if user complete the fields

  interval = tonumber(interval)

  if interval ~= nil then

    interval = math.floor(interval)

    main() -- Execute your main function

    reaper.UpdateArrange() -- Update the arrangement (often needed)

  end

end
