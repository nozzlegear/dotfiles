#! /usr/bin/env fish

set scriptName (status -f)
set password $argv[1]

echo ""

function printHelpAndExit -a err
    set_color yellow;
    echo "$err"
    echo "Usage: ./$scriptName [database password]"
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

set port 5432
set containerName "watchmaker"
set volume "watchmaker"
set username "watchmaker_sa"
# Postgres 17 alpine
set imageName "docker.io/library/postgres@sha256:d1747e7e92732afd6a451cf90b47986d1c19bfb217c30388fbd2486aacf1113c"
set user_platform (uname -m)

set_color green
echo "Restoring pgsql database as $containerName with image '$imageName'."
echo "Using '$volume' as the data volume."
echo "SA username is $username."
echo ""
set_color normal

podman run \
    -dit \
    --name "$containerName" \
    --restart unless-stopped \
    -v "$volume:/var/lib/postgresql/data" \
    -e "POSTGRES_PASSWORD=$password" \
    -e "POSTGRES_USER=$username" \
    -p "$port:5432" \
    "$imageName"
