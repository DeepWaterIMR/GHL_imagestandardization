### Empty the workspace ####

rm(list=ls())

### Load packages ####

packages<-c("tidyverse", "AgeEstimatoR");

## Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())

# if("remotes" %in% packages[!installed_packages]) {
#   install.packages("remotes")
# }

if (any(installed_packages == FALSE)) {
  
  if("AgeEstimatoR" %in% packages[!installed_packages]) {
    remotes::install_github("DeepWaterIMR/AgeEstimatoR", dependencies = TRUE,
                            upgrade = "never")
  }
  
  installed_packages <- packages %in% rownames(installed.packages())
  
  install.packages(packages[!installed_packages])
}

## Load packages
invisible(lapply(packages, library, character.only = TRUE))

# Age estimation

AgeEstimatoR::setup_python()

## Gammellupe

AgeEstimatoR::estimate_age(
  image_path = "Prosesserte_gammellupe",
  output_path = "data/gammellupe_ml_alder.csv")

## Nylupe

AgeEstimatoR::estimate_age(
  image_path = "Prosesserte_nylupe",
  output_path = "data/nylupe_ml_alder.csv")
