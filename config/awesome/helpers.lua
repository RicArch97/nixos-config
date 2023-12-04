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

return helpers
