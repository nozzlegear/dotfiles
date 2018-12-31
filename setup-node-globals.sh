#! /bin/bash

if [ "$(whoami)" != "root" ]; then
    echo "You must run this script as root. Try \`sudo ./setup-node-globals.sh\`."
    exit 1
fi

# This script installs global Node packages that I use
yarn global add ts-node bogpaddle parcel typescript webpack-cli 

