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
    hash = "NzA4ZGIyYjIwODkzNzQyN2MwY2RiZTRiNWY0YjIxODExNTgxZWY2ZA==";
  };
  nativeBuildInputs = [
    jdupes
    sassc
  ];
}
