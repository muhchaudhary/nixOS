# Qwen Code, set up in ~/.qwen/settings.json for the llama-swap server on muhammadDesktop.
{
  pkgs,
  inputs,
  ...
}: {
  home.packages = [inputs.llm-agents.result.packages.${pkgs.stdenv.hostPlatform.system}.qwen-code];
}
