# All AI coding agents. Packages come from the llm-agents pin (numtide/llm-agents.nix,
# rebuilt daily upstream, served from cache.numtide.com; see modules/nixos/nix.nix), so they
# are updated together with `npins update llm-agents`. Only the packages are managed: each
# tool's config stays a plain writable file so the tools (and e.g. MCP installers) can edit it.
{...}: {
  imports = [
    ./claude.nix
    ./opencode.nix
    ./pi.nix
    ./qwen-code.nix
    ./t3code.nix
  ];
}
