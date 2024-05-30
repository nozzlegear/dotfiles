#! /usr/bin/env fish

set scriptName (status -f)
set password $argv[1]

echo ""

function printHelpAndExit -a err
    set_color yellow;
    echo "$err"
    echo "Usage: $scriptName [database password]"
    set_color normal;
    exit 1
end

if test -n "$password"
    set password $password
else if test -n "$GENERIC_SQL_PASSWORD"
    set password $GENERIC_SQL_PASSWORD
else
    printHelpAndExit "Missing database password. Pass via CLI or \$GENERIC_SQL_PASSWORD environment variable (set -x GENERIC_SQL_PASSWORD [value])."
end

set port 1433
set containerName "blackbox"
set volume "blackbox"
set imageName "mcr.microsoft.com/mssql/server:2022-latest"

set_color green
echo "Restoring SQL database as $containerName with image '$imageName'. Using '$volume' as the data volume."
echo ""
set_color normal

podman run \
    -dit \
    --name "$containerName" \
    -v "$volume:/var/opt/mssql" \
    -e 'ACCEPT_EULA=Y' \
    -e "MSSQL_SA_PASSWORD=$password" \
    -p "$port:1433" \
    "$imageName"
