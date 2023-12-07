{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation rec {
  name = "aylurs-ags-dots";
  src = fetchFromGitHub {
    owner = "Aylur";
    repo = "dotfiles";
    rev = "b64b5bf196c98abf31b0247bdc696518986286f0";
    hash = "sha256-Nj5GuDLqmqoXWH+VD7olRRo6ZohC3EB5ITQXXTHtATA=";
  };
  buildCommand = ''
    mkdir -p $out && cp -r ${src}/ags/* $out
  '';
}
