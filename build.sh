#!/bin/bash

APP="service-archive"
APP_NAME="archive"
IMAGE="oydeu/§APP"

# read commandline options
REFRESH=false
DOCKER_UPDATE=false
VAULT_UPDATE=false
while [ $# -gt 0 ]; do
    case "$1" in
        --dockerhub*)
            DOCKER_UPDATE=true
            ;;
        --name=*)
            APP_NAME="${1#*=}"
            ;;
        --refresh*)
            REFRESH=true
            ;;
        --vault*)
            VAULT_UPDATE=true
            ;;
        --help*)
            echo "Verwendung: [source] ./build.sh  --options"
            echo "erzeugt und startet OwnYourData Komponenten"
            echo " "
            echo "Optionale Argumente:"
            echo "  --dockerhub       pusht Docker-Image auf hub.docker.com"
            echo "  --help            zeigt diese Hilfe an"
            echo "  --name=TEXT       Name für Docker Container und bei --vault für Subdomain"
            echo "  --refresh         aktualisiert docker Verzeichnis von Github"
            echo "  --vault           startet Docker Container auf datentresor.org"
            echo " "
            echo "Beispiele:"
            echo " ./build.sh --dockerhub --vault"
            if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
                return 1
            else
                exit 1
            fi
            ;;
        *)
            printf "unbekannte Option(en)\n"
            if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
                return 1
            else
                exit 1
            fi
    esac
    shift
done

if $REFRESH; then
    if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
        cd ~/docker
        rm -rf $APP
        git clone https://github.com/OwnYourData/service-archive.git
        echo "refreshed"
        cd ~/docker/$APP
        return
    else
        echo "you need to source the script for refresh"
        exit
    fi
fi

docker build -t $IMAGE .

if $DOCKER_UPDATE; then
    docker push $IMAGE
fi

if $VAULT_UPDATE; then
    # restart demo
    docker stop $APP_NAME
    docker rm $(docker ps -q -f status=exited)
    docker rm $(docker ps -q -f status=created)
    CONTAINER_ID=$(docker run -d --name $APP_NAME --expose 80 -e VIRTUAL_HOST=$APP_NAME.datentresor.org -e VIRTUAL_PORT=80 $IMAGE)
fi
