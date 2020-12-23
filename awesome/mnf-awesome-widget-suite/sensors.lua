local wibox         = require("wibox")
local awful         = require("awful")
local beautiful     = require("beautiful")
local naughty       = require("naughty")
local gears         = require("gears")
local cairo         = require("lgi").cairo
local module_path = (...):match ("(.+/)[^/]+$") or ""

local theme = beautiful.get()

local sensors = {}

local function worker(args)
    -- Arguments
    local args = args or {}

    local timeout = args.timeout or 2

    local sensors_text = wibox.widget {
        text = "\u{fa0e} --°C",
        widget = wibox.widget.textbox
    }
    local sensors_widget = wibox.widget {
        sensors_text,
        layout = wibox.layout.fixed.horizontal
    }
    
    awful.widget.watch("sensors", timeout, function(widget, stdout)
        local temp = string.match(stdout, 'temp%d+: +%+(%d+%.%d+)°C')
        if temp ~= nil then
            widget:get_children()[1]:set_text("\u{fa0e} " .. temp .. "°C")
        else
            widget:get_children()[1]:set_text("Something wrong with sensors.")
        end
    end, sensors_widget)

    local sensors_notif = nil

    sensors_widget:connect_signal("mouse::enter", function()
        if sensors_notif ~= nil then
            naughty.destroy(sensors_notif)
        end
        local f = io.popen("sensors")
        local str = "sensors"
        for line in f:lines() do
            str = str .. "\n" .. line
        end
        sensors_notif = naughty.notify {
            preset = naughty.config.presets.normal,
            timeout = 0,
            title = "Sensors Info",
            text = str
        }
    end)
    
    sensors_widget:connect_signal("mouse::leave", function()
        if sensors_notif ~= nil then
            naughty.destroy(sensors_notif)
            sensors_notif = nil
        end
    end)

    return sensors_widget
end

return setmetatable(sensors, {__call = function(_, ...) return worker(...) end})
