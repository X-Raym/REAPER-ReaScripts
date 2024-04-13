--[[
 * ReaScript Name: Lua Pattern Viewer (ReaImGui)
 * Screenshot: https://i.imgur.com/UxOvxXI.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Version: 1.1.2
--]]

--[[
 * Changelog:
 * v1.1.2 (2024-04-13)
  # Force reaimgui version
 * v1.1.1 (2023-08-13)
  + Allows tab character in inputs
 * v1.1 (2023-08-01)
  + Doc in right panel
  + Doc word wrap
  + Match pattern in input field with pattern ID
 * v1.0.1 (2023-07-25)
  + Substitution replace field
  + display errors messages
 * v1.0 (2023-07-25)
  + Initial release
--]]

--------------------------------------------------------------------------------
-- USER CONFIG AREA --
--------------------------------------------------------------------------------

console = true -- Display debug messages in the console
reaimgui_force_version = "0.8.7.6" -- false or string like "0.8.4"

txt = "01 - Artist_Title.mp3"
pattern = "(%d+) %- (.+)_(.+)%.(.+)"
replace = "%1 - %2_%3.%4"

--------------------------------------------------------------------------------
                                                   -- END OF USER CONFIG AREA --
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- GLOBALS --
--------------------------------------------------------------------------------

input_title = "XR - Lua Pattern Viewer"

