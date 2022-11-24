#Librerias a utilizar
library(DBI)
library(RPostgres)
library(sf)
library(shiny)
library(RColorBrewer)
library(leaflet)

#Datos PostgreSQL
dvr <- RPostgres::Postgres()
db <- "prueba"  
host_db <- "postgis"
db_port <- "5432" 
db_user <- "admin_ejemplo" 
db_password <- "password_ejemplo" 

#Código de conexión
con <- DBI::dbConnect(dvr, dbname = db, host = host_db, port = db_port,
                    user = db_user, password = db_password)

#Se leen los datos desde PostGIS
Manzanas <- st_read(con, layer = "Manzanas_R01")
#Se revisa si los datos se guardaron correctamente
print(Manzanas)

#Se crea la página shiny
ui <- navbarPage("PACER+ Map", id = "nav", tabPanel("Map"
                , div(class = "outer", tags$style(type = "text/css"
                , "#map {height: calc(100vh - 80px) !important;}")
                , leafletOutput("map", height = "100%", width = "100%"))))
Comunas <- subset(Manzanas, Manzanas$NOM_COM %in% c("PICA","CAMINA","ALTO HOSPICIO","IQUIQUE","POZO ALMONTE","COLCHANE","HUARA")) 
server <- function(input, output, session) {
    output$map <- renderLeaflet({
        leaflet(Comunas) %>% 
            addPolygons(color = "#2a08d9", weight = 1, smoothFactor = 0.5, 
                        opacity = 1.0, fillOpacity = 0.5,
                        fillColor = ~colorQuantile("YlOrRd", PERSONAS)(PERSONAS),
                        highlightOptions = highlightOptions(color = "white", weight = 2, 
                        bringToFront = TRUE))
                                })}
#Se muestra la aplicación
shinyApp(ui, server)
