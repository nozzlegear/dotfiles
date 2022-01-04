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
set containerName "generic_sql"
set imageName "mcr.microsoft.com/mssql/server:2019-latest"
set volumeLocation "$HOME/docker/custom-volumes/generic_sql"
# The data volume either needs to be owned by root, or we need to run Docker as whichever user owns the volume dir.
# We'll assume the current user owns it and run the container as that user.
set userId (id -u (whoami))
set userGroupId (id -g (whoami))

set_color green
echo "Restoring generic SQL database as $containerName with image '$imageName'. Using '$volumeLocation' as the data volume location, and user" (whoami) "as the owner of the data volume."
echo ""
set_color normal

sudo docker run --restart "unless-stopped" --name "$containerName" --volume "$volumeLocation:/var/opt/mssql" -d -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=$password" -p "$port:$port" -u "$userId:$groupId" "$imageName"
