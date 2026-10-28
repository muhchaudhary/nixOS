# Coding agents for the llama-swap server on muhammadDesktop (~/Documents/LLMs), reached
# over the tailnet. Both default to qwen3.8-27b; llama-swap reloads on every model change,
# so OpenCode's small_model is pinned to the same ID.
{pkgs, ...}: let
  baseURL = "https://muhammaddesktop.tail1f99a6.ts.net/v1";
  model = "qwen3.8-27b";
in {
  # Qwen Code reads its OpenAI-compatible provider from the environment.
  home.packages = [pkgs.qwen-code];
  home.sessionVariables = {
    OPENAI_BASE_URL = baseURL;
    OPENAI_API_KEY = "llama-swap"; # unchecked; the server is tailnet-only
    OPENAI_MODEL = model;
  };

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
