local wibox         = require("wibox")
local awful         = require("awful")
local beautiful     = require("beautiful")
local naughty       = require("naughty")
local gears         = require("gears")
local cairo         = require("lgi").cairo
local module_path = (...):match ("(.+/)[^/]+$") or ""

local theme = beautiful.get()

local volume = {}

local function worker(args)
    -- Arguments
    local args = args or {}
    
    local timeout = args.timeout or 2
    local card = args.card or 0
    local use_buttons = args.use_buttons or false
    local keys = args.keys or nil


    local volume_text = wibox.widget {
        text = "\u{fa7d} --%",
        widget = wibox.widget.textbox
    }
    local volume_widget = wibox.widget {
        volume_text,
        layout = wibox.layout.fixed.horizontal
    }
   
    local function update_widget(widget, stdout)
        local volume_level = string.match(stdout, '(%-?%d+)%%')
        if volume_level ~= nil then 
            widget:get_children()[1]:set_text("\u{fa7d} " .. volume_level .. "%")
        else
            widget:get_children()[1]:set_text("Something wrong with volume.")
        end
    end

    awful.widget.watch("amixer -c" .. card .. " sget Master ", timeout, function(widget, stdout)
        update_widget(widget, stdout)
    end, volume_widget)

    local volume_notif = nil

    volume_widget:connect_signal("mouse::enter", function()
        if volume_notif ~= nil then
            naughty.destroy(volume_notif)
        end
        local f = io.popen("amixer -c" .. card .. " sget Master ")
        local str = "amixer -c" ..card .. " sget Master"
        for line in f:lines() do
            str = str .. "\n" .. line
        end
        volume_notif = naughty.notify {
            preset = naughty.config.presets.normal,
            timeout = 0,
            title = "Volume Info",
            text = str
        }
    end)
    
    volume_widget:connect_signal("mouse::leave", function()
        if volume_notif ~= nil then
            naughty.destroy(volume_notif)
            volume_notif = nil
        end
    end)

    volume_widget.keylist = gears.table.join(
        awful.key({ }, "XF86AudioRaiseVolume", function()
            awful.spawn.with_shell("amixer -c" .. card .. " sset Master playback 5+", false)
            awful.spawn.easy_async_with_shell("amixer -c" .. card .. " sget Master", function(stdout, stderr, exr, exc)
                update_widget(volume_widget, stdout)
            end)
            awful.spawn.with_shell("aplay ~/.config/awesome/sound_click_tick.wav", false)
        end, {description = "volume up", group = "awesome"}),
        awful.key({ }, "XF86AudioLowerVolume", function()
            awful.spawn.with_shell("amixer -c" .. card .. " sset Master playback  5-", false)
            awful.spawn.easy_async_with_shell("amixer -c" .. card .. " sget Master", function(stdout, stderr, exr, exc)
                update_widget(volume_widget, stdout)
            end)
            awful.spawn.with_shell("aplay ~/.config/awesome/sound_click_tick.wav", false)
        end, {description = "volume down", group = "awesome"}),
        awful.key({ }, "XF86AudioMute", function()
            awful.spawn.with_shell("amixer -c" .. card .. " sset Master toggle")
            awful.spawn.easy_async_with_shell("amixer -c" .. card .. " sget Master", function(stdout, stderr, exr, exc)
                update_widget(volume_widget, stdout)
            end)
            awful.spawn.with_shell("aplay ~/.config/awesome/sound_click_tick.wav", false)
        end, {description = "volume (un)mute", group = "awesome"})
    )

    return volume_widget
end

return setmetatable(volume, {__call = function(_, ...) return worker(...) end})
