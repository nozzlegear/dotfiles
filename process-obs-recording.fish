#! /usr/bin/env fish

if ! set -q argv[1]
    set_color red
    echo "Missing video file."
    return 1
end

set video_file "$argv[1]"

if ! test -e "$video_file"
    set_color red
    echo "$video_file does not exist or is not a regular file."
    return 1
end

echo "Using $video_file"

set video_filename (path basename "$video_file")
set video_dirname (path dirname "$video_file")
set output_video_file "$video_dirname/merged_$video_filename"

ffmpeg -i "$video_file" \
    -filter_complex "[0:a:1]pan=stereo|c0=c1|c1=c1[dup];[0:a:0][dup]amix=inputs=2:duration=first:dropout_transition=3[aout]" \
    -map 0:v \
    -map "[aout]" \
    -c:v copy \
    -c:a aac \
    -ac 2 \
    "$output_video_file"

echo "Output to $output_video_file"

