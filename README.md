# Collection of miscellaneous linuxdeploy plugins

This repository contains miscellaneous [linuxdeploy plugins](https://github.com/linuxdeploy/linuxdeploy/wiki/Plugin-system). They're mostly written in plain bash (or even just Bourne shell).


## Usage

```bash
# get linuxdeploy
> wget -c "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage"

# get some plugin
> wget -c "https://raw.githubusercontent.com/linuxdeploy/misc-plugins/master/demo/linuxdeploy-plugin-demo.sh"

# first option: install your app into your AppDir via `make install` etc.
# second option: bundle your app's main executables manually
# see https://docs.appimage.org/packaging-guide/from-source/native-binaries.html for more information
> [...]

# call through linuxdeploy
> ./linuxdeploy-x86_64.AppImage --appdir AppDir --plugin demo --output appimage --icon-file mypackage.png --desktop-file mypackage.desktop
```


## Contributing new plugins

Plugins in this repository must be "download, make executable, run". That means that they must be written in script languages that are typically available on systems (e.g., bash). They must be able to run standalone (that means, making them executable and running them without linuxdeploy should yield some useful log). The files must respect the linuxdeploy [plugin naming](https://github.com/linuxdeploy/linuxdeploy/wiki/Plugin-system#plugin-naming), and implement the [mandatory CLI parameters](https://github.com/linuxdeploy/linuxdeploy/wiki/Plugin-system#mandatory-parameters).

Most of these plugins just call other tools on the system, install AppRun hooks, or perform other simple tasks. More complex ones should be moved into dedicated repositories.

Plugins may have dependencies on system tools. Ideally, these are commonly available (e.g., `readelf`). They should always check whether these are available, and either hard-fail (print error and exit), or warn the user and deactivate certain functionality if programs cannot be found in `$PATH`.

linuxdeploy can be expected to be available (`$LINUXDEPLOY` usually points to a working binary), and it can be used to perform certain tasks such as bundling additional binaries or libraries along with their dependencies.
Even though `$LINUXDEPLOY` is set by linuxdeploy automatically, the plugin should always check for its existence (e.g., with `[ -x "$LINUXDEPLOY" ]`) and provide meaningful feedback.

The `demo` plugin is a very simple, minimal working example plugin. Please feel free to take it as an inspiration for your own plugins.

Only plugins with free software licenses (recognized by the OSI) are accepted into this repository. It is highly recommended to use the MIT license (the same license linuxdeploy and all official plugins use), but it's not mandatory. However, if your plugin uses a non-permissive license (e.g., a copyleft one), it might be rejected, depending on how it works.


## Testing

Basic tests are available under `tests`. Plugins that require specific environment variables must have a `.test.env` file in their directory, containing all prerequisite.


## Licensing

All plugin scripts reside in subdirectories of this repository, along with a README. If there is no LICENSE file next to the plugin script, the license in `LICENSE.txt` in the root directory of the repository applies.
