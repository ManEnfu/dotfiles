local wibox         = require("wibox")
local awful         = require("awful")
local beautiful     = require("beautiful")
local naughty       = require("naughty")
local gears         = require("gears")
local cairo         = require("lgi").cairo
local module_path = (...):match ("(.+/)[^/]+$") or ""

local theme = beautiful.get()

local memory = {}

local function worker(args)
    -- Arguments
    local args = args or {}

    local timeout = args.timeout or 2

    local memory_text = wibox.widget {
        text = " ----MiB",
        widget = wibox.widget.textbox
    }
    local memory_widget = wibox.widget {
        memory_text,
        layout = wibox.layout.fixed.horizontal
    }
    
    awful.widget.watch("free --mebi", timeout, function(widget, stdout)
        local used = string.match(stdout, 'Mem: +%d+ +(%d+)')
        if used ~= nil then
            widget:get_children()[1]:set_text(" " .. used .. "MiB")
        else
            widget:get_children()[1]:set_text("Something wrong with memory.")
        end
    end, memory_widget)

    local memory_notif = nil

    memory_widget:connect_signal("mouse::enter", function()
        if memory_notif ~= nil then
            naughty.destroy(memory_notif)
        end
        local f = io.popen("free --mebi")
        local str = "free"
        for line in f:lines() do
            str = str .. "\n" .. line
        end
        memory_notif = naughty.notify {
            preset = naughty.config.presets.normal,
            timeout = 0,
            title = "Memory Info",
            text = str
        }
    end)
    
    memory_widget:connect_signal("mouse::leave", function()
        if memory_notif ~= nil then
            naughty.destroy(memory_notif)
            memory_notif = nil
        end
    end)

    return memory_widget
end

return setmetatable(memory, {__call = function(_, ...) return worker(...) end})
