#! /bin/bash

# exit whenever a command called in this script fails
set -e

if [ "$DEBUG" != "" ]; then
    set -x
    verbose="--verbose"
fi

appdir=""

show_usage() {
    echo "Usage: bash $0 --appdir <AppDir>"
    echo
    echo "Bundles source files for debugging"
    echo
    echo "Required variables:"
    echo "  LINUXDEPLOY_PLUGIN_GDB_SRC: path to source directory"
    echo
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
        --help)
            show_usage
            exit 0
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

if [ -z "$LINUXDEPLOY_PLUGIN_GDB_SRC" ]; then
    echo "$0: LINUXDEPLOY_PLUGIN_GDB_SRC environment variable is not set"
    show_usage
    exit 2
fi

echo "Copying source files"
cp --recursive $verbose "$LINUXDEPLOY_PLUGIN_GDB_SRC" "$appdir/usr/"

echo "Installing new AppRun wrapper"
exe="$(readlink -f "$appdir/AppRun.wrapped")"
rm $verbose "$appdir/AppRun.wrapped"
cat > "$appdir/AppRun.wrapped" <<EOF
#! /bin/bash

if [[ -n "\$APPIMAGE_USE_GDB" ]]; then
	gdb --cd "\$APPDIR/usr/$(basename "$LINUXDEPLOY_PLUGIN_GDB_SRC")" --args "\$APPDIR/${exe#$appdir}" "\$@"
else
	exec "\$APPDIR/${exe#$appdir}" "\$@"
fi
EOF
chmod $verbose 755 "$appdir/AppRun.wrapped"
