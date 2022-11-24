library(DBI)
library(RPostgres)
library(sf)
library(shiny)
library(RColorBrewer)

dvr <- RPostgres::Postgres()
db <- 'test'  ##Nombre de la BBDD
host_db <- 'postgis'
db_port <- '5432' 
db_user <- 'citadmin'  ##Tu usuario
db_password <- 'test123' ##Tu contraseña 

con <- DBI::dbConnect(dvr, dbname = db, host=host_db, port=db_port,
                      user=db_user, password=db_password) 
dbListTables(con)

Pobreza <- st_read(con, layer = "pobreza_por_ingresos")
print(Pobreza)

#Color
pal <- brewer.pal(7, "OrRd") # we select 7 colors from the palette
class(pal)

ui <- basicPage(
  plotOutput("plot1", click = "plot_click"),
  verbatimTextOutput("info")
)

server <- function(input, output) {
  output$plot1 <- renderPlot({plot(Pobreza['porc_pobre'],main = "Pobreza por ingresos por comuna en la región de Antofagasta", 
          breaks = "quantile",nbreaks = 7,pal = pal)
  })
  
  output$info <- renderText({
    paste0("x=", "Porcentaje de pobreza por comuna")
  })
}

shinyApp(ui, server)