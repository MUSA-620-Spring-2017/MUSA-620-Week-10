library(leaflet)
library(rgdal)
library(htmlwidgets)
library(ggmap)




# *** GEOCODING ***

ourCoords <- geocode("425 S University Ave, philadelphia, pa")





# *** BASIC LEAFLET EXAMPLE ***

mymap <- leaflet() %>%
  addTiles() %>%
  addMarkers(ourCoords$lon, ourCoods$lat, popup="<strong>**MUSA 620**</strong>") %>%
  setView(ourCoords$lon, ourCoods$lat, zoom = 17)

mymap





# *** MAP TILES ***
# Many options: https://leaflet-extras.github.io/leaflet-providers/preview/
# Design your own: https://www.mapbox.com/help/define-mapbox-studio-classic/.

# Default map tiles
leaflet() %>%
  addTiles() %>%

# Neutral, light -- good for data visualization
leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron)

# Neutral, dark -- good for data visualization
leaflet() %>%
  addProviderTiles(providers$CartoDB.DarkMatter)

# Satellite imagery
leaflet() %>%
  addProviderTiles(providers$Esri.WorldImagery)

# Earth at night
leaflet() %>%
  addProviderTiles(providers$NASAGIBS.ViirsEarthAtNight2012)

# Map tiles can also be layered
leaflet() %>% addProviderTiles(providers$MtbMap) %>%
  addProviderTiles(providers$Stamen.TonerLines, options = providerTileOptions(opacity = 0.35)) %>%
  addProviderTiles(providers$Stamen.TonerLabels)





# *** POINT OVERLAYS ***

accidentpoints <- read.csv("d:/philly-accident-points.csv")

personBins <- c(0, 1, 2, 5, 10, 20, Inf)
paletteBins <- colorBin(palette = "OrRd", accidentpoints$persons, bins=-personBins)

paletteFactor <- colorFactor(c("blue","red","green"), accidentpoints$drunk_dr)

paletteContinuous <- colorNumeric(palette = "magma", domain = accidentpoints$latitude + accidentpoints$longitud)

leaflet() %>%
  addProviderTiles(providers$CartoDB.DarkMatterNoLabels) %>%
  #addProviderTiles(providers$CartoDB.PositronNoLabels) %>%
  addCircleMarkers(data=accidentpoints,
                   lng = ~longitud,
                   lat = ~latitude,
                   radius = ~sqrt(persons) + 0.5,
                   fillOpacity = 1,
                   fillColor = ~paletteBins(-persons),
                   #fillColor = ~paletteFactor(drunk_dr),
                   #fillColor = ~paletteContinuous(latitude + longitud),
                   #color = "white",
                   #weight = 2,
                   #opacity = 1,
                   stroke=FALSE,
                   #popup= ~paste0("Date: ",month,"/",day),
                   label = ~tway_id)





# *** POLYGON OVERLAYS ***

phillycrime2016 <- readOGR("d:/philly-crime-2016.geojson", "OGRGeoJSON")

phillycrime2016$crimebucket <- factor(
  cut(as.numeric(crimePlot2016$y2016), c(-1, 300, 700, 1200, 1801, 99999999)),
  labels = c("Less than 300", "300 to 699", "700 to 1199", "1200 to 1800", "More than 1800")
)

crimeBucketPal <- colorFactor(c("#3b2a3d", "#755a4a", "#8b844a",  "#e3c700", "#e2e900"), phillycrime2016$crimebucket)

crime2016 <- leaflet(phillycrime2016) %>% addProviderTiles(providers$CartoDB.Positron) %>%
  addPolygons( data = phillycrime2016,
               fillColor = ~crimeBucketPal(crimebucket),
               weight = 0.8,
               opacity = 0.9,
               smoothFactor = 0.1,
               color = ~crimeBucketPal(crimebucket),
               fillOpacity = 0.9,
               label = ~paste0("Crimes: ", y2016),
               highlight = highlightOptions(
                 fillColor = "orange",
                 fillOpacity = 1,
                 bringToFront = FALSE)) %>%
  addLegend(pal = crimeBucketPal, 
            values = ~crimebucket, 
            position = "bottomright", 
            title = "Crimes in 2016",
            opacity = 1)

crime2016




# *** EXPORT TO THE WEB ***

saveWidget(crime2016, file="philly-crime.html", selfcontained=TRUE)

