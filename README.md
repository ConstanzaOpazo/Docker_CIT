# Instalación contenedores en EC2

Se genera una instancia de EC2 en AWS, esto descargará automáticamente un archivo nombre_de_la_clave.pem con las credenciales para acceder de manera remota a la máquina. En nuestro ejemplo tenemos la siguiente información:
* Archivo pem: aws-ec2-cit.pem 
* Usuario de la máquina:  ubuntu
* DNS de IPv4 público: ec2-54-232-41-235.sa-east-1.compute.amazonaws.com

En el terminal, no dirigimos a la dirección de nuestro archivo .pem y colocamos.

```bash
ssh -i .\aws-ec2-cit.pem ubuntu@ec2-54-232-41-235.sa-east-1.compute.amazonaws.com
```

Esto nos hará ingresar a EC2 desde nuestro terminal

Para descargar los archivos Dockerfile, docker-compose.yml y otros archivos a nuestro EC2 de manera más rápida se hizo a traves de git.

Primero, se debe instalar los comandos git y Docker en el terminal de EC2

## Instalación git
```bash
sudo apt update
sudo apt install git
#Verificamos instalación
git --version
```
## Instalación Docker

### Configurar el repositorio
Actualice apt e instale paquetes para permitir que apt utilice un repositorio a través de HTTPS
```bash
sudo apt-get update
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
```
Añada la clave GPG oficial de Docker:
```bash
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```
Utilice el siguiente comando para configurar el repositorio:
```bash
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```
### Instalar docker engine
```bash
sudo apt update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
#Verificar instalación
sudo docker run hello-world
```
Puede verificar los pasos anteriores en el siguiente [link](https://docs.docker.com/engine/install/ubuntu/) 

Segundo, nos dirigimos a la carpeta en donde quedarán guardados los documentos, en mi caso en home/Documentos y ponemos.

```bash
git clone https://github.com/CIT-UAI/Docker_IDE.git
```

Una vez guardados los archivos en el sistema tendremos la carpeta Docker-IDE con todos los archivos para crear los contenedores Docker presentes en el archvio docker-compose.yml

Antes de correr los contenedores, para que la máquina pueda instalar todas las librerias presentes en el Dockerfile va a ser necesario regular la utilización de RAM, para eso se debe utilizar swap. Los pasos son:
### Crear un nuevo espacio swap 
El nuevo espacio swap cuenta  con un tamaño de 1 GB (1*1024 = 1024). Debido a que la maquina creada tenía un 1GB de RAM, aquí se puede modificar según sea el caso, Básicamente bs * count = bytes a asignar (en este caso 1 GB) bs es el tamaño de bloque. Aquí bs = 1M (M significa mega, por lo que estamos asignando un tamaño de bloque de 1MB) y estamos asignando 1024 * 1MB (=1GB) a swap.
```bash
 sudo dd if=/dev/zero of=/swapfile bs=1M count=1024
```
### Dar permiso de lectura/escritura
```bash
 sudo chmod 600 /swapfile
```
### Formatear para hacer swap
```bash
 sudo mkswap /swapfile
```
### Volver a prender swap
```bash
 sudo swapon /swapfile
```
### Verificar instalación
```bash
swapon --show
#Donde debería aparecer algo como:
NAME      TYPE  SIZE   USED PRIO
/swapfile file 1024M 306.7M   -2
```
Los pasos anteriores se sacaron del siguiente [link](https://askubuntu.com/questions/1264568/increase-swap-in-20-04)

## Correr los contenedores
Después de todos los pasos anteriores podemos correr el docker, simplemente dirijase a la carpeta Docker-IDE y ahi escriba el comando
```bash
sudo docker-compose up -d
```

Si todo sale bien, debería aparecer
```bash
Starting R_shiny ... done
Starting postgis ... done
Starting pgadmin ... done
```

Además se pueden ver los contenedores activos con el comando
```bash
docker ps
```
```bash
#Aparece
CONTAINER ID   IMAGE                    COMMAND                  CREATED        STATUS         PORTS                                            NAMES
bef35c6c7968   dockeride_shiny          "/usr/bin/shiny-serv…"   27 hours ago   Up 9 seconds   0.0.0.0:8081->3838/tcp, :::8081->3838/tcp        R_shiny
6fd78cc90399   dpage/pgadmin4:6.15      "/entrypoint.sh"         2 days ago     Up 8 seconds   443/tcp, 0.0.0.0:8080->80/tcp, :::8080->80/tcp   pgadmin
11759fd0949e   postgis/postgis:latest   "docker-entrypoint.s…"   2 days ago     Up 9 seconds   0.0.0.0:5433->5432/tcp, :::5433->5432/tcp        postgis
```

Para poder acceder a los contenedores simplemente ejecute el comando
```bash
docker exec -ti CONTAINER_ID /bin/bash
```
## Contenedor shiny-server

Para poder utilizar el shiny-server instalado en el contenedor se deben seguir los siguientes pasos:

1) Añada en el grupo de seguridad correspondiente una nueva regla de entrada, para el caso especifico de shiny-server añada en TCP personalizado para el puerto 8081 desde cualquier origen (0.0.0.0/0) y guarde las reglas. Para los contenedores de PostGIS y PGadmin se realiza lo mismo, solo que para los puertos 5433 y 8080 respectivamente.

2) Dentro del contenor de shiny-server ingrese a la ruta 
    ```bash
    cd /srv/shiny-server
    ```
3) Añada una carpeta NOMBRE, ingrese a esta y cree el archivo app.R (debe llamarse app.R)
    ```bash
    sudo mkdir NOMBRE_CARPETA
    cd NOMBRE
    sudo nano app.R
    ```
4) En el archivo app.R ingrese el código de su página shiny.

5) En el buscador de su preferencia agregue 54.232.41.235:8081/NOMBRE_CARPETA
