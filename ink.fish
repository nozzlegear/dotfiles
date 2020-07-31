#! /usr/bin/env fish 

set scriptName (status -f)
set ink $argv[1]
set amount $argv[2]

echo ""

function printHelpAndExit -a err
    set_color yellow;
    echo "$err"
    echo "Usage: $scriptName [desired ink] [desired amount]"
    set_color normal;
    exit 1
end

if test -z "$ink"
    printHelpAndExit "Missing desired ink."
end

if not string match -qr '^[0-9]+$' $amount 
    printHelpAndExit "Missing valid amount (must be a number, but got '$amount')"
end

# Ink rates source:
# https://docs.google.com/spreadsheets/d/1gzqUMZfFoMK9v--fCQOSWcHWs-YU0QQ6oKzDYivOZ1Y/edit#gid=1480745486

set pigmentRate;
set herbs;

switch (string lower $ink)
    case crimson
        # Rate for crimson ink is .3152
        set pigmentRate "0.3152"
        set herbs "Riverbud, Akunda's Bite, Sea Stalk, Siren's Pollen, Star Moss or Winter's Kiss"
    case maroon marroon
        # Rate for maroon ink is .6012
        set pigmentRate "0.6012"
        set herbs "Zin'anthid"
    case sallow 
        # Sallow pigment has multiple rates depending on the herb. 
        # For now, just use dreamleaf which is the highest.
        set pigmentRate "0.0992"
        set herbs "Dreamleaf (other herbs currently unimplemented)"
    case roseate
        # Roseate pigment has multiple rates depending on the herb
        # For now, just use dreamleaf which is one of the highest.
        set pigmentRate "0.4771"
        set herbs "Dreamleaf (other herbs currently unimplemented)"
    case '*'
        printHelpAndExit "Unhandled ink type (received '$ink')"
        exit 1
end

set totalHerbs (math round "($amount / $pigmentRate)")

set_color green
echo "Ink: $ink ink"
echo "Herbs: $herbs"
echo "Mill (average): $totalHerbs"
set_color normal
