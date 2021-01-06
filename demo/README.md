# linuxdeploy-plugin-demo

This is a minimal demo of a linuxdeploy plugin written in plain bash. You can use it as a template for other plugins.


## Usage

```bash
# get linuxdeploy and linuxdeploy-plugin-demo
> wget -c "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage"
> wget -c "https://raw.githubusercontent.com/linuxdeploy/misc-plugins/master/demo/linuxdeploy-plugin-demo.sh"

# first option: install your app into your AppDir via `make install` etc.
# second option: bundle your app's main executables manually
# see https://docs.appimage.org/packaging-guide/from-source/native-binaries.html for more information
> [...]

# call through linuxdeploy
> ./linuxdeploy-x86_64.AppImage --appdir AppDir --plugin demo --output appimage --icon-file mypackage.png --desktop-file mypackage.desktop
```
