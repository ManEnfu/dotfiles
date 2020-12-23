local wibox         = require("wibox")
local awful         = require("awful")
local beautiful     = require("beautiful")
local naughty       = require("naughty")
local gears         = require("gears")
local cairo         = require("lgi").cairo
local module_path = (...):match ("(.+/)[^/]+$") or ""

local theme = beautiful.get()

local cool_battery_widget = {}

local function worker(args)
    -- Arguments
    local args = args or {}

    local timeout = args.timeout or 2

    -- Widget Components
    local batt_level_text = wibox.widget.textbox()
    batt_level_text:set_text("\u{f240}  --%")

    batt_widget = wibox.widget {
        batt_level_text,
        layout = wibox.layout.fixed.horizontal
    }

    -- Monitor battery level using acpi
    awful.widget.watch("acpi", timeout, function(widget, stdout)
        local status, charge = string.match(stdout, '.+: ([%a ]+), (%d?%d?%d)%%')
        if status ~= nil then
            local charge_value = tonumber(charge)
            local battery_symbol = "\u{f240}  "
            if charge_value >= 0 and charge_value < 12.5 then
                battery_symbol = "\u{f244}  "
            elseif charge_value >= 12.5 and charge_value < 37.5 then
                battery_symbol = "\u{f243}  "
            elseif charge_value >= 37.5 and charge_value < 62.5 then
                battery_symbol = "\u{f242}  "
            elseif charge_value >= 62.5 and charge_value < 87.5 then
                battery_symbol = "\u{f241}  "
            end
            local status_symbol = (status == "Charging") and "\u{f492} " or ""
            widget:get_children()[1]:set_text(battery_symbol .. status_symbol ..  charge .. "%")
        else
            widget:get_children()[1]:set_text("Something wrong with ACPI.")
        end
    end, batt_widget)

    -- Display detail through notification
    local batt_notif = nil

    batt_widget:connect_signal("mouse::enter", function()
        if batt_notif ~= nil then
            naughty.destroy(batt_notif)
        end
        local f = io.popen("acpi -i")
        local str = "ACPI"
        for line in f:lines() do
            str = str .. "\n" .. line
        end
        batt_notif = naughty.notify {
            preset = naughty.config.presets.normal,
            timeout = 0,
            title = "Battery Info",
            text = str
        }
    end)
    
    batt_widget:connect_signal("mouse::leave", function()
        if batt_notif ~= nil then
            naughty.destroy(batt_notif)
            batt_notif = nil
        end
    end)

    return batt_widget
end

return setmetatable(cool_battery_widget, {__call = function(_, ...) return worker(...) end})
