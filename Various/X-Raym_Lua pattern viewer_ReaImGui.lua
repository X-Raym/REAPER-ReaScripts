--[[
 * ReaScript Name: Lua Pattern Viewer (ReaImGui)
 * Screenshot: https://i.imgur.com/UxOvxXI.gif
 * Author: X-Raym
 * Author URI: https://www.extremraym.com
 * Repository: GitHub > X-Raym > REAPER-ReaScripts
 * Repository URI: https://github.com/X-Raym/REAPER-ReaScripts
 * Licence: GPL v3
 * Version: 1.1.4
--]]

--[[
 * Changelog:
 * v1.1.3 (2025-01-06)
  # Renamed with ReaImGui suffix
  # ReaImGui v0.9.3.2
  # Dark Theme
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
reaimgui_force_version = "0.9.3.2"

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

local theme_colors = {
  WindowBg          = 0x292929ff, -- Window
  Border            = 0x2a2a2aff, -- Border
  Button            = 0x454545ff, -- Button
  ButtonActive      = 0x404040ff, -- Button and Top resize
  ButtonHovered     = 0x606060ff,
  FrameBg           = 0x454545ff, -- Input text BG
  FrameBgHovered    = 0x606060ff,
  FrameBgActive     = 0x404040ff,
  TitleBg           = 0x292929ff, -- Title
  TitleBgActive     = 0x000000ff,
  Header            = 0x323232ff, -- Selected rows
  HeaderHovered     = 0x323232ff,
  HeaderActive      = 0x05050587,
  ResizeGrip        = 0x323232ff, -- Resize
  ResizeGripHovered = 0x323232ff,
  ResizeGripActive  = 0x05050587,
  TextSelectedBg    = 0x05050587, -- Search Field Selected Text
  CheckMark         = 0xffffffff, -- CheckMark
}

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

imgui_path = reaper.ImGui_GetBuiltinPath and ( reaper.ImGui_GetBuiltinPath() .. '/imgui.lua' )

if not imgui_path then
  reaper.MB("Missing dependency: ReaImGui extension.\nDownload it via Reapack ReaTeam extension repository.", "Error", 0)
  return false
end

local ImGui = dofile(imgui_path) (reaimgui_force_version)

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

----------------------------------------------------------------------
-- IMGUI --
----------------------------------------------------------------------

function SetThemeColors(ctx)
  local count_theme_colors = 0
  for k, color in pairs( theme_colors ) do
    local color_str = reaper.GetExtState( "XR_ImGui_Col", k )
    if color_str ~= "" then
      color = tonumber( color_str, 16 )
    end
    ImGui.PushStyleColor(ctx, ImGui["Col_" .. k ], color )
    count_theme_colors = count_theme_colors + 1
  end
  return count_theme_colors
end

-- From cfillion
function about()
  local owner = reaper.ReaPack_GetOwner(({reaper.get_action_context()})[2])

  if not owner then
    reaper.MB(string.format(
      'This feature is unavailable because this script was not installed using ReaPack.',
      "Warning"), "Warning", 0)
    return
  end

  reaper.ReaPack_AboutInstalledPackage(owner)
  reaper.ReaPack_FreeEntry(owner)
end

function contextMenu()
  local dock_id = ImGui.GetWindowDockID(ctx)
  if not ImGui.BeginPopupContextWindow(ctx, nil, ImGui.PopupFlags_MouseButtonRight | ImGui.PopupFlags_NoOpenOverItems) then return end
  if ImGui.BeginMenu(ctx, 'Dock window') then
    if ImGui.MenuItem(ctx, 'Floating', nil, dock_id == 0) then
      set_dock_id = 0
    end
    for i = 0, 15 do
      if ImGui.MenuItem(ctx, ('Docker %d'):format(i + 1), nil, dock_id == ~i) then
        set_dock_id = ~i
      end
    end
    ImGui.EndMenu(ctx)
  end
  ImGui.Separator(ctx)
  if ImGui.MenuItem(ctx, 'About/help', 'F1', false, reaper.ReaPack_GetOwner ~= nil) then
    about()
  end
  if ImGui.MenuItem(ctx, 'Close', 'Escape') then
    exit = true
  end
  ImGui.EndPopup(ctx)
end

--------------------------------------------------------------------------------
-- MAIN --
--------------------------------------------------------------------------------

function Main()

  --retval, txt = ImGui.InputText( ctx, "Text", txt or "" )

  if ImGui.BeginChild(ctx, 'left_panel', imgui_width/2 - 12, nil, nil, ImGui.WindowFlags_MenuBar) then

    if ImGui.BeginMenuBar(ctx) then
      ImGui.Text(ctx,'PLAYGROUND')
      ImGui.EndMenuBar(ctx)
    end

    retval, txt = ImGui.InputTextMultiline( ctx, "Text", txt or "", nil, nil,  ImGui.InputTextFlags_AllowTabInput )
    retval, pattern = ImGui.InputText( ctx, "Pattern", pattern or "",  ImGui.InputTextFlags_AllowTabInput )
    retval, replace = ImGui.InputTextMultiline( ctx, "Replace", replace or "", nil, nil,  ImGui.InputTextFlags_AllowTabInput )

    pattern_clean = pattern
    last_char = pattern:sub(-1)
    if last_char == "%" then
      pattern_clean = pattern:sub(1, -2)
    end
    ImGui.Dummy( ctx, 16, 16 )
    local status, result = pcall(string.match, txt, pattern)
    if pattern ~= "" and status then
        matches = { txt:match(pattern)}
        if #matches > 0 then
          ImGui.Text( ctx, "Matches: " .. #matches .. (#matches > 1 and " groups" or " group") .. "\n" )
          for i, match in ipairs( matches ) do
            ImGui.InputText( ctx, "%" .. i .. "##match" .. i, match,  ImGui.InputTextFlags_AllowTabInput |  ImGui.InputTextFlags_ReadOnly )
          end
          ImGui.Text( ctx, "\nSubstitution:")
          local sub_status, sub_result = pcall(string.gsub, txt, pattern, replace)
          if sub_status then
            local substitution = txt:gsub(pattern, replace)
            ImGui.InputTextMultiline( ctx, "Output", substitution, nil, nil,  ImGui.InputTextFlags_AllowTabInput )
          else
            ImGui.Text( ctx, "Wrong substitution pattern: " .. sub_result )
          end
        else
          ImGui.Text( ctx, "No Match" )
        end
    else
      if pattern == "" then
        ImGui.Text( ctx, "Empty pattern" )
      else
        ImGui.Text( ctx, "Wrong pattern: " .. result )
      end
    end
    ImGui.EndChild(ctx)
  end

  ImGui.SameLine(ctx)

  if ImGui.BeginChild(ctx, 'right_panel', imgui_width/2 - 12, nil, nil, ImGui.WindowFlags_MenuBar) then

    if ImGui.BeginMenuBar(ctx) then
      ImGui.TextWrapped(ctx,'DOC')
      ImGui.EndMenuBar(ctx)
    end

    ImGui.Text( ctx, "Doc form: https://help.interfaceware.com/v6/lua-magic-characters" )

    if ImGui.IsItemClicked( ctx ) then
      Open_URL( "https://help.interfaceware.com/v6/lua-magic-characters")
    end

    ImGui.PushTextWrapPos(ctx, imgui_width/2 - 12*3)
    ImGui.Text(ctx, doc)
    ImGui.PopTextWrapPos(ctx)

    ImGui.EndChild(ctx)
  end

end

function Run()

  ImGui.SetNextWindowBgAlpha( ctx, 1 )

  if set_dock_id then
    ImGui.SetNextWindowDockID(ctx, set_dock_id)
    set_dock_id = nil
  end

  count_theme_colors = SetThemeColors( ctx )

  ImGui.PushFont(ctx, font)
  ImGui.SetNextWindowSize(ctx, 800, 200, ImGui.Cond_FirstUseEver)

  local imgui_visible, imgui_open = ImGui.Begin(ctx, input_title, true, ImGui.WindowFlags_NoCollapse)

  if imgui_visible then

    imgui_width, imgui_height = ImGui.GetWindowSize( ctx )

    contextMenu()

    Main()

    --------------------

    ImGui.End(ctx)
  end

  ImGui.PopStyleColor(ctx, count_theme_colors)
  ImGui.PopFont(ctx)

  if imgui_open and not ImGui.IsKeyPressed(ctx, ImGui.Key_Escape) and not process then
    reaper.defer(Run)
  end

end -- END DEFER

--------------------------------------------------------------------------------
-- INIT --
--------------------------------------------------------------------------------

function Init()
  SetButtonState( 1 )
  reaper.atexit( Exit )

  ctx = ImGui.CreateContext( input_title, ImGui.ConfigFlags_DockingEnable | ImGui.ConfigFlags_NavEnableKeyboard )
  ImGui.SetConfigVar( ctx, ImGui.ConfigVar_DockingNoSplit, 1 )
  font = ImGui.CreateFont('sans-serif', 16)
  ImGui.Attach(ctx, font)

  reaper.defer(Run)
end

if not preset_file_init then
  Init()
end
