--[[
 * ReaScript Name: Export markers and regions as Davinci Resolve EDL file
 * About: This was designed to have a tempo map inside DaVinci Resolve
 * Screenshot: https://i.imgur.com/xEsD5a8.gifv
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Links
    Forum Thread https://forum.cockos.com/showthread.php?p=1670961
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.3
--]]

--[[
 * Changelog:
 * v1.3 (2020-16-01)
  + Marker Only option
 * v1.2 (2020-16-01)
  + Region support
  # Fix davinci colors
  # Add new davinci colors
 * v1.1 (2019-02-11)
  + Marker
  + User Input
  + Resolve Color Support
  + From Time Selection start if any
  + Better file handling
 * v1.0 (2018-12-21)
  + Initial Release
--]]

-- USER CONFIG AREA ------------------------

vars = {}
vars.frame_rate = 25
vars.offset = 3600
vars.markers_only = "y"

popup = true

---- END OF USER CONFIG AREA ----------------

-- TODO: More Resolve Color Support

ext_name = "XR_EDL_Marker_Resolve"

-- Console Message
function Msg(g)
  reaper.ShowConsoleMsg(tostring(g).."\n")
end

-- SAVE PRESET
function SaveState()
  for k, v in pairs( vars ) do
    SaveExtState( k, v )
  end
end

function SaveExtState( var, val)
  reaper.SetExtState( ext_name, var, tostring(val), true )
end

function GetExtState( var, val )
  if reaper.HasExtState( ext_name, var ) then
    local t = type( val )
    val = reaper.GetExtState( ext_name, var )
    if t == "boolean" then val = toboolean( val )
    elseif t == "number" then val = tonumber( val )
    else
    end
  end
  return val
end

---------------------------------------------------------
-- NUMBER
-- ------

-- Format Seconds
function Format(number)
  str = reaper.format_timestr_pos(number, "", 5)
  return str
end



--------------------------------------------------------
-- PATHS
-- -----

-- Get Path from file name
function GetPath(str,sep)
    return str:match("(.*"..sep..")")
end


-- Check if project has been saved
function IsProjectSaved()
  -- OS BASED SEPARATOR
  if reaper.GetOS() == "Win32" or reaper.GetOS() == "Win64" then
    -- user_folder = buf --"C:\\Users\\[username]" -- need to be test
    separator = "\\"
  else
    -- user_folder = "/USERS/[username]" -- Mac OS. Not tested on Linux.
    separator = "/"
  end

  --path = reaper.GetProjectPath("") -- E:\Bureau\Projet\Audio
  --path = path:gsub("Audio", "") -- E:\Bureau\Projet\

  retval, project_path_name = reaper.EnumProjects(-1, "")
  if project_path_name ~= "" then
    
    dir = GetPath(project_path_name, separator)
    --msg(name)
    name = string.sub(project_path_name, string.len(dir) + 1)
    name = string.sub(name, 1, -5)

    name = name:gsub(dir, "")
    --file = dir .. "HTML" .. separator .. name .. " - Items List.html"
    file = dir .. name .. " - Regions List.edl"
    --msg(name)
    project_saved = true
    return project_saved
  else
    display = reaper.ShowMessageBox("You need to save the project to execute this script.", "File Export", 1)

    if display == 1 then

      reaper.Main_OnCommand(40022, 0) -- SAVE AS PROJECT

      return IsProjectSaved()

    end
  end
end


------------------------------------------------------------------
-- COLOR FUNCTIONS
-- ---------------
--[[
 * Converts an RGB color value to HSL. Conversion formula
 * adapted from http://en.wikipedia.org/wiki/HSL_color_space.
 * Assumes r, g, and b are contained in the set [0, 255] and
 * returns h, s, and l in the set [0, 1].
 *
 * @param   Number  r       The red color value
 * @param   Number  g       The green color value
 * @param   Number  b       The blue color value
 * @return  Array           The HSL representation
]]
function rgbToHsl(r, g, b, a)
  r, g, b = r / 255, g / 255, b / 255

  local max, min = math.max(r, g, b), math.min(r, g, b)
  local h, s, l

  l = (max + min) / 2

  if max == min then
    h, s = 0, 0 -- achromatic
  else
    local d = max - min
    if l > 0.5 then s = d / (2 - max - min) else s = d / (max + min) end
    if max == r then
      h = (g - b) / d
      if g < b then h = h + 6 end
    elseif max == g then h = (b - r) / d + 2
    elseif max == b then h = (r - g) / d + 4
    end
    h = h / 6
  end

  return h, s, l, a or 255
end

color_names = {}
color_names[9] = "Red"
color_names[39] = "Yellow"
color_names[120] = "Green"
color_names[181] = "Cyan"
color_names[206] = "Blue" -- 
color_names[271] = "Purple"
color_names[318] = "Pink"
color_names[369] = "Red"

color_names[333] = "Fuchsia"
color_names[345] = "Rose"
color_names[256] = "Lavender"
color_names[195] = "Sky"
color_names[89] = "Mint"
color_names[65] = "Lemon"
color_names[30] = "Sand"
color_names[20] = "Cocoa"
color_names[30] = "Cream"

