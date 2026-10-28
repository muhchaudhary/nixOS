# Coding agents for the llama-swap server on muhammadDesktop (~/Documents/LLMs), reached
# over the tailnet. Both default to qwen3.8-27b; llama-swap reloads on every model change,
# so OpenCode's small_model is pinned to the same ID.
{
  pkgs,
  lib,
  ...
}: let
  baseURL = "https://muhammaddesktop.tail1f99a6.ts.net/v1";
  model = "qwen3.8-27b";

  qwenSettings = {
    env.LLAMA_SWAP_API_KEY = "llama-swap"; # unchecked; the server is tailnet-only
    security.auth.selectedType = "openai";
    model.name = model;
    modelProviders.openai = [
      {
        id = model;
        name = "Qwen3.8 27B";
        baseUrl = baseURL;
        envKey = "LLAMA_SWAP_API_KEY";
        generationConfig.contextWindowSize = 242688;
      }
      {
        id = "qwen3.8-27b-hyperqwen";
        name = "Qwen3.8 27B (vLLM)";
        baseUrl = baseURL;
        envKey = "LLAMA_SWAP_API_KEY";
        generationConfig.contextWindowSize = 150000;
      }
    ];
  };
in {
  home.packages = [pkgs.qwen-code];

  # Qwen Code writes its own state into ~/.qwen/settings.json, so merge our keys into it
  # on activation instead of making it a read-only store symlink.
  home.activation.qwenSettings = lib.hm.dag.entryAfter ["writeBoundary"] ''
    f="$HOME/.qwen/settings.json"
    run mkdir -p "$HOME/.qwen"
    [ -s "$f" ] || echo '{}' > "$f"
    tmp=$(mktemp)
    ${lib.getExe pkgs.jq} --argjson s ${lib.escapeShellArg (builtins.toJSON qwenSettings)} \
      '. * $s' "$f" > "$tmp" && run mv "$tmp" "$f"
  '';

  programs.opencode = {
    enable = true;
    settings = {
      provider.desktop = {
        npm = "@ai-sdk/openai-compatible";
        name = "Desktop (llama-swap)";
        options.baseURL = baseURL;
        models = {
          ${model} = {
            name = "Qwen3.8 27B";
            limit = {
              context = 242688;
              output = 32768;
            };
          };
          "qwen3.8-27b-hyperqwen" = {
            name = "Qwen3.8 27B (vLLM)";
            limit = {
              context = 150000;
              output = 32768;
            };
          };
        };
      };
      model = "desktop/${model}";
      small_model = "desktop/${model}";
    };
  };
}
