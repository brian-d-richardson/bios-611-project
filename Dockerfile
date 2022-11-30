FROM rocker/verse

RUN r -e "install.packages(\"ggplot2\")"
RUN r -e "install.packages(\"tidyr\")"
RUN r -e "install.packages(\"dplyr\")"
RUN r -e "install.packages(\"kableExtra\")"
RUN r -e "install.packages(\"stringr\")"
RUN r -e "install.packages(\"imager\")"

RUN Rscript --no-restore --no-save -e "remotes::install_github('eddelbuettel/rcppcorels')"
