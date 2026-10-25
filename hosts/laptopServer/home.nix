# Headless server: the home `base` (shared CLI: git, fish, fzf, direnv, …) plus
# Claude Code, kept running as a Remote Control session so the phone app / claude.ai
# can drive it. No desktop, apps, themes, or infra tooling.
{pkgs, ...}: {
  home.packages = [pkgs.claude-code];

  # Always-on Remote Control session in the resume repo. Runs inside the repo's dev
  # shell so just/typst/pdftotext are on PATH. Needs a one-time interactive `claude`
  # login (and trusting ~/resume) before it can start; until then it just retries.
  systemd.user.services.claude-remote-control = {
    Unit = {
      Description = "Claude Code Remote Control (resume)";
      After = ["network-online.target"];
      ConditionPathIsDirectory = "%h/resume";
    };
    Service = {
      WorkingDirectory = "%h/resume";
      Environment = ["PATH=/etc/profiles/per-user/muhammad/bin:/run/current-system/sw/bin"];
      ExecStart = "${pkgs.nix}/bin/nix develop %h/resume --command claude remote-control --name resume";
      Restart = "always";
      RestartSec = 30;
    };
    Install.WantedBy = ["default.target"];
  };
}
