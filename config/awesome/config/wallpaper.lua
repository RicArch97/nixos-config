-----------------------------
-- Wallpaper configuration --
-----------------------------

local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")

screen.connect_signal("request::wallpaper", function(s)
  awful.wallpaper {
    screen = s,
    widget = {
      vertical_fit_policy   = "fit",
      image                 = beautiful.wallpaper,
      widget                = wibox.widget.imagebox,
    },
  }
end)
