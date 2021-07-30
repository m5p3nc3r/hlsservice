#!/bin/bash

profile=m5p3nc3r
build='hlsstream hlsserver'
platform='linux/arm64,linux/amd64'
dryrun=0

show_help() {
    echo << EOF "
Build the containers and push upstream

-h? show this help
-n  profile name            Default m5p3nc3r
-b  containers to build     Default 'hlsstream hlsserver'
-p  platforms to build for  Default 'linux/arm64,linux/amd64'
-d  dry run                 Default false
"
EOF
}

while getopts "h?n:b:p:d" opt; do
  case "$opt" in
    h|\?) show_help && exit 0 ;;
    n)    profile=$OPTARG ;;
    b)    build=$OPTARG ;;
    p)    platform=$OPTARG ;;
    d)    dryrun=1 ;;
   esac
done

for container in $build; do
   case "$dryrun" in
      "1") echo docker buildx build --platform $platform -t $profile/$container ./$container --push ;;
      "0") docker buildx build --platform $platform -t $profile/$container ./$container --push ;;
   esac
done