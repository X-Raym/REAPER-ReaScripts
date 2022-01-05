--[[
 * ReaScript Name: Select items with same source as first selected item
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0.3
--]]

--[[
 * Changelog:
 * v1.0.1 (2021-04-15)
  + Initial Release
 * v1.0 (2015-08-14)
  + Initial Release
--]]

function Msg(variable)
  reaper.ShowConsoleMsg(tostring(variable).."\n")
end

function GetTakeFileSource( take )
  local source = reaper.GetMediaItemTake_Source(take)
  if not source then return false end
  local source_type = reaper.GetMediaSourceType( source, '' )
  if source_type == 'SECTION' then
    source = reaper.GetMediaSourceParent( source )
  end
  return source
end

function main()

  first_item = reaper.GetSelectedMediaItem(0, 0)

  if first_item ~= nil then

    reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

    first_take = reaper.GetActiveTake(first_item)

    if first_take then

      if reaper.TakeIsMIDI(first_take) == false then

        first_take_source = GetTakeFileSource(first_take)
        if first_take_source then
          first_take_source_name = reaper.GetMediaSourceFileName(first_take_source, "")

          items_count = reaper.CountMediaItems(0)

          for i = 0, items_count - 1  do
            -- GET ITEMS
            item = reaper.GetMediaItem(0, i) -- Get selected item i

            take = reaper.GetActiveTake(item) -- Get the active take

            if take ~= nil then -- if ==, it will work on "empty"/text items only

              if reaper.TakeIsMIDI(take) == false then

                take_source = GetTakeFileSource( take )
                if take_source then
                  take_source_name = reaper.GetMediaSourceFileName(take_source, "")

                  if take_source_name == first_take_source_name then

                    reaper.SetMediaItemSelected(item, true)

                  else

                    reaper.SetMediaItemSelected(item, false)

                  end

                end

              end

            end -- ENDIF active take

          end -- ENDLOOP through selected items

        end

      else -- else item take midi

        reaper.Main_OnCommand(41611, 0)

      end -- if audio or midi

    end -- take selection

    reaper.Undo_EndBlock("Select items with same source as first selected item", -1) -- End of the undo block. Leave it at the bottom of your main function.

  end

end

reaper.PreventUIRefresh(1) -- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

reaper.UpdateArrange() -- Update the arrangement

reaper.PreventUIRefresh(-1)  -- Restore UI Refresh. Uncomment it only if the script works.
