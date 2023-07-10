function vlc-stream -d "Opens a video url and streams it using VLC" -a url
    if ! command -q "trurl"
        set_color red
        echo "trurl is not installed, unable to manipulate urls. Please install trurl with your package manager to proceed."
        return 1
    end

    if ! trurl --url "$url" --verify 2&>1
        return $status
    end

    set host (trurl --url "$url" --get '{host}')

    if string match -r ".*nitter.*" "$host"
        set url (trurl --url "$url" --set 'host=twitter.com')
        echo "Rewrote nitter url to $url"
    end

    # Use the yt-dlp's -g command to get the streaming url from the video, then pass that to vlc
    # TODO: figure out how to background the vlc process
    vlc (yt -g "$url")&

    disown %1
end
