{
  config,
  pkgs,
  ...
}: {
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraPackages = with pkgs; [
      nixd
      nodejs
      lua-language-server
      luajitPackages.luarocks
      stylua
      alejandra
    ];
  };
}
