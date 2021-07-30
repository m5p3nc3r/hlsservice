#!/bin/sh

test=0
device="/dev/video0"
playlisy_root=""
location=""
filter=""

# -f "video/x-raw, format=NV12,width=1920,height=1080"

show_help() {
    echo << EOF "
construct a gstreamer pipeline that defaults to v4l2->hlssink2

-h? show this help
-t  use a test source
-d  v4l2 device to use.  Default /dev/video0
-r  playlist-root        Default none
-o  output directory     Default none
-f  filter               Default video/x-raw, format=NV12,width=1920,height=1080
-s  source               Default v4l2, this will define the source, 
                         otherwise it is composed by using the v4l2 with the -d option
"
EOF
}


while getopts "h?td:r:o:f:s:" opt; do
  case "$opt" in
    h|\?) show_help && exit 0 ;;
    t) test=1 ;;
    d) device=$OPTARG ;;
    r) playlist_root="playlist-root=$OPTARG" ;;
    o) location="playlist-location=$OPTARG/playlist.m3u8 location=$OPTARG/segment%05d.ts" ;;
    f) filter="! $OPTARG" ;;
    s) source=$OPTARG; test=-1 ;;
    esac
done

source=""
case "$test" in
    "-1") ;;
    "0") source="v4l2src device=$device" ;;
    "1") source="videotestsrc" ;;
esac

echo "gst-launch-1.0 $source $filter ! videoconvert ! x264enc tune=zerolatency ! hlssink2 $playlist_root $location"
gst-launch-1.0 $source $filter ! videoconvert ! x264enc tune=zerolatency ! hlssink2 $playlist_root $location
