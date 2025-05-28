function excel-to-csv -d "Converts an Excel (.xlsx) file to CSV (.csv)" -a input output
    # Make sure the xlsx2csv utility is installed
    # Note: this may need to be changed for macOS
    if ! command -q "xlsx2csv"
        set_color red
        echo "xlsx2csv is not installed, unable to convert file. Please install xlsx2csv with your package manager to proceed."
        return 1
    end

    if test -z "$input"
        set_color red
        echo "No file given as input."
        return 1
    end

    if test -z "$output"
        # If an output directory was not set, use one based on the input filename
        set rootname (stripext "$input" | string lower)
        set output "$rootname"
    end

    xlsx2csv -a "$input" "$output"
    or return 1

    set_color green
    echo -n "Converted "
    set_color yellow
    echo -n "$input"
    set_color green
    echo -n " to "
    set_color yellow
    echo -n "$output"
    set_color green
    echo "."
end
