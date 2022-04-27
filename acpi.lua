local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local acpi ={
    percentage = "", -- energy storage % of maximum energy storage
    capacity = "", -- maximun energy storage %, the lower the oldest battery
    status = "" -- charging status [Charging, Discharging, Full]
}
local widget = wibox.widget.textbox()
function widget:init(beautiful)
    widget.beautiful = beautiful
    return widget
end
function widget:display()
    local padding_left = ""
    if tonumber(acpi.percentage) < 10  then
        padding_left = padding_left .. "  "
    elseif tonumber(acpi.percentage) < 100 then
        padding_left = padding_left .. " "
    end
    widget.text = "[acpi:" .. padding_left .. acpi.percentage .. "%]"
end
function widget:get()
    awful.spawn.easy_async("acpi -i -b", function(stdout, stderr, exitreason, exitcode)
        acpi.status, acpi.percentage, acpi.capacity = string.match(stdout, "Battery 0: (%u%l+), (%d+).*%s(%d+)")
        widget:display()
    end)
    return true
end
widget:get()
widget.timer = gears.timer.start_new(60, function()
    widget:get()
    return true
end)
return widget;