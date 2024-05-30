#! /usr/bin/env fish

set scriptName (status -f)
set password $argv[1]

echo ""

function printHelpAndExit -a err
    set_color yellow;
    echo "$err"
    echo "Usage: $scriptName [couchy password]"
    set_color normal;
    exit 1
end

if test -n "$password"
    set password $password
else if test -n "$COUCHY_PASSWORD"
    set password $COUCHY_PASSWORD
else
    printHelpAndExit "Missing couchy admin password. Pass via CLI or \$COUCHY_PASSWORD environment variable (set -x COUCHY_PASSWORD [value])."
end

set port 5984
set username "nozzlegear"
set containerName "couchy"
set volumeLocation "$HOME/.local/volumes/couchy/data"
set image "couchdb:3"

echo "Restoring Couchy database with apache/couchdb:3 on port $port. Using '$username' as admin username, and '$volumeLocation' as the data volume location."
echo ""

podman run \
    -dit \
    --restart "unless-stopped" \
    --name "$containerName" \
    --volume "$volumeLocation:/opt/couchdb/data" \
    -e "COUCHDB_USER=$username" \
    -e "COUCHDB_PASSWORD=$password" \
    -p "$port:5984" \
    "$image"
