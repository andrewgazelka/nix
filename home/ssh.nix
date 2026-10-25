{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "github.com" = {
        ControlMaster = "auto";
        ControlPath = "~/.ssh/controlmasters/%r@%h-%p";
        ControlPersist = "10m";
        ServerAliveInterval = 60;
      };
      "*" = {
        ForwardAgent = false;
        AddKeysToAgent = "no";
        HashKnownHosts = false;
        IdentityFile = [
          "~/.ssh/id_ed25519"
          "~/.ssh/id_ed25519_legacy"
        ];
        SetEnv = {
          TERM = "xterm-256color";
          COLORTERM = "truecolor";
        };
      };
    };
  };

  home.file.".ssh/controlmasters/.keep".text = "";
}
