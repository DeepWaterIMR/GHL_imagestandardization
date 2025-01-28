## ---------------------------
##
## Script name: 
##
## Purpose of script:
##
## Author: Tine Nilsen, Mikko Vihtakari, Kristin Windsland // Institute of Marine Research, Norway
## Email: mikko.vihtakari@hi.no
##
## Date Created: 2025-01-28
##
## ---------------------------

# Header ####

### Empty the workspace ####

rm(list=ls())

### Load packages ####

packages<-c("tidyverse", "graphics", "raster", "terra", "imager", "lidaRtRee");

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

### Source or list custom functions used within the script ####

source("R/standardize_image.R")

#########################
# Process the images ####

## Old microscope
# For gammellupa settes fyllparameteren et sted mellom 11 og 21.
# For gammellupa ser det ut til at adjustment ca 1.35 er passelig for de fleste bilder.

pathraw <- normalizePath('/Users/a22357/Library/CloudStorage/OneDrive-SharedLibraries-Havforskningsinstituttet/Nilsen, Tine - GHL_imagestandardization/Råbilder_gammellupe')

for (imno in 1:3) { # length(list.files(pathraw))
  standardize_image(
    imno, adj = 1.35, fillparam = 15, pathraw = pathraw, 
    pathprocessed = 'Prosesserte_gammellupe/'
    )
}

## New microscope
# For nylupa er det ikke nødvendig med fylling, sett fyllparameteren til 3. 
# For nylupa er 1.1 en passelig adjustment. 

pathraw <- normalizePath('/Users/a22357/Library/CloudStorage/OneDrive-SharedLibraries-Havforskningsinstituttet/Nilsen, Tine - GHL_imagestandardization/Råbilder_nylupe')

for (imno in 1:3) { # length(list.files(pathraw))
  standardize_image(
    imno, adj = 1.1, fillparam = 3, pathraw = pathraw, 
    pathprocessed = 'Prosesserte_nylupe/'
  )
}
