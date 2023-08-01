#!/bin/bash
repo_root=$(git rev-parse --show-toplevel)
pack_root=$1
modrinthpack="$pack_root/*.mrpack"
indextoml="$pack_root/index.toml"
pack_version="$(basename ${pack_root})"
build_dir="$repo_root/builds/${pack_version}"
echo ${pack_root}
if [ ! -d "$indextoml" ]; then
    # If the directory doesn't exist, create it
    touch "$indextoml"
fi

if [ ! -d "$build_dir" ]; then
    # If the directory doesn't exist, create it
    mkdir "$build_dir" --parents
    echo "Created Build Directory $pack_version" > $build_dir/.log
fi

( cd $pack_root && packwiz modrinth export ) || {
    packwiz modrinth export >> $build_dir$/.log
    # If the build command fails, show a Zenity error dialog
    
    echo "Build failed! Try deleting the 'index.toml' file & doing a git pull"

    zenity --error --text="Build failed! Try deleting the 'index.toml' file & doing a git pull"
    echo "$(pwd)"
    exit 1
}
pack_filename="$(basename ${modrinthpack})"
mv $modrinthpack $build_dir

if [ -f "$build_dir/.log" ] && [ -f "$build_dir/${pack_filename}" ]; then
    # If any ".mrpack" file exists, delete the log file
    rm "$build_dir/.log"
    echo "Deleted Log."
fi

