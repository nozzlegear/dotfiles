#! /usr/bin/env fish 

set scriptName (status -f)
set amount $argv[1]

echo ""

function printHelpAndExit -a err
    set_color yellow;
    echo "$err"
    echo "Usage: $scriptName [desired amount]"
    set_color normal;
    exit 1
end

if not string match -qr '^[0-9]+$' $amount 
    printHelpAndExit "Missing valid amount (must be a number, but got '$amount')"
end

# Expulsom rates are "officially" around .15, but I like to reduce to .13 to account for RNG 
set rate .13
set totalBracers (math round "($amount / $rate)")
set totalLinen (math "$totalBracers * 10")

set_color green
echo "Expulsom: $amount"
echo "Scrap Bracers (average): $totalBracers"
echo "Tidespray Linen needed: $totalLinen"
set_color normal
