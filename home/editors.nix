# Editors and the terminal. Their settings are linked live from config/, so
# changes made in the apps land in the repo.
{
  config,
  pkgs,
  repo,
  ...
}:
let
  live = path: config.lib.file.mkOutOfStoreSymlink "${repo}/config/${path}";
  appSupport = "Library/Application Support";
in
{
  home.packages = [
    pkgs.neovim
    pkgs.tree-sitter
  ];

  xdg.configFile = {
    "nvim".source = live "nvim";
    "ghostty".source = live "ghostty";
    "zed/settings.json".source = live "zed/settings.json";
    "zed/keymap.json".source = live "zed/keymap.json";
  };

  home.file = {
    "${appSupport}/Cursor/User/settings.json".source = live "cursor/settings.json";
    "${appSupport}/Cursor/User/keybindings.json".source = live "cursor/keybindings.json";
  };
}