doc = [[

The magic characters are:
  
  (   )   .   %   +   –   *   ?   [   ^   $
  
  In addition to this, Lua uses the following character classes (you will notice that the magic character % is used here)
  
      %a   letters
      %c   control characters
      %d   digits
      %l   lowercase letters
      %p   punctuation characters
      %s   whitespace characters
      %u   uppercase letters
      %w   alphanumeric characters
      %x   hexadecimal digits
      %z   the character \000
  
  How it works [top]
  
  This is section explains what each of the magic characters does. It also explains how to work with sets of characters.
  
  The magic characters:
  
      (   )
          Represents what is called a capture. This allows you to enclose sub-patterns in your patterns
      .
          Represents any single character
          If you want the literal . character then you have to escape it with the % character: %.
      %
          This is a special character which toggles the character classes
          In order to use the % pattern you must use %% as an input
      +
          Matches 1 or more repetitions of the class. This will always match the longest possible chain.
          Example of Usage: %w+
      -
          Matches 0 or more repetitions of the class. This will always match the shortest possible chain
          Example of Usage: %d-
      *
          Matches 0 or more repetitions of the class. This will always match the longest possible chain
          Example Usage: %l*
      ?
          Matches 0 or 1 occurrence of the class
          Example Usage: %a?
      ^
          This is only a magic character when it is at the beginning of a pattern.
          When this is at the beginning of a pattern it forces the pattern to match the start of a string
          Example Usage: ^A.+ This will match any set of characters which begin with the character A
      $
          This is only a magic character when it is at the beginning of a pattern.
          When it is at the end of a pattern it forces the pattern to match the end of the string
          Example Usage: %w%.$ will match any alphanumeric character which is followed immediately and only by a . character
  
  Fun with Sets:
  
      The [ and ] symbols are used to represent sets:
          The [ character denotes the start of a set, and a ] shows the end
          A set is a class which is the union of all of the characters and/or classes which appear in the set
          Example Usage: [%d%l] will match any digit or any lowercase letter
          Example Usage: [%dabc] will match any digit or the characters a, b, or c
      Sets can be modified with the ^ not character:
          This will make the set match anything but the characters listed inside the brackets
          Example Usage: [^%l] will match anything but a lowercase letter
      Use the - (dash) character to indicate a range of values:
          Example Usage: [1-5] will match the values 1 through 5 inclusive]]

--------------------------------------------------------------------------------
-- DEPENDENCIES --
--------------------------------------------------------------------------------

if not reaper.ImGui_CreateContext then
  reaper.MB("Missing dependency: ReaImGui extension.\nDownload it via Reapack ReaTeam extension repository.", "Error", 0)
  return false
end

if reaimgui_force_version then
  reaimgui_shim_file_path = reaper.GetResourcePath() .. '/Scripts/ReaTeam Extensions/API/imgui.lua'
  if reaper.file_exists( reaimgui_shim_file_path ) then
    dofile( reaimgui_shim_file_path )(reaimgui_force_version)
  end
end

--------------------------------------------------------------------------------
                                                       -- END OF DEPENDENCIES --
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- DEBUG --
--------------------------------------------------------------------------------

function Msg( value )
  if console then
    reaper.ShowConsoleMsg( tostring( value ) .. "\n" )
  end
end

--------------------------------------------------------------------------------
-- DEFER --
--------------------------------------------------------------------------------

-- Set ToolBar Button State
function SetButtonState( set )
  local is_new_value, filename, sec, cmd, mode, resolution, val = reaper.get_action_context()
  reaper.SetToggleCommandState( sec, cmd, set or 0 )
  reaper.RefreshToolbar2( sec, cmd )
end

function Exit()
  SetButtonState()
end

--------------------------------------------------------------------------------
-- OTHER --
--------------------------------------------------------------------------------

function Open_URL(url)
  if not OS then local OS = reaper.GetOS() end
  if OS=="OSX32" or OS=="OSX64" then
    os.execute("open ".. url)
   else
    os.execute("start ".. url)
  end
end

--------------------------------------------------------------------------------
-- MAIN --
--------------------------------------------------------------------------------

function Main()

  --retval, txt = reaper.ImGui_InputText( ctx, "Text", txt or "" )

  if reaper.ImGui_BeginChild(ctx, 'left_panel', imgui_width/2 - 12, nil, true, reaper.ImGui_WindowFlags_MenuBar()) then
    
    if reaper.ImGui_BeginMenuBar(ctx) then
      reaper.ImGui_Text(ctx,'PLAYGROUND')
      reaper.ImGui_EndMenuBar(ctx)
    end
    
    retval, txt = reaper.ImGui_InputTextMultiline( ctx, "Text", txt or "", nil, nil,  reaper.ImGui_InputTextFlags_AllowTabInput() )
    retval, pattern = reaper.ImGui_InputText( ctx, "Pattern", pattern or "",  reaper.ImGui_InputTextFlags_AllowTabInput() )
    retval, replace = reaper.ImGui_InputTextMultiline( ctx, "Replace", replace or "", nil, nil,  reaper.ImGui_InputTextFlags_AllowTabInput() )
    
    pattern_clean = pattern
    last_char = pattern:sub(-1)
    if last_char == "%" then
      pattern_clean = pattern:sub(1, -2)
    end
    reaper.ImGui_Dummy( ctx, 16, 16 )
    local status, result = pcall(string.match, txt, pattern)
    if pattern ~= "" and status then
        matches = { txt:match(pattern)}
        if #matches > 0 then
          reaper.ImGui_Text( ctx, "Matches: " .. #matches .. (#matches > 1 and " groups" or " group") .. "\n" )
          for i, match in ipairs( matches ) do
            reaper.ImGui_InputText( ctx, "%" .. i .. "##match" .. i, match,  reaper.ImGui_InputTextFlags_AllowTabInput() |  reaper.ImGui_InputTextFlags_ReadOnly() )
          end
          reaper.ImGui_Text( ctx, "\nSubstitution:")
          local sub_status, sub_result = pcall(string.gsub, txt, pattern, replace)
          if sub_status then
            local substitution = txt:gsub(pattern, replace)
            reaper.ImGui_InputTextMultiline( ctx, "Output", substitution, nil, nil,  reaper.ImGui_InputTextFlags_AllowTabInput() )
          else
            reaper.ImGui_Text( ctx, "Wrong substitution pattern: " .. sub_result )
          end
        else
          reaper.ImGui_Text( ctx, "No Match" )
        end
    else
      if pattern == "" then
        reaper.ImGui_Text( ctx, "Empty pattern" )
      else
        reaper.ImGui_Text( ctx, "Wrong pattern: " .. result )
      end
    end
    reaper.ImGui_EndChild(ctx)
  end
  
  reaper.ImGui_SameLine(ctx)
  
  if reaper.ImGui_BeginChild(ctx, 'right_panel', imgui_width/2 - 12, nil, true, reaper.ImGui_WindowFlags_MenuBar()) then
    
    if reaper.ImGui_BeginMenuBar(ctx) then
      reaper.ImGui_TextWrapped(ctx,'DOC')
      reaper.ImGui_EndMenuBar(ctx)
    end
    
    reaper.ImGui_Text( ctx, "Doc form: https://help.interfaceware.com/v6/lua-magic-characters" )
    
    if reaper.ImGui_IsItemClicked( ctx ) then
      Open_URL( "https://help.interfaceware.com/v6/lua-magic-characters")
    end
    
    reaper.ImGui_PushTextWrapPos(ctx, imgui_width/2 - 12*3)
    reaper.ImGui_Text(ctx, doc)
    reaper.ImGui_PopTextWrapPos(ctx)
    
    reaper.ImGui_EndChild(ctx)
  end
  
end

function Run()
  
  reaper.ImGui_SetNextWindowBgAlpha( ctx, 1 )

  reaper.ImGui_PushFont(ctx, font)
  reaper.ImGui_SetNextWindowSize(ctx, 800, 200, reaper.ImGui_Cond_FirstUseEver())

  if set_dock_id then
    reaper.ImGui_SetNextWindowDockID(ctx, set_dock_id)
    set_dock_id = nil
  end

  local imgui_visible, imgui_open = reaper.ImGui_Begin(ctx, input_title, true, reaper.ImGui_WindowFlags_NoCollapse())

  if imgui_visible then

    imgui_width, imgui_height = reaper.ImGui_GetWindowSize( ctx )

    Main()
    
    --------------------

    reaper.ImGui_End(ctx)
  end
  
  reaper.ImGui_PopFont(ctx)

  if imgui_open and not reaper.ImGui_IsKeyPressed(ctx, reaper.ImGui_Key_Escape()) and not process then
    reaper.defer(Run)
  end

end -- END DEFER

--------------------------------------------------------------------------------
-- INIT --
--------------------------------------------------------------------------------

function Init()
  SetButtonState( 1 )
  reaper.atexit( Exit )

  ctx = reaper.ImGui_CreateContext(input_title)
  font = reaper.ImGui_CreateFont('sans-serif', 16)
  reaper.ImGui_Attach(ctx, font)

  reaper.defer(Run)
end

if not preset_file_init then
  Init()
end

