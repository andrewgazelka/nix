# nushell is the login shell; zsh stays for scripts and agents.
{
  config,
  lib,
  pkgs,
  repo,
  ...
}:
let
  nuDir = "Library/Application Support/nushell";
  live = path: config.lib.file.mkOutOfStoreSymlink "${repo}/${path}";

  # Prompt, jump and history hooks, generated from the installed binaries.
  vendor =
    pkgs.runCommand "nushell-vendor"
      {
        nativeBuildInputs = [
          pkgs.starship
          pkgs.zoxide
          pkgs.atuin
        ];
      }
      ''
        export HOME=$TMPDIR
        mkdir -p $out/autoload
        starship init nu > $out/autoload/starship.nu
        zoxide init nushell > $out/autoload/zoxide.nu
        atuin init nu --disable-up-arrow > $out/autoload/atuin.nu
      '';
in
{
  home.packages = [
    pkgs.nushell
    pkgs.tmux
    pkgs.vivid # LS_COLORS for nushell's theme
  ];

  # Link each entry, not the whole directory: nushell writes history there.
  home.file =
    lib.mapAttrs' (
      name: _: lib.nameValuePair "${nuDir}/${name}" { source = live "config/nushell/${name}"; }
    ) (builtins.readDir ../config/nushell)
    // {
      "${nuDir}/vendor".source = vendor;
      ".config/nushell-hm-session-vars.nu".text = lib.concatLines (
        lib.mapAttrsToList (
          name: value: "$env.${name} = ${builtins.toJSON (toString value)}"
        ) config.home.sessionVariables
      );
    };

  programs.zsh = {
    enable = true;
    # Agents (CLAUDECODE=1) get plain ls.
    initContent = ''
      if [[ -z ''${CLAUDECODE-} ]]; then
        alias ls='eza --git --time-style=relative' ll='ls -l' la='ls -a' lt='ls --tree'
      fi
    '';
  };

  programs.starship = {
    enable = true;
    enableNushellIntegration = false; # loaded by vendor/autoload
    presets = [ "nerd-font-symbols" ];
    settings = lib.importTOML ../config/starship.toml;
  };

  programs.atuin = {
    enable = true;
    enableNushellIntegration = false;
    flags = [ "--disable-up-arrow" ];
    daemon.enable = true;
    settings = {
      auto_sync = true;
      enter_accept = true;
      style = "compact";
      update_check = false;
      search_mode = "daemon-fuzzy";
      workspaces = true;
      store_failed = true;
      secrets_filter = true;
      sync.records = true;
      daemon.sync_frequency = 15;
    };
  };

  programs.zoxide = {
    enable = true;
    enableNushellIntegration = false;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config.global.log_format = ""; # quiet
  };

  programs.eza = {
    enable = true;
    git = true;
    icons = "auto";
    enableZshIntegration = false;
  };

  programs.fzf = {
    enable = true;
    historyWidget.command = ""; # atuin owns ctrl-r
  };
  programs.bat.enable = true;
  programs.yazi = {
    enable = true;
    shellWrapperName = "y";
  };

  xdg.configFile."tmux/tmux.conf".source = ../config/tmux.conf;
}
