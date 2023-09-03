-----------------------------
-- Wallpaper configuration --
-----------------------------

local helpers = require("helpers")

screen.connect_signal("request::wallpaper", function(s)
  helpers.set_wallpaper(s, false)
end)
