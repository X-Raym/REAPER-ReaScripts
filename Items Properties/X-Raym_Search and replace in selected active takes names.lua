--[[
 * ReaScript Name: Search and replace in selected active takes names
 * Screenshot: http://i.giphy.com/3oEdv3tKb0CpB7VCtq.gif
 * Author: X-Raym
 * Author URI: https://extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Items Properties (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1574814#post1574814
 * REAPER: 5.0
 * Version: 1.2.2
--]]

--[[
 * Changelog:
 * v1.2.2 (2022-03-29)
  # Fix defaut csv (thx nicola!)
 * v1.2.1 (2022-03-21)
  # Fix /E
 * v1.2 (2021-02-19)
  + Select item with matches
 * v1.1.1 (2021-02-27)
  + Preset file support
 * v1.1 (2015-12-10)
  + User Config Area
 * v1.0 (2015-10-08)
  + Initial Release
--]]

-- USER CONFIG AREA ---------------------------------------------
-- Do you want a pop up to appear ?
popup = true -- true/false

-- Define here your default variables values
search = "word" -- % for escaping characters
replace = "/del" -- "/del" for deletion
truncate_start = "0"
truncate_end = "0"
ins_start_in = "/no" -- "/no" for no insertion, "/E" for item number in selection, "/T" for track name
ins_end_in = "/no" -- "/no" for no insertion, "/E" for item number in selection, "/T" for track name
select_renamed = "y" -- y/n for select item with renamed
-----------------------------------------------------------------
function Msg(val)
  reaper.ShowConsoleMsg(tostring(val) .. "\n")
end


function main()

  reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

  select_renamed_items = {}

  -- INITIALIZE loop through selected items
  for i = 0, sel_items_count-1  do
    -- GET ITEMS
    item = reaper.GetSelectedMediaItem(0, i) -- Get selected item i

  take = reaper.GetActiveTake(item)

  if take ~= nil then

    -- GET NAMES
    take_name = reaper.GetTakeName(take)
    original_take_name = take_name

    track = reaper.GetMediaItem_Track(item)
    retval, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)


    -- MODIFY NAMES
    replace = replace:gsub("/T", track_name)
    take_name = take_name:gsub(search, replace)

    truncate_start = tonumber(truncate_start)
    truncate_end = tonumber(truncate_end)
    if truncate_start > 0 and truncate_start ~= nil then take_name = take_name:sub(truncate_start+1) end
    if truncate_end > 0 and truncate_end ~= nil then
      take_name_len = take_name:len()
      take_name = take_name:sub(0, take_name_len-truncate_end)
    end
    
    ins_start = ins_start_in:gsub("/E", tostring(i + 1))
    ins_start = ins_start:gsub("/T", track_name)

    ins_end = ins_end_in:gsub("/E", tostring(i + 1))
    ins_end = ins_end:gsub("/T", track_name)

    new_take_name = ins_start..take_name..ins_end

    if select_renamed == "y" and original_take_name ~= new_take_name then
      table.insert(select_renamed_items, item)
    end

    -- SETNAMES
    reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", new_take_name, true)

  end

  end -- ENDLOOP through selected items

  if select_renamed == "y" then
  reaper.SelectAllMediaItems(0, false)
  for i, item in ipairs(select_renamed_items) do
    reaper.SetMediaItemSelected( item, true )
  end
  end

  reaper.Undo_EndBlock("Search and replace in selected active takes names", -1) -- End of the undo block. Leave it at the bottom of your main function.

end

function Init()
  -- START
  sel_items_count = reaper.CountSelectedMediaItems(0)

  if sel_items_count > 0 then

    if popup == true then

      defaultvals_csv = search .. "," .. replace .. "," .. truncate_start .. "," .. truncate_end .. "," .. ins_start_in .. "," .. ins_end_in .. "," .. select_renamed

      retval, retvals_csv = reaper.GetUserInputs("Search & Replace", 7, "Search (% for escape char),Replace (/del for deletion),Truncate from start,Truncate from end,Insert at start (/E = Sel Num),Insert at end (/T = track name),Select renamed only? (y/n)", defaultvals_csv)

      if retval then -- if user complete the fields

        search, replace, truncate_start, truncate_end, ins_start_in, ins_end_in, select_renamed = retvals_csv:match("([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+),([^,]+)")

        if replace == "/del" then replace = "" end
        if ins_start_in == "/no" then ins_start_in = "" end
        if ins_end_in == "/no" then ins_end_in = "" end

        if search ~= nil then

        reaper.PreventUIRefresh(1)
        
        reaper.ClearConsole()

        main() -- Execute your main function

        reaper.PreventUIRefresh(-1)

        reaper.UpdateArrange() -- Update the arrangement (often needed)
        end

      end

    else

      reaper.PreventUIRefresh(1)

      if replace == "/del" then replace = "" end
      if ins_start_in == "/no" then ins_start_in = "" end
      if ins_end_in == "/no" then ins_end_in = "" end

      main() -- Execute your main function

      reaper.PreventUIRefresh(-1)

      reaper.UpdateArrange() -- Update the arrangement (often needed)

    end

  end
end

if not preset_file_init then
  Init()
end
