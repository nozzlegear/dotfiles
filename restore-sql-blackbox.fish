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
set platform "linux/amd64"
set user_platform (uname -m)

set_color green
echo "Restoring SQL database as $containerName with image '$imageName'. Using '$volume' as the data volume."
echo ""
set_color normal

# Note that functions in fish return exit codes, not boolean true/false
if test "$user_platform" = "arm64"
    set_color yellow
    echo -n "[Warning]: "
    set_color normal
    echo -n "Image does not support your machine's arch type "
    set_color yellow
    echo -n "$user_platform"
    set_color normal
    echo -n ". Defaulting to platform "
    set_color yellow
    echo -n "$platform"
    set_color normal
    echo ". No user action is required. Rosetta 2 emulation layer will be used, which may incur a small performance impact on the container."
    echo ""
end

podman run \
    -dit \
    --name "$containerName" \
    --platform "$platform" \
    -v "$volume:/var/opt/mssql" \
    -e 'ACCEPT_EULA=Y' \
    -e "MSSQL_SA_PASSWORD=$password" \
    -p "$port:1433" \
    "$imageName"
