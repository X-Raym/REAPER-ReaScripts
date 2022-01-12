--[[
 * ReaScript Name: Color selected items according to their source file name
 * Screenshot: https://i.imgur.com/cIgOvSi.gif
 * Author: X-Raym
 * Author URI: http://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]

--[[
 * v1.0 ( 2021-09-29 )
  + Initial release
--]]

console = false

function Msg(value)
  if console then
    reaper.ShowConsoleMsg(tostring(value) .. "\n")
  end
end

-- Lua port of // https://stackoverflow.com/questions/3426404/create-a-hexadecimal-colour-based-on-a-string-with-javascript
function stringToColour(str)
  local hash = 0
  for i = 1, #str do
    hash = string.byte( string.sub(str, i, i+1) ) + (  (hash << 5) - hash)
  end
  local colour = '#'
  for i = 0, 2 do
    local value = (hash >> (i * 8)) & 0xFF
    colour = colour .. ( string.sub('00' .. string.format('%02X', tostring(value)),-2))
  end
  return colour
end

function GetStringFromMIDIbytes( buf )
  local pos=1
  local main_out = ""
  while pos <= buf:len() do

    local offs,flag,msg=string.unpack("IBs4",buf,pos)
    local adv=4+1+4+msg:len() -- int+char+int+msg

    local out="+"..offs.."\t"
    for j=1,msg:len() do out=out..string.format("%02X ",msg:byte(j)) end
    if flag ~= 0 then out=out.."\t" end
    if flag&1 == 1 then out=out.."sel " end          if flag&2 == 2 then out=out.."mute " end
    main_out = main_out .. "\n" .. out
    pos=pos+adv
  end
  return main_out
end

function HexToRGB( hex )
  local hex = hex:gsub("#","")
  local R = tonumber("0x"..hex:sub(1,2))
  local G = tonumber("0x"..hex:sub(3,4))
  local B = tonumber("0x"..hex:sub(5,6))
  return R, G, B
end

function HexToInt( hex )
  local r, g, b = HexToRGB( hex )
  local int =  reaper.ColorToNative( r, g, b )|16777216
  return int
end

function GetTakeSource(take)
  local source =  reaper.GetMediaItemTake_Source( take )
  if not source then return nil end
  local source_section = reaper.GetMediaSourceParent( source ) -- Necesseary for reversed section cause reversed section have 'SECTION' section type
  if source_section then source = source_section end
  return source
end

function Main()
  for i = 0, count_sel_items do
    local item = reaper.GetSelectedMediaItem(0,i)
    if item then
      local take = reaper.GetActiveTake( item )
      if take and not reaper.TakeIsMIDI( take ) then
        local source = GetTakeSource(take)
        if source then
          local source_filename = reaper.GetMediaSourceFileName( source, "" )
          local color_hex = stringToColour(source_filename)
          local color_int = HexToInt(color_hex)
          reaper.SetMediaItemTakeInfo_Value(take, "I_CUSTOMCOLOR", color_int)
        end
      end
    end
  end
end

-- See if there is items selected
count_sel_items = reaper.CountSelectedMediaItems(0)

if count_sel_items > 0 then

  reaper.PreventUIRefresh(1)

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  reaper.ClearConsole()

  Main()

  reaper.Undo_EndBlock("Color selected items according to their source file name", -1) -- End of the undo block. Leave it at the bottom of your main function.

  reaper.UpdateArrange()

  reaper.PreventUIRefresh(-1)

end
