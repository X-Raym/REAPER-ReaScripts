--[[
 * ReaScript Name: Save project and keep only X backups
 * About: This action can replace your regular save action. Set CTRL+S as keyboard shortcode fr eg. Use REAPER config to save new backup at each save with timestamp and next to project
 * Screenshot: https://i.imgur.com/URmnLmt.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0.7
--]]

--[[
 * Changelog:
 * v1.0.7 (2021-08-09)
  + Save only if project is dirty variable
  # Pattern fine tuning for project name with dash and other lua esape characters
 * v1.0.6 (2021-07-25)
  + Automatic backup support
 * v1.0.5 (2021-07-23)
  # Pattern in user config area
 * v1.0.4 (2021-07-23)
  # Small code optimization
  + Stricter pattern
 * v1.0.3 (2021-02-10)
  * Preset file support
 * v1.0.2 (2020-04-25)
  # String find insteas of string match to allow "-" character
 * v1.0.1 (2020-02-12)
  # Buf fix when saving not saved project
 * v1.0 (2020-01-15)
  + Initial Release
--]]

-- USER CONFIG AREA ------------------
-- Use Preset Script file for moding in update compatible way
-- https://gist.github.com/X-Raym/f7f6328b82fe37e5ecbb3b81aff0b744

limit = 5
console = false
do_automatic_backup_dir = true
save_if_dirty_only = true

-- Pattern
-- DOn't change that if you are only using reaper default backup systems
-- Default works with "Timestamped backup" in Options -> Project -> Project saving
-- Also consider auto timestamp which are in $proj_name which doesn't have seconds in timestamp.
-- But in case you do need customization...
-- wildcard = $proj_name
pattern = "^$proj_name%-(%d%d%d%d%-%d%d%-%d%d_%d%d%d%d%d?%d?)%.rpp%-bak"

----------- END OF USER CONFIG AREA --

function Msg(variable)
  if console then
    reaper.ShowConsoleMsg(tostring(variable).."\n")
  end
end

sep = package.config:sub(1,1)

-- NOT USED FOR NOW
-- Backup Folder
-- Eg: [[backup]] for project_path/backup
-- Use system path separator (\ for Windows, / for MacOS)
-- Don't use system path separator as last character
-- backup_folder = [[]]
-- if backup_folder ~= "" then backup_folder = backup_folder .. sep end

function CopyFiles( in_path, out_path )
  if reaper.file_exists( in_path ) then
    local infile = io.open( in_path, "r" )
    local instr = infile:read( "*a" )
    infile:close()

    local outfile = io.open( out_path, "w" )
    outfile:write( instr )
    outfile:close()
  else
    Msg("ERROR: Missing file")
    Msg(in_path)
  end
end

function EnumerateFiles( folder )
  local files = {}
  local i = 0
  repeat
    local retval = reaper.EnumerateFiles( folder, i )
    table.insert(files, retval)
    i = i + 1
  until not retval
  return files
end

-- Split file name
function SplitFileName( strfilename )
  -- Returns the Path, Filename, and Extension as 3 values
  local path, file_name, extension = string.match( strfilename, "(.-)([^\\|/]-([^\\|/%.]+))$" )
  file_name = string.match( file_name, ('(.+)%.(.+)') )
  return path, file_name, extension
end

function Process(folder)
  -- REMOVE BACKUPS
  folder = folder or ""
  local files = EnumerateFiles( folder )

  local backup_files = {}
  for i, file in ipairs( files ) do
    if file:find( pattern ) then
      table.insert(backup_files, file)
    end
  end

  if #backup_files > limit then
    for i = 1, #backup_files - limit do
      os.remove(  folder .. backup_files[i]  )
    end
  end
end

function EscapeLuaSpecialChar( str )
  local chars = { "%", "(", ")", ".", "+", "-",  "[", "^", "$", "]" } -- percentage first
  for i, char in ipairs( chars ) do
    str = str:gsub( "%" .. char, "%%%%" .. char )
  end
  return str
end

function Main()

  -- SAVE PROJECT
  reaper.Main_SaveProject( 0, false )

  -- MAKE BACKUP
  retval, proj_path = reaper.EnumProjects( -1 )

  if proj_path == "" then
    return false
  end
  folder, proj_name, proj_ext = SplitFileName(proj_path)

  proj_name = EscapeLuaSpecialChar( proj_name )

  pattern = pattern:gsub("$proj_name", proj_name)

  -- TODO: Copy backup in certain dir
  -- Folowwing code is if custom backup and not regular one
  -- timestamp = os.date("%Y-%m-%d_%M-%S")

  --backup_path = folder .. backup_folder .. proj_name .. "_" .. timestamp .. ".rpp-bak"

  --reaper.RecursiveCreateDirectory( folder .. backup_folder, 0 )
  --CopyFiles( proj_path, backup_path )

  -- Do Project Dir
  Process(folder)

  -- Do Automatic Backup Dir
  if do_automatic_backup_dir then
    local reaper_ini_file = reaper.get_ini_file()
    retval, saveopts = reaper.get_config_var_string( "saveopts" )
    saveopts = tonumber(saveopts)
    if saveopts & 8 == 8 then -- 8 is save to timestamped file in additional directory setting
      local retval, autosavedir = reaper.BR_Win32_GetPrivateProfileString( "reaper", "autosavedir", "",  reaper_ini_file  )
      Process(autosavedir ..sep)
    end
  end

end

function Init()
  reaper.ClearConsole()
  if not save_if_dirty_only or (save_if_dirty_only and reaper.IsProjectDirty() == 1 ) then
    reaper.defer(Main)
  end
end

if not preset_file_init then
  Init()
end
