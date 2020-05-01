# R 3.6.1
library(tidyverse)
library(sf)
library(mapview)
library(leaflet)
library(inlmisc)

roadFile <- st_read( 'GIS/VA_WV_Forest_Roads.shp') %>%
  st_transform(4326) %>% # to wgs84
  dplyr::select(FIELD_ID, NAME, GIS_MILES, JURISDICTI, OPERATIONA, SURFACETYP,
                SEASONAL, FORESTNAME) %>%
  rename('Route' = 'FIELD_ID', 'Road Name' = 'NAME', 'Mileage' = 'GIS_MILES',
         'Jurisdiction' = 'JURISDICTI', 'Use' = 'OPERATIONA', 
         'Surface Type' = 'SURFACETYP', 'Seasonal Road' = 'SEASONAL', 'Forest' = 'FORESTNAME')


# color palette for road types
pal <- colorFactor(
  palette = colorRamps::primary.colors(5),
  domain = roadFile$Use)


leaflet(roadFile) %>%
  addProviderTiles(providers$OpenStreetMap, group='Open Street Map') %>%
  addProviderTiles(providers$HikeBike, group='HikeBike') %>%
  addProviderTiles(providers$Stamen.Terrain, group='Topo') %>%
  addProviderTiles(providers$Esri.WorldImagery,group='Imagery') %>%
  setView(-78, 37.5, zoom=6) %>%
  addPolylines(weight = 3, layerId = ~`Road Name`,
               label = ~`Road Name`,
               color = ~pal(Use), 
               group="FS Roads",
               popup=leafpop::popupTable(roadFile)) %>%
  addLayersControl(baseGroups=c("Open Street Map","Topo",'Imagery',"HikeBike"),
                   overlayGroups = c('FS Roads'),
                   options=layersControlOptions(collapsed=T),
                   position='topleft') %>%
  addLegend(pal = pal, values = ~Use, position = "topright") %>%
  inlmisc::AddSearchButton(group = "FS Roads", zoom = 15, #propertyName = "label",
                           textPlaceholder = "Search Road Names") 


# inlmisc version, search button not picking up data for some reason

CreateWebMap(maps = c("Topo","Imagery"), collapsed = TRUE) %>%
  addPolylines(data = roadFile, weight = 3, layerId = ~`Road Name`,
               label = ~`Road Name`,
               color = ~pal(Use), 
               group="FS Roads",
               popup=leafpop::popupTable(roadFile)) %>%
  addLayersControl(baseGroups=c("Topo",'Imagery'),
                   overlayGroups = c('FS Roads'),
                   options=layersControlOptions(collapsed=T),
                   position='topleft') %>%
  addLegend(data = roadFile, pal = pal, values = ~Use, position = "topright") %>%
  inlmisc::AddHomeButton(raster::extent(-80.60, -80.20, 37.20, 37.30), position = "topleft")# %>%
  #inlmisc::AddSearchButton(group = "FS Roads", zoom = 15, #propertyName = "label",
  #                         textPlaceholder = "Search Road Names") 
