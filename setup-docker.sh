#!/bin/bash

if [ "$(whoami)" != "root" ]; then
    echo "You must run this script as root. Try \`sudo ./setup.sh\`."
    exit 1
fi

# https://stackoverflow.com/a/38859331
if grep -q Microsoft /proc/version; then
    echo "Ubuntu on Windows"
    WSL_running=true
    oldDockerHost=$DOCKER_HOST
    export DOCKER_HOST=tcp://localhost:2375
else
    echo "native Linux"
    WSL_running=false
fi

# Couch DB
docker run --name couchy --restart unless-stopped -d -p 5984:5984 couchdb

# SQL database
docker run --name sql --restart unless-stopped -e "ACCEPT_EULA=y" -e "SA_PASSWORD=a-BAD_passw0rd" -p 1433:1433 -d mcr.microsoft.com/mssql/server:2017-latest-ubuntu

if [[ $WSL_running == true ]]; then 
    # Reset the docker host variable
    export DOCKER_HOST=$oldDockerHost
fi
