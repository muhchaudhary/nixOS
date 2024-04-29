{
  config,
  pkgs,
  lib,
  ...
}: {
  home.packages = with pkgs; [
    rstudio
    (rWrapper.override
      {
        packages = with rPackages; [
          Hmisc
          tidytable
          eikosograms
          venneuler
          languageserver
          rmarkdown
          ggplot2
          dplyr
          xts
          jsonlite
          aplpack
          loon
          loon_data
          png
          qqtest
          PairViz
          hexbin
          qrmdata
          devtools
          colorspace
          jpeg
          tiff
        ];
      })
  ];
}
