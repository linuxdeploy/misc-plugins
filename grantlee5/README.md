# linuxdeploy-plugin-grantlee5

This linuxdeploy plugin copies grantlee5's plugins into the AppDir and uses linuxdeploy and the Qt plugin to deploy the dependencies.

The plugin uses CMake to auto-detect the plugins path. Should this fail (e.g., because they cannot be found by CMake, or during cross compilation), users can specify the directory manually in `$GRANTLEE5_PLUGINS_DIR`
