#! /usr/bin/env fish

# This script will back up a running CouchDB container by copying the files at /opt/couchdb/data and running tarsnap on them.
# The backup can be restored by creating a new container and pointing a volume at the backed up data folder:
# `podman run --volume "path/to/tarsnap-backup/data:/opt/couchdb/data" apache/couchdb`
# 
# Note: this script only needs to be used when the container does not already have a volume. If it does have a volume, you can just back up the volume location with tarsnap and skip the container file copying entirely.

set USE_PODMAN
set USE_SUDO_FOR_DOCKER

function log
    set TIMESTAMP (date '+%Y-%m-%d %H:%M:%S')
    echo "[$TIMESTAMP] $argv"
end

function print_help
    set_color yellow
    echo "Usage:"
    echo "  ./script.fish container_name [export_directory]"
    set_color normal
end

function error
    set_color red
    echo "$argv"
    set_color normal
end

function pod 
    # Run either podman, docker or sudo docker
    if test $USE_PODMAN -eq 1
        podman $argv
    else if $USE_SUDO_FOR_DOCKER -eq 1
        sudo docker $argv
    else
        docker $argv
    end
end

# Figure out whether to use podman, docker or sudo docker to start containers
if command -q podman
    set USE_PODMAN 1
else if command -q docker
    # Check if the user can use Docker without sudo
    if docker ps &> /dev/null
        set USE_SUDO_FOR_DOCKER 0
    else
        set USE_SUDO_FOR_DOCKER 1
    end
else
    error "`podman` and `docker` commands not found. Are they installed?"
    exit 1
end

if test -z "$argv[1]"
    error "No container name given."
    print_help
    exit 1
else 
    switch $argv[1]
        case "help" "--help" "-h"
            print_help
            exit 0
    end
end

set CONTAINER_NAME "$argv[1]"
set ARCHIVE_NAME "$CONTAINER_NAME"(date "+%Y-%m-%d_%H-%M-%S")

log "Backing up container $CONTAINER_NAME."

# Figure out which directory to export the container files into
if test -z "$argv[2]"
    set EXPORT_DIR (mktemp -d -t "backup-$CONTAINER_NAME")
    log "No export directory given, using temp directory at $EXPORT_DIR"
else
    set EXPORT_DIR "$argv[2]"
    log "Using export directory at $EXPORT_DIR"

    if test ! -d "$EXPORT_DIR"
        mkdir -p "$EXPORT_DIR"
        or exit 1
    end
end

# Copy the files out of the container into the backups folder
pod cp "$CONTAINER_NAME:/opt/couchdb/data" "$EXPORT_DIR"
or exit 1

log "Running tarsnap on $EXPORT_DIR"

# Run tarsnap on the export directory
tarsnap -c -f "$ARCHIVE_NAME" "$EXPORT_DIR"
or exit 1

log "Created tarsnap archive $ARCHIVE_NAME."
log "Done!"
