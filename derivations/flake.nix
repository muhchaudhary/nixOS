{
  description = "Custom NixOS Derivations";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }@inputs:
  flake-utils.lib.eachDefaultSystem ( system:
    let
      pkgs = import nixpkgs {
        inherit system;
      };
    in {
      packages = with pkgs; {
        vscode-nv = callPackage ./vscode.nix {};
      };
    }
  );
}