function minTableKey( array, key )
  local min = math.huge
  local key = ""
  for k, v in pairs( array ) do
    if v < min then
      min = v
      key = k
    end
  end
  return key, min
end

function GetClosestColorNameByHue( hue )
  local name = ''
  local diffs = {}
  for k, v in pairs(color_names) do
    diffs[k] = math.abs( k - hue )
  end
  local k, min = minTableKey(diffs)
  a = diffs
  return color_names[k]
end

--------------------------------------------------------------
-- CREATE FILE
-- -----------

-- New HTML Line
function export(f, variable)
  f:write(variable)
  f:write("\n")
end

-- Create File
function create(f)
  
  title = "TITLE: Timeline 1"
  FCM = "FCM: NON-DROP FRAME"
  export(f, title)
  export(f, FCM .. "\n")

  frame_duration = 1 / vars.frame_rate
  
  ts_start, ts_end = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)  
  
  retval, num_markers, num_regions = reaper.CountProjectMarkers( 0 )
  for i=0, retval - 1 do
    iRetval, bIsrgnOut, iPosOut, iRgnendOut, name, iMarkrgnindexnumberOut, iColorOur = reaper.EnumProjectMarkers3(0,i)
    if iRetval >= 1 then
      if iPosOut - ts_start > 0 then -- if marker region is after time selection start
        if ts_end ~= 0 and iPosOut > ts_end then break end -- if time selection and marker region_end is after
        start_time = "0" .. reaper.format_timestr_pos(iPosOut + vars.offset - ts_start, "",5)
        start_time_1 = "0" .. reaper.format_timestr_pos(iPosOut + vars.offset + frame_duration - ts_start, "",5)
        end_time =  reaper.format_timestr_pos(iRgnendOut, "",5)
        
        duration = iRgnendOut - iPosOut
        duration_frames = 1
        if bIsrgnOut then
          duration_frames = math.floor( (duration + frame_duration / 2)/ frame_duration )
        end
        
        local h, s, l = rgbToHsl( reaper.ColorFromNative(iColorOur) )
        acolor_RGB = { reaper.ColorFromNative(iColorOur)}
        acolor_HSL = {h * 360, s * 255, l * 255} -- 241 ?
        color_name = GetClosestColorNameByHue(acolor_HSL[1] )
        -- [start time HH:MM:SS.F] [end time HH:MM:SS.F] [name]
        -- 001  001      V     C        01:00:00:00 01:00:00:01 01:00:00:00 01:00:00:01  
        -- |C:ResolveColorBlue |M:Marker 1 |D:1
        if name == "" then name = "Marker " .. i+1 end
        line = i+1 .. "  001      V     C        " .. start_time .. " " .. start_time_1 .. " " .. start_time .. " " .. start_time_1 .. "  " .. "\n |C:ResolveColor" .. color_name .. " |M:" .. name .. " |D:" .. duration_frames .. "\n"
        --line = i .. "  001      V     C        " .. start_time .. " " .. start_time_1 .. " " .. start_time .. " " .. start_time_1 .. "  " .. "\n |C:ResolveColorBlue |M:" .. name .. " |D:1\n"
        if vars.markers_only ~= "y" or (vars.markers_only == "y" and not bIsrgnOut) then
          export(f, line)
        end
      end
      i = i+1
    end
  end
  
  export(f, "\n")

  Msg("Regions Lists exported to:\n" .. file .."\n")

end



----------------------------------------------------------------
-- MAIN FUNCTION
-- -------------

function main()

  f = io.open(file, "w")

  -- HTML FOLDER EXIST
  if f ~= nil then
    create(f)
  end
  
  -- CLOSE FILE
  f:close()

end -- ENDFUNCTION MAIN


----------------------------------------------------------------------
-- RUN
-- ---
reaper.ClearConsole()

-- Check if there is selected Items
retval, count_markers, count_regions = reaper.CountProjectMarkers(0)
if count_regions > 0 or count_markers > 0 then

  project_saved = IsProjectSaved() -- See if Project has been save and determine file paths
  if project_saved then
    if popup then
      vars.offset = GetExtState( "offset", vars.offset )
      vars.frame_rate = GetExtState( "frame_rate", vars.frame_rate )
      vars.markers_only = GetExtState( "markers_only", vars.markers_only )

      retval, retval_csv = reaper.GetUserInputs( "Export Markers to EDL", 3, "Framerate (fps):, Offset (s),Markers Only (y/n)", vars.frame_rate .. "," .. vars.offset .. "," .. vars.markers_only)
      if retval then
        vars.frame_rate, vars.offset, vars.markers_only = retval_csv:match("([^,]+),([^,]+),([^,]+)")
        if vars.frame_rate then
          vars.frame_rate = tonumber( vars.frame_rate )
          vars.offset = tonumber( vars.offset )
          SaveState()
        end
      end
    end

    if not popup or (retval and vars.frame_rate and vars.offset) then
      reaper.defer(main) -- Execute your main function
    end
  end

else
  Msg("No regions or markers in the project.")
end -- ENDIF Item in project
