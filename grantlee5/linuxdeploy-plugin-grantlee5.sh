#! /bin/bash

# exit whenever a command called in this script fails
set -eo pipefail

appdir=""

show_usage() {
    echo "Usage: bash $0 --appdir <AppDir>"
}

while [ "$1" != "" ]; do
    case "$1" in
        --plugin-api-version)
            echo "0"
            exit 0
            ;;
        --appdir)
            appdir="$2"
            shift
            shift
            ;;
        *)
            echo "Invalid argument: $1"
            echo
            show_usage
            exit 2
    esac
done

if [[ "$appdir" == "" ]]; then
    show_usage
    exit 2
fi

# we just need to copy the grantlee plugins properly to the Qt plugins dir which linuxdeploy-plugin-qt defines
# http://www.grantlee.org/apidox_generictypes/using_and_deploying.html

echo "### NOTE: THIS PLUGIN MUST BE USED IN COMBINATION WITH LINUXDEPLOY'S QT PLUGIN! ###"

# grantlee doesn't provide any _easy_ way to find the plugins' path, therefore we ask CMake

echo "Using CMake to find grantlee5 plugins path (note: you may need to specify your path manually using \$GRANTLEE5_PLUGINS_DIR, e.g., when cross-compiling)"

if [[ "$GRANTLEE5_PLUGINS_DIR" == "" ]]; then
    tempdir="$(mktemp -d /tmp/linuxdeploy-plugin-grantlee-XXXXX)"

    _cleanup() {
        cmake_log="$tempdir"/cmake.log
        if [[ -f "$cmake_log" ]]; then
            echo "CMake failed, log:"
            cat "$cmake_log"
        fi

        [[ -d "$tempdir" ]] && rm -r "$tempdir"
    }
    trap _cleanup EXIT

    pushd "$tempdir" &>/dev/null

    cat > CMakeLists.txt <<\EOF
cmake_minimum_required(VERSION 3.10)
project(linuxdeploy-plugin-grantlee)

find_package(Grantlee5 REQUIRED)

set(imported_target "Grantlee5::defaultfilters")

message(STATUS "Fetching imported location for target ${imported_target}")

foreach(property_name IMPORTED_LOCATION_NONE IMPORTED_LOCATION_RELWITHDEBINFO)
    get_property(imported_location TARGET "${imported_target}" PROPERTY "${property_name}")

    message(STATUS "Property ${property_name} value: \"${imported_location}\"")

    if(NOT "${imported_location}" STREQUAL "")
        break()
    endif()
endforeach()

if("${imported_location}" STREQUAL "")
    message(FATAL_ERROR "Could not find location with CMake")
endif()

get_property(imported_location TARGET "${imported_target}" PROPERTY IMPORTED_LOCATION_NONE)
message(STATUS "Imported location: ${imported_location}")

file(WRITE "${CMAKE_CURRENT_SOURCE_DIR}/imported-location" "${imported_location}")
EOF

    cmake . &>cmake.log

    # clean up log if everything worked, otherwise it would be printed by the cleanup handler
    [[ "$VERBOSE" != "" ]] && rm cmake.log

    imported_location="$(cat imported-location)"

    if [[ "$imported_location" == "" ]]; then
        echo "Error: could not find plugins location with CMake"
        exit 2
    fi

    GRANTLEE5_PLUGINS_DIR="$(dirname "$imported_location")"

    popd &>/dev/null
fi

echo "\$GRANTLEE5_PLUGINS_DIR=$GRANTLEE5_PLUGINS_DIR"

if [[ ! -d "$GRANTLEE5_PLUGINS_DIR" ]]; then
    echo "Error: grantlee5 plugins directory does not exist or could not be found"
    exit 2
fi

# guess grantlee version from the plugin path
# this should always be the last component, as the plugins need to be stored in a directory like .../grantlee/<version>/grantlee*.so
grantlee5_version="$(echo "$GRANTLEE5_PLUGINS_DIR" | rev | cut -d/ -f1 | rev)"

target_dir="$appdir"/usr/plugins/grantlee/"$grantlee5_version"

echo "Copying plugins from $GRANTLEE5_PLUGINS_DIR to $target_dir"
install -v -D -t "$target_dir" "$GRANTLEE5_PLUGINS_DIR"/*

echo "Using linuxdeploy to deploy dependencies"

if ! test -x "$LINUXDEPLOY"; then
    echo "Error: \$LINUXDEPLOY is not set or not executable"
    exit 2
fi

"$LINUXDEPLOY" --appdir "$appdir" --plugin qt --deploy-deps-only "$target_dir"
