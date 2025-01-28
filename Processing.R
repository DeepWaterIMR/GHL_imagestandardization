## Old file. Left here for Tine until further notice. Use 1 process images.R

rm(list=ls())

packages<-c("tidyverse", "graphics", "raster", "terra", "imager", "lidaRtRee", "magick");

## Install packages not yet installed
installed_packages <- packages %in% rownames(installed.packages())

# if("remotes" %in% packages[!installed_packages]) {
#   install.packages("remotes")
# }

if (any(installed_packages == FALSE)) {
  
  # if("sdmTMBextra" %in% packages[!installed_packages]) {
  #   remotes::install_github("pbs-assess/sdmTMBextra", dependencies = TRUE,
  #                           upgrade = "never")
  # }
  
  installed_packages <- packages %in% rownames(installed.packages())
  
  install.packages(packages[!installed_packages])
}

## Load packages
invisible(lapply(packages, library, character.only = TRUE))

#For gammellupa settes fyllparameteren et sted mellom 11 og 21.
#For gammellupa ser det ut til at adjustment ca 1.35 er passelig for de fleste bilder.


#### Avkommenter følgende linjer for å standardisere bilder fra gammellupa
fillparam<-15
adj<-1.3
pathraw<-('/Users/a22357/Library/CloudStorage/OneDrive-SharedLibraries-Havforskningsinstituttet/Nilsen, Tine - GHL_imagestandardization/Råbilder_gammellupe')
pathprocessed<-('Prosesserte_gammellupe/')

#####

#For nylupa er det ikke nødvendig med fylling, sett fyllparameteren til 3. 
#For nylupa er 1.1 en passelig adjustment. 


#### Kommenter vekk følgende linjer for å standardisere bilder fra gammellupa
# fillparam<-3
# adj<-1.1 
# pathraw<-('/Users/a22357/Library/CloudStorage/OneDrive-SharedLibraries-Havforskningsinstituttet/Nilsen, Tine - GHL_imagestandardization/Råbilder_nylupe')
# pathprocessed<-('Prosesserte_nylupe/')

#####

# setwd('/Users/a37357/Library/CloudStorage/OneDrive-Havforskningsinstituttet/Bildestandardisering')

source('imstand_create_manual_lupetest.R')
for (imno in 1){
imstand_create_manual_lupetest(imno, adj, fillparam, pathraw, pathprocessed)
}