# Optional modules in this TrinityCore fork

Each module lives in its own `modules/<name>/` directory with a `CMakeLists.txt`,
source, configuration template, and documentation. The build discovers those
directories and creates `MODULE_<UPPERCASE_NAME>` options, replacing hyphens with
underscores. For example, `-DMODULE_MOD_PLAYERBOTS=OFF` excludes Playerbots.
Playerbots and AHBot are developed in separate Git checkouts at
`modules/mod-playerbots` and `modules/mod-ahbot`; both are ignored by the core
repository. A core checkout alone therefore contains neither implementation.
Place compatible module checkouts in those directories before configuring an
enabled build. The core README records the module commits for each coordinated
snapshot; arbitrary module/core combinations are not assumed to build together.
Module code is statically compiled into the native `game` target. This provides
source compartmentalization and optional build integration; dynamic loading and
drop-in AzerothCore compatibility require separate work.

A module's CMake registration can follow this convention:

```cmake
CollectSourceFiles("${CMAKE_CURRENT_SOURCE_DIR}/src" SOURCES)
CollectIncludeDirectories("${CMAKE_CURRENT_SOURCE_DIR}/src" INCLUDES)
tc_register_module(
  NAME mod-example
  SOURCES ${SOURCES}
  INCLUDE_DIRS ${INCLUDES}
  LOADER AddSC_example_module
  CONFIG "${CMAKE_CURRENT_SOURCE_DIR}/conf/example.conf.dist")
```

`LOADER` and `CONFIG` are optional. The loader function registers ordinary native
ScriptMgr scripts in the static script context, after core scripts are registered.
It is generated into the build; adding an ordinary script module does not require
editing `custom_script_loader.cpp`. Config templates are installed into the module
config directory. Configurations contain one INI section, like core configurations.
`TEST_SOURCES` optionally contributes tests to the existing test executable only
when that module is enabled. Core tests do not depend on absent module headers.
`TEST_LIBRARIES` optionally adds native/interface dependencies to that test target
only when the module is enabled. Prefer interface targets for native header access
when a payload-only test does not need the server runtime.

At runtime, only enabled modules' active `.conf` files are loaded. The directory
defaults to `modules` beside the selected `worldserver.conf`, configurable through
`Modules.ConfigDirectory`. Main settings load first, then module files in sorted
directory discovery order; later matching keys override earlier values. Missing
files use main-config values/defaults. Reload rereads main settings and reapplies
active module files. Parse failure is reported without applying that file partially.
Module-specific activation policy decides how to handle a failed configuration.

Gameplay/state belongs to modules; ownership/thread/lifecycle hooks that scripts
cannot provide stay narrow in core. AHBot uses this boundary through
`mod-ahbot`; its core bridge is limited to initialization, update dispatch, and
auction-mail bot identity checks. Database migrations remain explicit module
work; this mechanism does not introduce a module
SQL auto-updater, shared-library ABI or arbitrary AzerothCore API emulation.
