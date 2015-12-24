--[[
 * ReaScript Name: Display TagLib metadatas of first selected item active take
 * Description: See title
 * Instructions: Select an item. Use it.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URI: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Scripts: TagLib (various)
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1534071
 * REAPER: 5.0 pre 36
 * Extensions: SWS/S&M 2.7.1 #0
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2015-06-12)
  + Initial Release
 --]]

font_size = 20
font_name = "Arial"
window_w = 400
window_h = 250
marge = 20
marge2 = 100
line_height = 25

function init(window_w, window_h)
  gfx.init("X-Raym's TagLib Viewer" , window_w, window_h)
  gfx.setfont(1, font_name, font_size, 'b')
  gfx.a = 1
  gfx.r = 1
  gfx.g = 1
  gfx.b = 1
end

function run()
  
  item = reaper.GetSelectedMediaItem(0, 0)
  
  if item ~= nil then
    take = reaper.GetActiveTake(item)
    
    if take ~= nil and reaper.TakeIsMIDI(take) == false then
      
      line = 0
      
      retval, take_name = reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", "", false)
      src = reaper.GetMediaItemTake_Source(take)
      fn = reaper.GetMediaSourceFileName(src, "")
            
      retval_artist, tag_artist = reaper.SNM_ReadMediaFileTag(fn, "artist", "")
      retval_album, tag_album = reaper.SNM_ReadMediaFileTag(fn, "album", "")
      retval_genre, tag_genre = reaper.SNM_ReadMediaFileTag(fn, "genre", "")
      retval_comment, tag_comment = reaper.SNM_ReadMediaFileTag(fn, "comment", "")
      retval_title, tag_title = reaper.SNM_ReadMediaFileTag(fn, "title", "")
      retval_year, tag_year = reaper.SNM_ReadMediaFileTag(fn, "year", "")
      
      gfx.x = marge
      
      gfx_a = 1
      gfx.r = 255/255
      gfx.g = 255/255
      gfx.b = 16/255
	  
	  line = line + 1
      gfx.x = marge
      gfx.y = line * line_height
      gfx.printf("Take: ")
	  
	  line = line + 1
      gfx.x = marge
      gfx.y = line * line_height
      gfx.printf("Source: ")
	  
	  gfx.r = 16/255
      gfx.g = 255/255
      gfx.b = 255/255
      
      line = line + 1
      gfx.x = marge
      gfx.y = line * line_height
      gfx.printf("Title: ")
      
      line = line + 1
      gfx.x = marge
      gfx.y = line * line_height
      gfx.printf("Artist: ")
      
      line = line + 1
      gfx.x = marge
      gfx.y = line * line_height
      gfx.printf("Album: ")
      
      line = line + 1
      gfx.x = marge
      gfx.y = line * line_height
      gfx.printf("Year: ")
      
      line = line + 1
      gfx.x = marge
      gfx.y = line * line_height
      gfx.printf("Genre: ")
      
      line = line + 1
      gfx.x = marge
      gfx.y = line * line_height
      gfx.printf("Comment: ")
      
      line = 0
      gfx.r = 255/255
      gfx.g = 255/255
      gfx.b = 255/255
      
      line = line + 1
      gfx.x = marge + marge2
      gfx.y = line * line_height
      gfx.printf(take_name)
	  
	  line = line + 1
      gfx.x = marge + marge2
      gfx.y = line * line_height
      gfx.printf(fn)
	  
	  line = line + 1
      gfx.x = marge + marge2
      gfx.y = line * line_height
      gfx.printf(tag_title)
      
      line = line + 1
      gfx.x = marge + marge2
      gfx.y = line * line_height
      gfx.printf(tag_artist)
      
      line = line + 1
      gfx.x = marge + marge2
      gfx.y = line * line_height
      gfx.printf(tag_album)
      
      line = line + 1
      gfx.x = marge + marge2
      gfx.y = line * line_height
      gfx.printf(tag_year)
      
      line = line + 1
      gfx.x = marge + marge2
      gfx.y = line * line_height
      gfx.printf(tag_genre)
      
      line = line + 1
      gfx.x = marge + marge2
      gfx.y = line * line_height
      gfx.printf(tag_comment)          
  
	end
  end  
  
  gfx.update()
  if gfx.getchar() >= 0 then reaper.defer(run) end

end

last_value = 0;

init(window_w, window_h)
run()
