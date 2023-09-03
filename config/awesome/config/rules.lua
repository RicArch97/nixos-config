-------------------------
-- Rules configuration --
-------------------------

local awful = require("awful")
local ruled = require("ruled")

-- Rules to apply to new clients.
ruled.client.connect_signal("request::rules", function()
  -- All clients will match this rule.
  ruled.client.append_rule {
    id         = "global",
    rule       = {},
    properties = {
      focus     = awful.client.focus.filter,
      raise     = true,
      screen    = awful.screen.focused,
      placement = awful.placement.centered
    }
  }

  -- Floating clients.
  ruled.client.append_rule {
    id         = "floating",
    rule_any   = {
      instance = { "pinentry" },
      role     = {
        "pop-up",
      }
    },
    properties = { floating = true }
  }

  -- Add titlebars to normal clients
  ruled.client.append_rule {
    id         = "titlebars",
    rule_any   = { type = { "normal" } },
    properties = { titlebars_enabled = true }
  }
end)
