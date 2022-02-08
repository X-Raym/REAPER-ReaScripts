--[[
 * ReaScript Name: Uppercase selected items notes
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 2.0.3
]]


--[[
 * Changelog:
 * v1.0 (2022-02-08)
  + Initial Release
]]

local info = debug.getinfo(1,'S');
script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
dofile(script_path .. "../../Functions/utf8.lua")
dofile(script_path .. "../../Functions/utf8data.lua")

function main()

  reaper.Undo_BeginBlock() -- Begin undo group


  for i = 0, count_sel_items - 1 do

    item = reaper.GetSelectedMediaItem( 0, i)
    notes = reaper.ULT_GetMediaItemNote( item )
    reaper.ULT_SetMediaItemNote( item, utf8upper( notes ) )

  end

  reaper.Undo_EndBlock("Uppercase selected items notes", -1) -- End undo group

end

-- RUN

count_sel_items = reaper.CountSelectedMediaItems( 0 )

if count_sel_items > 0 then

  reaper.PreventUIRefresh(1)

  main()

  reaper.UpdateArrange()

  reaper.PreventUIRefresh(-1)

end
