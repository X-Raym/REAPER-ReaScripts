--[[
 * ReaScript Name: Open render folder in explorer or finder
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Forum Thread: Scripts: Various
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1622146
 * REAPER: 7.0
 * Version: 1.0.4
--]]

--[[
 * Changelog:
 * v1.0 (2024-01-10)
  + Initial Release
--]]

function Tooltip(message) -- DisplayTooltip() already taken by the GUI version
  local x, y = reaper.GetMousePosition()
  reaper.TrackCtl_SetToolTip( tostring(message), x+17, y+17, false )
end

if not reaper.CF_ShellExecute then
  reaper.MB("Missing dependency: SWS extension.\nPlease download it from http://www.sws-extension.org/", "Error", 0)
  return false
end

local os_sep = package.config:sub(1,1)

retval, render_path = reaper.GetSetProjectInfo_String( 0, "RENDER_FILE", "", false )
if render_path == "" then
  reaper_ini_file = reaper.get_ini_file()
  retval, render_path = reaper.BR_Win32_GetPrivateProfileString( "reaper", "defrenderpath", '', reaper_ini_file )
  -- if is relative
  if ( os_sep == "\\" and not render_path:find(":" ) or ( os_sep == "/" and not render_path:sub(1,1) == os_sep ) ) then
    retval, project_path = reaper.EnumProjects( -1 )
    if project_path ~= "" then
      folder = project_path:match("@?(.*[\\|/])")
    else
      folder = reaper.GetProjectPath() -- This is in fact recording path, here for new project not saved
    end
    render_path = folder .. os_sep .. render_path
  end
  
end

if render_path ~= "" then
  render_path = render_path:gsub( os_sep .. "+", os_sep ) -- Remove duplicate path separators
  --reaper.RecursiveCreateDirectory( render_path, 0 ) -- Instead of checking if folder exists, we create it anyway
  Tooltip( render_path )
  reaper.CF_ShellExecute(render_path )
else
  Tooltip( "Empty render path" )
end
