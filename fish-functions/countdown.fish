function countdown
    set date1 (math (date +%s) + $argv[1])

    while test $date1 -ge (date +%s)
        echo -ne (date -u -r (math $date1 - (date +%s)) +%H:%M:%S)"\r"
        sleep 0.1
    end
end
