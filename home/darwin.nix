# macOS: window manager, background agents, default apps.
{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  logs = "${config.home.homeDirectory}/Library/Logs";
  lifelog = inputs.lifelog.packages.${pkgs.stdenv.hostPlatform.system}.lifelog;

  # Browser tabs on these sites get redirected; apps that talk to them
  # (Beeper, OAuth) keep working, unlike the DNS sinkhole in darwin/blocklist.nix.
  blockedTabs = [
    "threads.net"
    "tiktok.com"
    "facebook.com"
    "bsky.app"
    "pinterest.com"
    "tumblr.com"
  ];
  tabBlocklist = pkgs.writeShellScript "tab-blocklist" ''
    while :; do
      /usr/bin/osascript -l JavaScript ${../config/tab-blocklist.js} \
        ${lib.escapeShellArgs blockedTabs} || true
      sleep 1
    done
  '';

  workspaces = lib.range 1 9;
  directions = {
    h = "left";
    j = "down";
    k = "up";
    l = "right";
  };
in
{
  programs.aerospace = {
    enable = true;
    launchd.enable = true;
    settings = {
      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = false;
      accordion-padding = 100;
      workspace-to-monitor-force-assignment = lib.genAttrs (map toString workspaces) (
        n: if n == "9" then "secondary" else "main"
      );

      mode.main.binding =
        lib.listToAttrs (
          lib.concatMap (n: [
            (lib.nameValuePair "alt-${toString n}" "workspace ${toString n}")
            (lib.nameValuePair "alt-shift-${toString n}" "move-node-to-workspace ${toString n}")
          ]) workspaces
        )
        // lib.mapAttrs' (
          key: dir: lib.nameValuePair "alt-${key}" "focus --boundaries-action stop --ignore-floating ${dir}"
        ) directions
        // lib.mapAttrs' (key: dir: lib.nameValuePair "ctrl-alt-shift-${key}" "move ${dir}") directions
        // lib.mapAttrs' (key: dir: lib.nameValuePair "alt-shift-${key}" "join-with ${dir}") directions
        // {
          alt-tab = "workspace-back-and-forth";
          alt-backtick = "focus-back-and-forth";
          alt-a = "layout tiles accordion";
          alt-shift-e = "balance-sizes";
          alt-shift-minus = "resize smart -50";
          alt-shift-equal = "resize smart +50";
        };

      on-window-detected =
        map
          (app: {
            "if".app-id = app;
            run = "layout floating";
          })
          [
            "com.apple.FaceTime"
            "com.obsproject.obs-studio"
            "com.paulsolt.SuperEasyTimerMac"
          ]
        ++
          map
            (app: {
              "if".app-id = app;
              run = "layout tiling";
            })
            [
              "com.linear"
              "com.microsoft.Excel"
              "notion.id"
            ];
    };
  };

  launchd.agents = {
    lifelog = {
      enable = true;
      config = {
        ProgramArguments = [
          (lib.getExe lifelog)
          "record"
          "--listen"
          "127.0.0.1:5599"
        ];
        KeepAlive = true;
        RunAtLoad = true;
        StandardErrorPath = "${logs}/lifelog.log";
      };
    };

    tab-blocklist = {
      enable = true;
      config = {
        ProgramArguments = [ "${tabBlocklist}" ];
        KeepAlive = true;
        RunAtLoad = true;
        StandardErrorPath = "${logs}/tab-blocklist.log";
      };
    };
  };

  # Ghostty is the default terminal.
  home.activation.defaultApps = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${lib.getExe pkgs.duti} -s com.mitchellh.ghostty public.unix-executable shell || true
    ${lib.getExe pkgs.duti} -s com.mitchellh.ghostty .command all || true
  '';
}
