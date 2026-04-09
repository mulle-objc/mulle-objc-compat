### 0.21.4









* tests now use pointer-sized integer types `(intptr_t` / NSUInteger) to avoid truncation/ABI mismatches for retain counts and mutation pointers
* add --platform option to test/run-test and forward it to mulle-sde link-args so tests can be linked for a specific platform
