--[[
 * ReaScript Name: Save project and keep only X backups
 * About: This action can replace your regular save action. Set CTRL+S as keyboard shortcode for eg. Use REAPER config to save new backup at each save with timestamp and next to project
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-EEL-Scripts
 * Licence: GPL v3
 * REAPER: 5.0
 * Version: 1.0
--]]
 
--[[
 * Changelog:
 * v1.0 (2020-01-15)
  + Initial Release
--]]

-- USER CONFIG AREA ------------------

limit = 5
console = false
-- backup_folder = "backup" -- Without separator. NOTE: Don't modify this line.
backup_folder = ""

----------- END OF USER CONFIG AREA --

function Msg(variable)
  if console == true then
    reaper.ShowConsoleMsg(tostring(variable).."\n")
  end
end

sep = package.config:sub(1,1)

if backup_folder ~= "" then backup_folder = backup_folder .. sep end

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

function ReverseTable(t)
  local reversedTable = {}
  local itemCount = #t
  for k, v in ipairs(t) do
    reversedTable[itemCount + 1 - k] = v
  end
  return reversedTable
end

-- Split file name
function SplitFileName( strfilename )
  -- Returns the Path, Filename, and Extension as 3 values
  local path, file_name, extension = string.match( strfilename, "(.-)([^\\|/]-([^\\|/%.]+))$" )
  file_name = string.match( file_name, ('(.+)%.(.+)') )
  return path, file_name, extension
end

function Main()

  -- SAVE PROJECT
  reaper.Main_SaveProject( 0, false )

  -- MAKE BACKUP
  retval, proj_path = reaper.EnumProjects( -1 )

  folder, proj_name, proj_ext = SplitFileName(proj_path)

  -- Folowwing code is if custom backup and not regular one
  -- timestamp = os.date("%Y-%m-%d_%M-%S")

  --backup_path = folder .. backup_folder .. proj_name .. "_" .. timestamp .. ".rpp-bak"

  --reaper.RecursiveCreateDirectory( folder .. backup_folder, 0 )
  --CopyFiles( proj_path, backup_path )

  -- REMOVE BACKUPS
  files = EnumerateFiles( folder .. backup_folder )

  backup_files = {}
  for i, file in ipairs( files ) do
    --if file:match(proj_name .. "_(%d%d%d%d%-%d%d%-%d%d_%d%d%-%d%d)%.rpp%-bak" ) then
    if file:match(proj_name .. "%-(%d%d%d%d%-%d%d%-%d%d_%d%d%d%d%d%d)%.rpp%-bak" ) then
      table.insert(backup_files, file)
    end
  end

  backup_files = ReverseTable(backup_files)

  for i, file in ipairs( backup_files ) do
    if i > limit then
      os.remove(  folder .. backup_folder .. file  )
    end
  end

end

reaper.defer(Main)
