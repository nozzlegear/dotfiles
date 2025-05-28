function fish_greeting
    # Check if running on WSL, Linux or Mac
    # https://stackoverflow.com/a/38859331
    function isWindows
        if test -f /proc/version
            switch (cat /proc/version)
                case "*Microsoft*" "*microsoft-standard-WSL*"
                    return 0
            end
        end
        return 1
    end

    function isMac
        if test (uname -s) = "Darwin"
            return 0
        end
        return 1
    end

    function welcome -a os
        if shouldEcho
            echo ""
            set_color yellow
            echo "🐟 Fish on $os" 
        end
    end

    if isWindows
        welcome "WSL"
        set WSL_running true 
    else if isMac
        welcome "macOS"
        set WSL_running false 
    else
        welcome "Linux"
        set WSL_running false 
    end
end
