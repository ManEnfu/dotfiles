local module_path = (...):match ("(.+/)[^/]+$") or ""


local mod = {
    battery = require(module_path .. "mnf-awesome-widget-suite.battery"),
    sensors = require(module_path .. "mnf-awesome-widget-suite.sensors"),
    volume = require(module_path .. "mnf-awesome-widget-suite.volume"),
}

return mod
