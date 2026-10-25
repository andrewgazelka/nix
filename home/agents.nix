# Coding agents. AGENTS.md and skills/ are shared by every agent that reads
# them (Claude Code, Codex, ...); agents/claude/ is Claude Code's own config.
{ config, repo, ... }:
let
  live = path: config.lib.file.mkOutOfStoreSymlink "${repo}/agents/${path}";
in
{
  home.file = {
    ".agents/AGENTS.md".source = live "AGENTS.md";
    ".agents/skills".source = live "skills";
    ".codex/AGENTS.md".source = live "AGENTS.md";
    ".claude/CLAUDE.md".source = live "AGENTS.md";
    ".claude/skills".source = live "skills";
    ".claude/agents".source = live "claude/agents";
    ".claude/settings.json".source = live "claude/settings.json";
    ".claude/keybindings.json".source = live "claude/keybindings.json";
    ".claude/statusline.sh".source = live "claude/statusline.sh";
  };
}
