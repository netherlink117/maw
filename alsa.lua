local wibox = require("wibox")
local awful = require("awful")
local alsa = {
    volume = "",
    status = ""
}
local widget = wibox.widget.textbox()
function widget:init(beautiful)
    widget.beautiful = beautiful
    return widget
end
function widget:display()
    local padding_left = ""
    if tonumber(alsa.volume) < 10  then
        padding_left = padding_left .. "  "
    elseif tonumber(alsa.volume) < 100 then
        padding_left = padding_left .. " "
    end
    if alsa.status == "on" then
        widget.text = "[alsa:" .. padding_left .. alsa.volume .. "%]"
    else
        widget.text = "[alsa:" .. padding_left .. alsa.volume .. "M]"
    end
end
function widget:get()
    awful.spawn.easy_async("amixer -M sget Master", function(stdout, stderr, exitreason, exitcode)
        alsa.volume, alsa.status = string.match(stdout, "([%d]+)%%.*%[([%l]*)")
        widget:display()
    end)
end
function widget:toggle()
    awful.spawn.easy_async("amixer -M sset Master toggle", function(stdout, stderr, exitreason, exitcode)
        alsa.volume, alsa.status = string.match(stdout, "([%d]+)%%.*%[([%l]*)")
        widget:display()
    end)
end
function widget:increase()
    awful.spawn.easy_async("amixer -M sset Master 1%+", function(stdout, stderr, exitreason, exitcode)
        alsa.volume, alsa.status = string.match(stdout, "([%d]+)%%.*%[([%l]*)")
        widget:display()
    end)
end
function widget:decrease()
    awful.spawn.easy_async("amixer -M sset Master 1%-", function(stdout, stderr, exitreason, exitcode)
        alsa.volume, alsa.status = string.match(stdout, "([%d]+)%%.*%[([%l]*)")
        widget:display()
    end)
end
widget:connect_signal(
    "button::press",
    function(lx, ly, button, mods, find_widgets_result)
        if mods == 4 then --idk why mods gives the button number
            widget:increase() --even when docs say its a table, may be i'm wrong
        elseif mods == 5 then -- tested on debian 10 buster
            widget:decrease()
        elseif mods == 1 then
            widget:toggle()
        end
    end
) 
widget:get()
return widget;