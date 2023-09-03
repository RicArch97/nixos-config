---------------------------
-- Keybind configuration --
---------------------------

local awful = require("awful")

-- General Awesome keys
awful.keyboard.append_global_keybindings({
  awful.key({ modkey, "Shift" }, "c", awesome.restart,
    { description = "reload awesome config", group = "awesome" }),
})

-- Launcher keybinds
awful.keyboard.append_global_keybindings({
  awful.key({ modkey, }, "Return", function() awful.spawn(terminal) end,
    { description = "open a terminal", group = "launcher" }),
  awful.key({ modkey }, "d", function() awful.spawn.with_shell(launcher) end,
    { description = "launch rofi", group = "launcher" }),
})

-- Focus related keybindings
awful.keyboard.append_global_keybindings({
  awful.key({ modkey, }, "Left",
    function()
      awful.client.focus.byidx(-1)
    end,
    { description = "focus previous by index", group = "client" }
  ),
  awful.key({ modkey, }, "Right",
    function()
      awful.client.focus.byidx(1)
    end,
    { description = "focus next by index", group = "client" }
  ),
  awful.key({ modkey, "Shift" }, "Left", function() awful.screen.focus_relative(-1) end,
    { description = "focus the previous screen", group = "screen" }),
  awful.key({ modkey, "Shift" }, "Right", function() awful.screen.focus_relative(1) end,
    { description = "focus the next screen", group = "screen" }),
})

awful.keyboard.append_global_keybindings({
  awful.key {
    modifiers   = { modkey },
    keygroup    = "numrow",
    description = "only view tag",
    group       = "tag",
    on_press    = function(index)
      local screen = awful.screen.focused()
      if screen then
        local tag = screen.tags[index]
        if tag then
          tag:view_only()
        end
      end
    end,
  },
  awful.key {
    modifiers   = { modkey, "Control" },
    keygroup    = "numrow",
    description = "toggle tag",
    group       = "tag",
    on_press    = function(index)
      local screen = awful.screen.focused()
      if screen then
        local tag = screen.tags[index]
        if tag then
          awful.tag.viewtoggle(tag)
        end
      end
    end,
  },
  awful.key {
    modifiers   = { modkey, "Shift" },
    keygroup    = "numrow",
    description = "move focused client to tag",
    group       = "tag",
    on_press    = function(index)
      if client.focus then
        local tag = client.focus.screen.tags[index]
        if tag then
          client.focus:move_to_tag(tag)
        end
      end
    end,
  },
})

-- Client keybinds
client.connect_signal("request::default_keybindings", function()
  awful.keyboard.append_client_keybindings({
    awful.key({ modkey, }, "f",
      function(c)
        c.fullscreen = not c.fullscreen
        c:raise()
      end,
      { description = "toggle fullscreen", group = "client" }),
    awful.key({ modkey, "Shift" }, "q", function(c) c:kill() end,
      { description = "close", group = "client" }),
    awful.key({ modkey, "Shift" }, "space", awful.client.floating.toggle,
      { description = "toggle floating", group = "client" }),
    awful.key({ modkey, }, "o", function(c) c:move_to_screen() end,
      { description = "move to screen", group = "client" }),
    awful.key({ modkey, }, "t", function(c) c.ontop = not c.ontop end,
      { description = "toggle keep on top", group = "client" }),
    awful.key({ modkey, }, "minus", function(c) c.minimized = true end,
      { description = "minimize", group = "client" }),
    awful.key({ modkey, }, "equal",
      function(c)
        c.maximized = not c.maximized
        c:raise()
      end,
      { description = "(un)maximize", group = "client" }),
  })
end)
