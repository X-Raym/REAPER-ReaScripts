--[[
 * ReaScript Name: Insert CC linear ramp events between selected ones if consecutive
 * Description: Interpolate multiple CC events by creating new ones. Works with multiple lanes (CC Channel).
 * Instructions: Open a MIDI take in MIDI Editor. Select Notes. Run.
 * Screenshot: http://i.giphy.com/3o6UB8vDPviM8jbXlC.gif
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * Forum Thread: Script Request Sticky? - Page 32
 * Forum Thread URI: http://forum.cockos.com/showpost.php?p=1617117&postcount=1265
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.2
--]]

--[[
 * Changelog:
 * v1.2 (2017-05-29)
	# Works with multiple CCS.
 * v1.1.1 (2016-12-10)
	# Text
 * v1.1 (2016-12-10)
	# Bug fix
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

function GetCC(take, cc)
	return cc.selected, cc.muted, cc.ppqpos, cc.chanmsg, cc.chan, cc.msg2, cc.msg3
end

function main() -- local (i, j, item, take, track)

	take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive())

	if take ~= nil then

		retval, notes, ccs, sysex = reaper.MIDI_CountEvts(take)

		if ccs == 0 then return end

		-- Store CC by types
		midi_cc = {}
		for j = 0, ccs - 1 do
			cc = {}
			retval, cc.selected, cc.muted, cc.ppqpos, cc.chanmsg, cc.chan, cc.msg2, cc.msg3 = reaper.MIDI_GetCC(take, j)
			if not midi_cc[cc.msg2] then midi_cc[cc.msg2] = {} end
			table.insert(midi_cc[cc.msg2], cc)
		end

		-- Look for consecutive CC
		cc_events = {}
		cc_events_len = 0

		for key, val in pairs(midi_cc) do

			-- GET SELECTED NOTES (from 0 index)
			for k = 1, #val - 1 do

				a_selected, a_muted, a_ppqpos, a_chanmsg, a_chan, a_msg2, a_msg3 = GetCC(take, val[k])
				b_selected, b_muted, b_ppqpos, b_chanmsg, b_chan, b_msg2, b_msg3 = GetCC(take, val[k+1])

				if a_selected == true and b_selected == true then

					-- INSERT NEW CCs
					time_interval = (b_ppqpos - a_ppqpos) / interval

					for z = 1, interval - 1 do

						cc_events_len = cc_events_len + 1
						cc_events[cc_events_len] = {}

						c_ppqpos = a_ppqpos + time_interval * z
						c_msg3 = math.floor( ( (b_msg3 - a_msg3) / interval * z + a_msg3 )+ 0.5 )

						cc_events[cc_events_len].ppqpos = c_ppqpos
						cc_events[cc_events_len].chanmsg = a_chanmsg
						cc_events[cc_events_len].chan = a_chan
						cc_events[cc_events_len].msg2 = a_msg2
						cc_events[cc_events_len].msg3 = c_msg3

					end

				end

			end

		end

		-- Insert Events
		for i, cc in ipairs(cc_events) do
			reaper.MIDI_InsertCC(take, selected, false, cc.ppqpos, cc.chanmsg, cc.chan, cc.msg2, cc.msg3)
		end

	end -- ENFIF Take is MIDI

end

-- RUN ---------------------
if prompt then
	retval, interval = reaper.GetUserInputs("Insert CC Events", 1, "Number of new events between CC?", interval)
end

if retval or prompt == false then -- if user complete the fields

	interval = tonumber(interval)

	if interval then

		reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

		interval = math.floor(interval) + 1

		main() -- Execute your main function

		reaper.UpdateArrange() -- Update the arrangement (often needed)

		reaper.Undo_EndBlock("Insert CC linear ramp events between selected ones if consecutive", -1) -- End of the undo block. Leave it at the bottom of your main function.

	end

end
