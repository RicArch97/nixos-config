-------------------------------------------------
-- Global variables used throughout the config --
-------------------------------------------------

terminal = "alacritty"
explorer = "thunar"
browser = "firefox"
editor = os.getenv("EDITOR") or "nvim"
visual_editor = "code"
editor_cmd = terminal .. " -e " .. editor
modkey = "Mod4"