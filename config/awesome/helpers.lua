-------------------------------------------------
-- Helper functions used thoughout the configs --
-------------------------------------------------

local beautiful = require("beautiful")
local gears = require("gears")

local helpers = {}

-- Creates a rounded rectangle with given radius
function helpers.create_rounded_rect(radius)
    return function(cr, w, h)
        return gears.shape.rounded_rect(cr, w, h, radius)
    end
end

-- Turns Any String Into This Style
function helpers.title_style_capitalize(string)
    local capitalize = function(word)
        return word:gsub("^%l", string.upper)
    end

    return string:gsub('-', ' '):gsub("(%S+)", capitalize)
end

-- Set a wallpaper on a specific sceen
function helpers.set_wallpaper(screen, stretch)
    if stretch ~= nil then
        stretch = type(stretch) == "boolean" and stretch or false
    else
        stretch = false
    end

    if beautiful.wallpaper then
        local offsets = { x = 0, y = 0 }
        gears.wallpaper.maximized(beautiful.wallpaper, screen, stretch, offsets)
    end
end

return helpers
