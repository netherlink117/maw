local wibox = require("wibox")
local awful = require("awful")
local xbacklight = {
    brightness = ""
}
local widget = wibox.widget.textbox()
function widget:init(beautiful)
    widget.beautiful = beautiful
    return widget
end
function widget:display()
    local padding_left = ""
    if tonumber(xbacklight.brightness) < 10  then
        padding_left = padding_left .. "  "
    elseif tonumber(xbacklight.brightness) < 100 then
        padding_left = padding_left .. " "
    end
    widget.text = "[xbacklight:" .. padding_left .. xbacklight.brightness .. "%]"
end
function widget:get()
    awful.spawn.easy_async("xbacklight -get", function(stdout, stderr, exitreason, exitcode)
        xbacklight.brightness = math.floor(tonumber(string.match(stdout, "([%d]+).*")) + 0.5)
        widget:display()
    end)
end
function widget:increase()
    xbacklight.brightness = xbacklight.brightness + 1
    if tonumber(xbacklight.brightness) > 100 then
        xbacklight.brightness = 100
    end
    awful.spawn("xbacklight -set " .. xbacklight.brightness, widget:display())
end
function widget:decrease()
    xbacklight.brightness = xbacklight.brightness - 1
    if tonumber(xbacklight.brightness) < 0 then
        xbacklight.brightness = 0
    end
    awful.spawn("xbacklight -set " .. xbacklight.brightness, widget:display())
end
widget:connect_signal(
    "button::press",
    function(lx, ly, button, mods, find_widgets_result)
        if mods == 4 then --idk why mods gives the button number
            widget:increase() --even when docs say its a table, maybe i'm wrong
        elseif mods == 5 then -- tested on debian 10 buster
            widget:decrease()
        end
    end
) 
widget:get()
return widget;