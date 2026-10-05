# Focused Linux strategy validation

On 2026-10-04, Ubuntu 24.04/GCC 13.3 compiled the current addon protocol,
group batch, pending ownership and completion inbox tests directly. All 30
cases passed with 4,380 assertions, including concurrent inbox producers/drain.

This validates the copied protocol/strategy policy and its standard C++ thread
support on Linux. It does not compile native worldserver integration, run the
full 318-case suite, or validate Linux realm behavior. Docker's Linux engine was
stopped; the available Ubuntu environment had GCC but lacked CMake, Ninja and
the native server dependency headers. Subsequently, the existing isolated build
container completed the full Linux worldserver/tests-common build and 318/318
CTest checks on Ubuntu 22.04/GCC 11.4. See
[milestone evidence](PLAYERBOTS_STATE_MILESTONE.md); Linux runtime remains untested.

From the core root, with the project's fetched Catch2 single header available:

```sh
mkdir -p build/linux-strategy-check
g++ -std=c++17 -O0 -pthread \
  -Ibuild-both/_deps/catch2-src/single_include \
  -Isrc/common -Isrc/server/game/Server \
  tests/common/test-main.cpp \
  modules/mod-playerbots/tests/test-PlayerbotAddonProtocol.cpp \
  modules/mod-playerbots/tests/test-PlayerbotStrategyBatch.cpp \
  modules/mod-playerbots/tests/test-PlayerbotStrategyPending.cpp \
  modules/mod-playerbots/tests/test-PlayerbotStrategyCompletions.cpp \
  -o build/linux-strategy-check/strategy-check
build/linux-strategy-check/strategy-check --reporter compact
```

Adjust the Catch2 include path if the existing CMake build directory differs.
This uses the checked-in tests and their normal main, without generated test
stubs or installed packages. The first compile attempt omitted `src/common`;
adding that existing include directory resolved the missing Define.h input.
