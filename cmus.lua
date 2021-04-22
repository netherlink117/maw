local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local debug = false
local cmus = {
    status = "status",
    duration = "duration",
    position = "position",
    title = "title",
    album = "album",
    artist = "artist",
    albumartist = "albumartist",
    time = {
        total = {
            hours = 0,
            minutes = 0,
            seconds = 0
        },
        pased = {
            hours = 0,
            minutes = 0,
            seconds = 0
        }
    },
    format = 1
}
local widget = wibox.widget.textbox()
local space = 20
function widget:init(beautiful)
    widget.beautiful = beautiful
    return widget
end
function widget:display()
    local text = "label"
    if cmus.status == "off" then
        text = cmus.status
    else
        if debug then
            widget.text = "[" .. cmus.status .. "|" .. cmus.duration .. "|" .. cmus.position .. "|" .. cmus.title.. "|" .. cmus.album .. "|" .. cmus.artist .. "]"
            return 1
        elseif cmus.format == 1 then -- formats
            text = cmus.title
        elseif cmus.format == 2 then
            text = cmus.artist
        elseif cmus.format == 3 then
            cmus.time.total.hours = math.floor(cmus.duration / 3600)
            cmus.time.total.minutes = math.floor((cmus.duration - (cmus.time.total.hours * 3600)) / 60)
            cmus.time.total.seconds = math.floor(cmus.duration - ((cmus.time.total.hours * 3600) + (cmus.time.total.minutes * 60)))
            cmus.time.pased.hours = math.floor(cmus.position / 3600)
            cmus.time.pased.minutes = math.floor((cmus.position - (cmus.time.pased.hours * 3600)) / 60)
            cmus.time.pased.seconds = math.floor(cmus.position - ((cmus.time.pased.hours * 3600) + (cmus.time.pased.minutes * 60)))
            if cmus.time.total.hours > 0 then
                text = string.format("%02d:%02d:%02ds-%02d:%02d:%02ds", cmus.time.pased.hours, cmus.time.pased.minutes, cmus.time.pased.seconds, cmus.time.total.hours, cmus.time.total.minutes, cmus.time.total.seconds)
            else
                text = string.format("%02d:%02ds-%02d:%02ds", cmus.time.pased.minutes, cmus.time.pased.seconds, cmus.time.total.minutes, cmus.time.total.seconds)
            end
        end
    end
    if string.len(text) > space and (not (cmus.format == 3)) then -- if format is not time
        text = string.sub(text, 1, space - 4) .. "..." -- cut the title to match the space
    end
    if (string.len(text) % 2) > 0 then
        text = " " .. text
    end
    while string.len(text) < space do --align to right adding padding spaces
        text = " " .. text .. " "
    end
    widget.text = "[cmus:" .. text .. "]"
end
function widget:get()
    awful.spawn.with_line_callback("cmus-remote -Q", {
        stdout = function(line)
            if string.find(line, "not running") then
                cmus.status = "off"
            elseif string.find(line, "status") then
                cmus.status = string.match(line, "status (.+)")
            elseif string.find(line, "duration") then
                cmus.duration = string.match(line, "duration (%d+)")
            elseif string.find(line, "position") then
                cmus.position = string.match(line, "position (%d+)")
            elseif string.find(line, "%stitle") then
                cmus.title = string.match(line, "tag title (.+)")
            elseif string.find(line, "%salbumartist") then
                cmus.albumartist = string.match(line, "tag albumartist (.+)")
            elseif string.find(line, "%salbum") then
                cmus.album = string.match(line, "tag album (.+)")
            elseif string.find(line, "%sartist") then
                cmus.artist = string.match(line, "tag artist (.+)")
            end
            widget:display()
        end
    })
end
function widget:play()
    if not (cmus.status == "off") then
        awful.spawn("cmus-remote -p")
    end
end
function widget:stop()
    if not (cmus.status == "off") then
        awful.spawn("cmus-remote -s")
    end
end
function widget:pause()
    if not (cmus.status == "off") then
        awful.spawn("cmus-remote -u")
    end
end
function widget:toggle(arg)
    if cmus.status == "playing" then
        if arg == "stop" then
            widget:stop()
        else
            widget:pause()
        end
    elseif cmus.status == "paused" then 
        widget:play()
    elseif cmus.status == "stopped" then
        widget:play()
    end
end
function widget:next()
    if not (cmus.status == "off") then
        awful.spawn("cmus-remote -n")
    end
end
function widget:previous()
    if not (cmus.status == "off") then
        awful.spawn("cmus-remote -r")
    end
end
widget:connect_signal(
    "button::press",
    function(lx, ly, button, mods, find_widgets_result)
        if mods == 1 then --in theory it should be button, but using mods since it works
            local format = cmus.format + 1
            if format > 3 then
                format = 1
            end
            cmus.format = format
        end
    end
)
widget:get()
widget.timer = gears.timer.start_new(0.5, function()
    widget:get()
    return true
end)
return widget;
