rm(list=ls())

packages<-c("tidyverse", "graphics", "raster", "terra", "imager", "lidaRtRee", "magick");

lapply(packages, require,character.only=TRUE);

#For gammellupa settes fyllparameteren et sted mellom 11 og 21.
#For gammellupa ser det ut til at adjustment ca 1.35 er passelig for de fleste bilder.


#### Avkommenter følgende linjer for å standardisere bilder fra gammellupa
# fillparam<-15
# adj<-1.3 
# pathraw<-('/Users/a37357/Library/CloudStorage/OneDrive-Havforskningsinstituttet/Bildestandardisering/Råbilder_gammellupe')
# pathprocessed<-('/Users/a37357/Library/CloudStorage/OneDrive-Havforskningsinstituttet/Bildestandardisering/Prosesserte_gammellupe/')

#####

#For nylupa er det ikke nødvendig med fylling, sett fyllparameteren til 3. 
#For nylupa er 1.1 en passelig adjustment. 


#### Kommenter vekk følgende linjer for å standardisere bilder fra gammellupa
fillparam<-3
adj<-1.1 
pathraw<-('/Users/a37357/Library/CloudStorage/OneDrive-Havforskningsinstituttet/Bildestandardisering/Råbilder_nylupe')
pathprocessed<-('/Users/a37357/Library/CloudStorage/OneDrive-Havforskningsinstituttet/Bildestandardisering/Prosesserte_nylupe/')

#####


setwd('/Users/a37357/Library/CloudStorage/OneDrive-Havforskningsinstituttet/Bildestandardisering')

source('imstand_create_manual_lupetest.R')
for (imno in 2:5){
imstand_create_manual_lupetest(imno,adj, fillparam, pathraw,pathprocessed)
}