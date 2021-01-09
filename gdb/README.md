# linuxdeploy-plugin-gdb

This plugin allows to debug the application within AppImage through GDB.  
To allow GDB to find source files, `LINUXDEPLOY_PLUGIN_GDB_SRC` environment variable must be set: this plugin copies source files inside AppDir during AppImage build process.

**:warning: This plugin is experimental and has not been tried with several applications. :warning:**

## Usage

```bash
# get linuxdeploy and linuxdeploy-plugin-gdb
> wget -c "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage"
> wget -c "https://raw.githubusercontent.com/linuxdeploy/misc-plugins/master/gdb/linuxdeploy-plugin-gdb.sh"

# first option: install your app into your AppDir via `make install` etc.
# second option: bundle your app's main executables manually
# see https://docs.appimage.org/packaging-guide/from-source/native-binaries.html for more information
> [...]

# call through linuxdeploy
> export LINUXDEPLOY_PLUGIN_GDB_SRC="/some/path/to/app/source"
> ./linuxdeploy-x86_64.AppImage --appdir AppDir --plugin gdb --output appimage --icon-file mypackage.png --desktop-file mypackage.desktop
```

## Start GDB

By default, the AppImage works normally. To start GDB, set the `APPIMAGE_USE_GDB` environment variable, like this:
```bash
# start the AmmImage with GDB
> APPIMAGE_USE_GDB=1 ./mypackage-x86_64.AppImage
```
