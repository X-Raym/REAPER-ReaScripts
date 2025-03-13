# ReaScript Preset File

## Documentation

### Concept

Preset script files allow you to modify main variables and functions from a script file without modifying its source, so that your modifications will be preserved even if the parent script is updated by its developer.
It only works with scripts written with this concept in mind.

### For User

1. Create a new Preset script file next to the Parent script file of your choice. You can name it whatever you want. You can do it via REAPER *Actions window* → *New Action* button → *New ReaScript* menu.
2. Copy the [Preset script.lua](https://github.com/X-Raym/REAPER-ReaScripts/blob/master/Templates/Script%20Preset/X-Raym_Preset%20script_template.lua) content. For that, you can click [here](https://github.com/X-Raym/REAPER-ReaScripts/raw/master/Templates/Script%20Preset/X-Raym_Preset%20script_template.lua), and do CTRL/CMD+A to select all text, and then do CTRL/CMD+C to copy the code.
3. Paste the code into the Preset script file via the opened IDE (code editor) window.
5. Copy parent script file name and paste it to the [User Config Area 1/2](https://github.com/X-Raym/REAPER-ReaScripts/blob/master/Templates/Script%20Preset/X-Raym_Preset%20script_template.lua#L14) section of the preset script.
6. Open the Parent script file into a code editor. It can be REAPER IDE, via *Actions window* → *Edit Action* button → *ReaScript IDE* menu.
7. Copy parent script [User Config Area](https://github.com/X-Raym/REAPER-ReaScripts/blob/master/Templates/Script%20Preset/X-Raym_Parent%20script%20of%20preset%20script_template.lua#L15-L16) variables and paste to the [User Config Area 2/2](https://github.com/X-Raym/REAPER-ReaScripts/blob/master/Templates/Script%20Preset/X-Raym_Preset%20script_template.lua#L43-L44) section of the preset script over the template variables.
8. Alter the [User Config Area 2/2](https://github.com/X-Raym/REAPER-ReaScripts/blob/master/Templates/Script%20Preset/X-Raym_Preset%20script_template.lua#L43-L44) variables in the preset script as you want.
9. Save your Preset script file (CTRL/CMD+S if done via REAPER IDE).

The preset script is now ready to use.

### For Devs

1. Wrap main code in a `Init()` function as in [Parent script.lua](https://github.com/X-Raym/REAPER-ReaScripts/blob/master/Templates/Script%20Preset/X-Raym_Parent%20script%20of%20preset%20script_template.lua#L20-L22).
2. Add [boolean](https://github.com/X-Raym/REAPER-ReaScripts/blob/master/Templates/Script%20Preset/X-Raym_Parent%20script%20of%20preset%20script_template.lua#L20-L22) to prevent running `Init()` directly if the script is called by preset script.
3. Have a [User Config Area](https://github.com/X-Raym/REAPER-ReaScripts/blob/master/Templates/Script%20Preset/X-Raym_Parent%20script%20of%20preset%20script_template.lua#L12-L18) at top of the script.
4. Prevent saving last input if necessary (for script with GUI) so that this feature stay for main script (not the preset, which usually will not have any popup).
