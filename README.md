<img src="assets/logo_margins.png" align="center" />

![Docker Image Version (latest semver)](https://img.shields.io/docker/v/als3bas/zulu-fabricmc?sort=semver)
![Docker Image Size (tag)](https://img.shields.io/docker/image-size/als3bas/zulu-fabricmc/latest)
![Docker Pulls](https://img.shields.io/docker/pulls/als3bas/zulu-fabricmc)
![](https://img.shields.io/github/license/als3bas/docker-fabric-zulu)

----

# Fabric MC Running on Zulu OpenJDK 
## What is this?
* This is a docker image that runs a [Fabric MC](https://fabricmc.net/) server on [Zulu OpenJDK](https://www.azul.com/downloads).
* Fabric is a lightweight, experimental modding toolchain for Minecraft.
* [Zulu OpenJDK](https://www.azul.com/downloads) _is a free, fully compliant, 100% open-source implementation of the Java SE Platform, Standard Edition._

**You're free to fork this repo and modify it to your needs.**

## Why Zulu instead of Temurin, Graalvm, Corretto, etc?
I just wanted to try it, and almost every openjdk implementation are the same.
The only problem is that Zulu depends on a single company (Azul), and if they want to change their license or policies, they can do it.

**Anyway, I will replicate this repo with Adoptium/Temurin**

# Requirements
* Docker [🔎 How to install](https://docs.docker.com/desktop/)
* Docker-compose 
* Preferably Linux, [WSL2](https://learn.microsoft.com/en-us/windows/wsl/install) or MacOS.
* Architecture: amd64 or arm64.
* 4+ GB of RAM (Depending on the players and mods)

# Creating a docker-compose.yml file
I prefer to use docker-compose, but you can use the docker cli if you want.

> **Warning**
> Don't forget to change PUID and PGID envs to run as non-root user.

```yml
version: "3.9"

services:
  minecraft:
    container_name: "fabricserver"
    # image: "als3bas/zulu-fabricmc:1.21.1"
    image: "als3bas/zulu-fabricmc:latest"
    # If you want to build the image locally, uncomment this 3 lines and comment the image line above.
    # build: 
    #   context: .
    #   dockerfile: Dockerfile
    restart: unless-stopped
    environment:
      - MEMORYSIZE: "1G"
      - PUID: "xxxx"
      - PGID: "xxxx"
    volumes:
      - ./:/data:rw
    ports:
      - "25565:25565"
    stdin_open: true
    tty: true
```

# Running as non-root user

Set the PUID and PGID environment variables to the user and group id of the user you want to run the server as.
To get those values, run the following command:

```sh
id $USER
uid=1000(alvaro) gid=984(users) groups=984(users),998(wheel),973(docker)
```

Then in the docker-compose.yml add the following environment variables:

```yaml
# docker-compose.yml
# In this example the user is alvaro 1000 and the group is users 984
environment:
  - PUID=1000
  - PGID=984
```

# Update the container

```sh
# This command will pull the latest image and restart the container
make update-container
```
or
```sh
# And this is basically the same
docker-compose stop
docker-compose pull
docker-compose up -d
``` 

# Adding mods

Adding mods is very easy, just copy them to the `mods` folder and restart the server.
```sh
make restart
```

# Running the server

### Run
Run the server with the following command:

```sh
docker-compose up -d --build
```

### Stop
Stop the server with the following command:

```sh
docker-compose stop
``` 

### Logs
To see the logs of the server, run the following command:

```sh
docker-compose logs -f 
```

## Using the makefile 
You can use the makefile on this repo
```sh
# run the server
make start

# stop the server
make stop

# down the server
make down

# build the server
# useful if you want to update the fabric version
# you won't lose your world, plugins or config files 😉
make build

# restart the server
# useful if you want to update the config or plugin files 
make restart

# attach to the server console
# you can use the server commands like /op /reload, etc
# Remember to use CTRL + P + Q to detach from the console without stopping the server
make attach

# show the last 20 lines of the log
make logs
```


# Common issues

* I can't upload/remove/edit files. [🔎 Click Here](#Running-as-non-root-user)
* Problems downloading .jar from mojang servers [🔎 Click Here](#Problems-downloading-jar-from-mojang-servers)

#  Problems downloading .jar from mojang servers

The `make logs` will show you something like this:

```sh
Downloading mojang_1.xx.xx.jar
mcserver-zulu  | Failed to download mojang_1.xx.xx.jar
mcserver-zulu  | java.net.UnknownHostException: xxxxxxxx.mojang.com
```

Probably you're using WSL2 and you have problems with the DNS server.
You have to modify/create the `/etc/docker/daemon.json` file and add your favorite dns server.

Example:
```sh
sudo nano /etc/docker/daemon.json
```
```json
{
  "dns": ["1.1.1.1", "8.8.8.8"]
}
```

# References
* This docker image is based on my repo [docker-papermc-graalvm](https://github.com/als3bas/docker-papermc-graalvm) which uses PaperMC & GraalVM as runtime.
* This repo and the previous one are based on the work of [mtoensing](https://github.com/mtoensing/Docker-Minecraft-PaperMC-Server)

