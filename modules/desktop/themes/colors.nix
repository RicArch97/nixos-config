# Colors based on Xresources
{
  config,
  options,
  lib,
  ...
}: let
  colorType =
    lib.types.addCheck lib.types.str (x: !isNull (builtins.match "#[0-9a-fA-F]{6}" x));
  color = defaultColor:
    lib.mkOption {
      type = colorType;
      default = defaultColor;
    };
in {
  options.modules.desktop.themes.colors = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
    # Github dark color scheme & types
    colors = {
      color0 = color "#484f58";
      color1 = color "#ff7b72";
      color2 = color "#3fb950";
      color3 = color "#d29922";
      color4 = color "#58a6ff";
      color5 = color "#bc8cff";
      color6 = color "#39c5cf";
      color7 = color "#b1bac4";
      color8 = color "#6e7681";
      color9 = color "#ffa198";
      color10 = color "#56d364";
      color11 = color "#e3b341";
      color12 = color "#79c0ff";
      color13 = color "#d2a8ff";
      color14 = color "#56d4dd";
      color15 = color "#f0f6fc";
    };
    types = {
      background = color "#0d1117";
      background-darker = color "#010409";
      foreground = color "#b3b1ad";
      highlight = color "#f78166";
      border = color "#30363d";
      selection = color "#2d3139";
      current-line = color "#171b22";
    };
    syntax = {
      comment = color "#8b949e";
      keyword = color "#ff7b72";
      function = color "#d2a8ff";
      variable = color "#ffa657";
      string = color "#a5d6ff";
      label = color "#79c0ff";
    };
    diagnostic = {
      error = color "#f85149";
      warning = color "#f0883e";
    };
  };
}
