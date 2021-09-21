#! /usr/bin/env fish

set fileName "wow-backup-"(date --iso-8601=minutes)".tar.gz"

# Try to figure out where the WoW retail folder is
set locations \
    "/mnt/c/Program Files (x86)/World of Warcraft/_retail_" \
    "$HOME/Games/World of Warcraft/_retail_" \
    "$HOME/Games/battlenet/drive_c/Program Files (x86)/World of Warcraft/_retail_"

for location in $locations
    if test -d $location
        set wowDirectory $location
    end
end

if test ! $wowDirectory
    set_color red
    echo "Could not find World of Warcraft retail directory. The following locations were checked:"
    set_color yellow
    for location in $locations; echo "$location"; end;
    set_color normal
    exit 1
end

set_color green
echo "Backing up World of Warcraft retail directory at $wowDirectory"
set_color normal

sudo tar -zcpv \
	--exclude "Cache/ADB" \
    --directory "$wowDirectory" \
    -f "/tmp/$fileName" \
    "Interface" \
    "Screenshots" \
    "WTF" \
    "Cache"

set_color green
echo ""
echo "WoW retail directory backed up to /tmp/$fileName"
set_color normal
