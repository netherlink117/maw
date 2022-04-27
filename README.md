# MAW
MAW is another set of text-based widgets designed to work on awesome wm v4.3. using only lua scripts and the API from awesome wm (but to execute shell commands, mostly). I made them as a hobbie as almost all my other projects. Some of the actual feactures are:
- Volume widget using amixer
    - The functions from widget can be binded to keyboard using globalkeys.
    - Mouse click on widget toggles sound.
    - Mouse scrolling over the widget to adjust the volume.
- Brightness widget using xbacklight
    - The functions from widget can be binded to keyboard using globalkeys.
    - Mouse scrolling over the widget to adjust the brightness.
- Battery monitoring widget usinc acpi
    - A simple widget that shows the battery charge percentage.
- Music widget using cmus-remote
    - The widget functions can be binded to keyboard keys.
    - Mouse clicking on the widget can change the information described (by now only title, artist and progress).

![Screenshot from the bar including the widgets](./source/images/screenshot-widgets-bar.png "Small screenshot")*Each widget can be customised changing the strings's text on code, that's how I'm using them right now.*
It is currently manintained by myself, but varely I put effort for mantinances as news projects come out, but I try to improve them.
## Installation
Now, to use the widgets, simply clone this git inside ~/.config/awesome folder, then add the follow lines just after the beautiful.init call at rc.lua file from the ~/.config/awesome folder, it might look like this:
```lua
   beautiful.init("your/theme/path/here.lua") --just an example, usually rc.lua already has this line
   local alsa = require("maw.alsa").init(beautiful) -- used to control Master channel using amixer (it affects pulse when is on default card)
   local acpi = require("maw.acpi").init(beautiful) -- used to monitor battery usinf the acpi command
   local xbacklight = require("maw.xbacklight").init(beautiful) -- used to control brightness using the xbacklight package's command
   local cmus = require("maw.cmus").init(beautiful) -- used to control cmus instance using the cmus-remote commands
```
And finally put them on the s.wibox:setup layouts (it is locate on rc.lua too):
```lua
    s.mywibox:setup {
    layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            -- mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            cmus,
            alsa, -- audio widget
            xbacklight, -- brightness widget
            acpi, -- battery widget
            layout = wibox.layout.fixed.horizontal,
            mykeyboardlayout,
            trayicons,
            mytextclock,
            s.mylayoutbox,
        },
    }
```
Optionally, the widget functions to control volume and brigthness can be used by the key bindings at globalkeys, so you need to look for it in the rc.lua file and then add this lines inside the brackets, at the end of the globalkeys definition.
```lua
    -- Audio
    awful.key({ }, "XF86AudioRaiseVolume", function () alsa:increase() end),
    awful.key({ }, "XF86AudioLowerVolume", function () alsa:decrease() end),
    awful.key({ }, "XF86AudioMute",  function () alsa:toggle() end),
    -- Music
    awful.key({ }, "XF86AudioPlay", function () cmus:toggle("stop") end),
    awful.key({ }, "XF86AudioNext", function () cmus:next() end),
    awful.key({ }, "XF86AudioPrev", function () cmus:previous() end),
    -- Brightness
    awful.key({}, "XF86MonBrightnessUp", function() xbacklight:increase() end),
    awful.key({}, "XF86MonBrightnessDown", function() xbacklight:decrease() end),
```
For more information, files can be checked as I tried to make the code relatively easy to understand.
## License
The code shared on this repository is shared under the [MIT](https://opensource.org/licenses/MIT) license.
