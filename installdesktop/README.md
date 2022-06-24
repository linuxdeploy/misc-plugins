# linuxdeploy-plugin-installdesktop

This plugin provides an --install-desktop switch to be parsed for an AppImage.  If present, the APP.desktop and APP.png/svg are installed into either /usr/share or ~/.local/share so that the application may be found through the start menu / menu system on a linux platform.

The plugin assumes that there is only one .desktop and only one png/svg file in the root folder of the AppDir.

**:warning: This plugin is experimental and has not been tried with several applications. :warning:**

## Usage

```bash
# get linuxdeploy and linuxdeploy-plugin-installdesktop

> wget -c "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage"
> wget -c "https://raw.githubusercontent.com/linuxdeploy/misc-plugins/master/installdesktop/linuxdeploy-plugin-installdesktop.sh"

# first option: install your app into your AppDir via `make install` etc.
# second option: bundle your app's main executables manually
# see https://docs.appimage.org/packaging-guide/from-source/native-binaries.html for more information
> [...]

# call through linuxdeploy
> ./linuxdeploy-x86_64.AppImage --appdir AppDir --plugin installdesktop --output appimage --icon-file mypackage.png --desktop-file mypackage.desktop
```
## Using

Once packaged, launch the application as follows (to install in the user's folders)

  appimage.AppImage --install-desktop

or (to install in the system folders)

  sudo appimage.AppImage --install-desktop
