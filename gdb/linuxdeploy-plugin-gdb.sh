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
# AppRun script does: exec "$this_dir"/AppRun.wrapped "$@"
# AppRun.wrapped (this script) is a wrapper on AppRun.wrapped.orig
# AppRun.wrapped.orig is the real application
old_exe="$(readlink -f "$appdir/AppRun.wrapped")"
new_exe="$old_exe.orig"
mv $verbose "$old_exe" "$new_exe"
cat > "$old_exe" <<EOF
#! /bin/bash

if [[ -n "\$APPIMAGE_USE_GDB" ]]; then
	gdb --cd "\$APPDIR/usr/$(basename "$LINUXDEPLOY_PLUGIN_GDB_SRC")" --args "\$APPDIR/${new_exe#"$appdir"}" "\$@"
else
	exec "\$APPDIR/${new_exe#"$appdir"}" "\$@"
fi
EOF
chmod $verbose 755 "$old_exe"
