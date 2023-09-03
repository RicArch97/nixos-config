------------------------------------
-- Main config file / entry point --
------------------------------------

pcall(require, "luarocks.loader")

require("awful.autofocus")

-- created by Nix
require("globals")

require("config")
require("shell")
