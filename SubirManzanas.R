#Librerias
library(DBI)
library(RPostgres)
library(sf)

#Leer shape file
data <- sf::st_read("/Manzanas_folder/MANZANAS_INFO.SHP")
data

#Datos PostgreSQL
dvr <- RPostgres::Postgres()
db <- "prueba"  
host_db <- "postgis"
db_port <- "5432"
db_user <- "admin_ejemplo"  
db_password <- "ejemplo_contraseña"

#Código de conexión
con <- DBI::dbConnect(dvr, dbname = db, host = host_db, port = db_port,
                    user = db_user, password = db_password)
#Se escriben los datos
sf::st_write(data, con, layer ="Manzanas_R01")
