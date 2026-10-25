{
  config,
  lib,
  pkgs,
  ...
}:
let
  signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPSZ+Pm8k0eiCcVg8NNxBdjEUyBTI1h5SkOUtxEiEDjB";
in
{
  programs.git = {
    enable = true;
    lfs.enable = true;
    signing = {
      format = "ssh";
      # The on-disk key, so signing never waits on 1Password.
      key = "${config.home.homeDirectory}/.ssh/id_ed25519";
      signByDefault = pkgs.stdenv.hostPlatform.isDarwin;
    };
    settings = {
      user = {
        name = "Andrew Gazelka";
        email = "andrew.gazelka@gmail.com";
      };
      alias = {
        lg = "log --pretty=format:'%s %C(dim)%h%C(reset)'";
        dft = "diff --ext-diff";
        sync = "!git pull --rebase && git push";
      };
      core = {
        excludesfile = "${../config/gitignore}";
        untrackedcache = true;
      };
      init.defaultBranch = "main";
      commit = {
        verbose = true;
        cleanup = "scissors";
      };
      pull.rebase = true;
      push = {
        autoSetupRemote = true;
        followTags = true;
      };
      fetch = {
        prune = true;
        parallel = 0;
      };
      rebase = {
        autoSquash = true;
        autoStash = true;
        updateRefs = true;
      };
      merge = {
        conflictstyle = "zdiff3";
        ff = false; # every branch lands as one revertable merge
      };
      rerere = {
        enabled = true;
        autoupdate = true;
      };
      diff = {
        algorithm = "histogram";
        external = "difft";
      };
      log.date = "relative";
      blame.coloring = "highlightRecent";
      advice.statusHints = false;
      column.ui = "auto";
      branch.sort = "-committerdate";
      maintenance.auto = false;
      gpg.ssh.allowedSignersFile = "${pkgs.writeText "allowed-signers" ''
        andrew.gazelka@gmail.com namespaces="git" ${signingKey}
      ''}";
      credential."https://github.com".helper = [
        ""
        "!${pkgs.gh}/bin/gh auth git-credential"
      ];
      credential."https://gist.github.com".helper = [
        ""
        "!${pkgs.gh}/bin/gh auth git-credential"
      ];
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = true;
    };
  };
}
