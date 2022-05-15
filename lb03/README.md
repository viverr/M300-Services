# Einleitung

# Code Erklärung
In diesem README wird die Funktion der LB03-Container-Integration erklärt.

## Inhaltsverzeichis
- [Einleitung](#einleitung)
- [Code Erklärung](#code-erklärung)
  - [Inhaltsverzeichis](#inhaltsverzeichis)
  - [Repository Struktur](#repository-struktur)
- [Funktion der einzelnen Files](#funktion-der-einzelnen-files)
## Repository Struktur
Die Struktur des M300-Services/lb03 Repositories sieht folgendermassen aus:
```
M300-Services/ 
  ├─ assets
     ├─ startup.sh
  ├─ lb03/
     ├─ README.md
     ├─ run.sh
     ├─ Dockerfile
     ├─ docker-compose.yml
     ├─ build.sh
     ├─ build-multiarch.sh
     ├─ vars
```
**Die wichtigsten Dateien hier sind:**
- Dockerfile
- build.sh
- docker-compose.yml
- build-multiarch.sh
- vars
- run.sh

# Funktion der einzelnen Files

**---- Dockerfile ----** 
Die Dockerfile besitzt alle Informationen zum Aufbau des Containers. Sie ist sozusagen der Bauplan der gesamten Container Grundstruktur und wird für jede Erstellung eines Containers gebraucht.

*Der Aufbau:*
```
FROM alpine:latest

ARG BUILD_DATE

# Container Informationen
LABEL build_info="cturra/docker-ntp build-date:- ${BUILD_DATE}"
LABEL maintainer="Chris Turra <cturra@gmail.com>"
LABEL documentation="https://github.com/cturra/docker-ntp"

# Chrony Installation
RUN apk add --no-cache chrony

# Konfigurations Skript einbinden
COPY assets/startup.sh /opt/startup.sh

# NTP Port
EXPOSE 123/udp

# Docker Gesunheitscheck durchführen
HEALTHCHECK CMD chronyc tracking || exit 1

# Chrony starten
ENTRYPOINT [ "/bin/sh", "/opt/startup.sh" ]
```
- FROM 
  -  Gibt das Basis-Bild an. Die Alpine-Version ist das minimale Docker-Image, das auf Alpine Linux basiert und nur 5 MB groß ist.
- RUN
  - Führt einen Linux-Befehl aus. Wird verwendet, um Pakete im Container zu installieren, Ordner zu erstellen usw.
- LABEL
  - Stellt Metadaten bereit.
- COPY
  - Kopiert Dateien und Verzeichnisse in den Container.
- EXPOSE
  - Ports freigeben.
- ENTRYPOINT
  - Stellt Befehle und Argumente für einen ausführenden Container bereit.
- HEALTHCHECK
  - Hier geht es darum, den Zustand von Docker-Containern zu überprüfen. 