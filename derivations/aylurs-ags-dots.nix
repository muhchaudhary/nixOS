{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  jdupes,
  sassc,
  ...
}:
stdenvNoCC.mkDerivation rec {
  name = "aylurs-ags-dots";
  src = fetchFromGitHub {
    owner = "Aylur";
    repo = "dotfiles";
    rev = "b64b5bf196c98abf31b0247bdc696518986286f0";
    hash = "sha256-NxIWH3qLW8sEguovAv9wfgnlnmPlTipRJTmMo3rSHNY=";
  };
  nativeBuildInputs = [
    jdupes
    sassc
  ];
  postPatch = ''
    rm -rf home-manager
  '';

  installPhase = ''
    runHook preInstall
    name= HOME="$TMPDIR"

    jdupes --quiet --link-soft --recurse $out/share

    runHook postInstall
  '';
  buildCommand = ''
    mkdir $out
  '';
}
