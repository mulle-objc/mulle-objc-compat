### 0.21.7






feature: make test configuration selectable via `TEST_CONFIGURATION`

* test/run-test honors the `TEST_CONFIGURATION` environment variable (defaulting to Debug) and forwards the chosen configuration to `mulle-sde dependency-dir` and `mulle-sde test link-args`
* Added autotools (aclocal, automake, autoheader, autom4te, glibtoolize) to the tool environment




feature: add proper CMake `add_subdirectory` and `find_package` consumer support

* add AddSubdirectorySupport and FindPackageSupport modules, replacing InstallCMakeInclude and InstallCMakePackage
* `add_subdirectory` consumers now inherit dependency include directories and transitively link resolved dependency targets
* `find_package` consumers get exported targets plus generated config and version files that resolve dependencies by name
* propagate whole-archive force-linking for initialization libraries via a portable INTERFACE wrapper (CMake 3.24+)
* embed a UTF-8 activeCodePage manifest in Windows executables so argv and environment arrive as UTF-8
* split SDK and dependency discovery out of Environment into SDKEnvironment, gated by the new `USE_DEPENDENCY_DIR` option

### 0.21.6



* fix allocation gifting when registering a selector name collides
* no longer frees the signature gifted by the universe allocator
* correctly gifts the descriptor instead of leaking it

### 0.21.5

Various small improvements
