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

### Source or list custom functions used within the script ####

#########################
# Process the images ####

## Old microscope
# For gammellupa settes fyllparameteren et sted mellom 11 og 21.
# For gammellupa ser det ut til at adjustment ca 1.35 er passelig for de fleste bilder.

# Change the path below to match where the photos are located
pathraw <- normalizePath('/Users/a22357/Library/CloudStorage/OneDrive-SharedLibraries-Havforskningsinstituttet/Nilsen, Tine - GHL_imagestandardization/Råbilder_gammellupe')

AgeEstimatoR::standardize_images(
  input_path = pathraw,
  output_path = 'Prosesserte_gammellupe',
  adj = 1.35, fillparam = 15
)

## New microscope
# For nylupa er det ikke nødvendig med fylling, sett fyllparameteren til 3. 
# For nylupa er 1.1 en passelig adjustment. 

# Change the path below to match where the photos are located
pathraw <- normalizePath('/Users/a22357/Library/CloudStorage/OneDrive-SharedLibraries-Havforskningsinstituttet/Nilsen, Tine - GHL_imagestandardization/Råbilder_nylupe')

AgeEstimatoR::standardize_images(
  input_path = pathraw,
  output_path = 'Prosesserte_nylupe',
  adj = 1.1, fillparam = 3
)
