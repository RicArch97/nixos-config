------------------------------------------------------
-- Right click menu and menubar shell configuration --
------------------------------------------------------

local awful = require("awful")
local beautiful = require("beautiful")
local helpers = require("helpers")
local menubar = require("menubar")
local wibox = require("wibox")

local menu = {}

-- {{{ Right click menu
menu.awesome = {
    { "Edit Config",       visual_editor .. " " .. "/etc/nixos-config" },
    { "Restart",           awesome.restart },
    { "Quit",              function() awesome.quit() end }
}

menu.main = awful.menu {
    items = {
        { "Terminal",   terminal },
        { "Explorer",   file_manager },
        { "Browser",    browser },
        { "Editor",     visual_editor },
        { "Awesome",    menu.awesome },
    }
}

-- style
function menu.create_rounded_menu(menu_obj)
    -- anti aliasing using hack
    menu_obj.wibox.shape = helpers.create_rounded_rect(12)
    menu_obj.wibox.bg = beautiful.bg_normal .. '00'
    menu_obj.wibox:set_widget(wibox.widget {
        menu_obj.wibox.widget,
        widget = wibox.container.background,
        bg = beautiful.bg_normal,
        shape = helpers.create_rounded_rect(12),
    })

    return menu_obj
end

menu.create_rounded_menu(menu.main)

menu.default_new = awful.menu.new
-- replace the default menu contructor with our rounded menu
-- this way submenus are also styled correctly
function awful.menu.new(...)
    return menu.create_rounded_menu(menu.default_new(...))
end

-- }}}

-- Menubar configuration
menubar.utils.terminal = terminal

return menu
