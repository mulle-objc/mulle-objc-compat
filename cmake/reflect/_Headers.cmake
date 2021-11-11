# This file will be regenerated by `mulle-match-to-cmake` via
# `mulle-sde reflect` and any edits will be lost.
#
# This file will be included by cmake/share/Headers.cmake
#
if( MULLE_TRACE_INCLUDE)
   MESSAGE( STATUS "# Include \"${CMAKE_CURRENT_LIST_FILE}\"" )
endif()

#
# contents are derived from the file locations

set( INCLUDE_DIRS
src
src/objc
)

#
# contents selected with patternfile ??-header--objc-headers
#
set( OBJC_HEADERS
src/objc/Protocol.h
src/objc/message.h
src/objc/objc-abi.h
src/objc/objc-api.h
src/objc/objc-auto.h
src/objc/objc-cache.h
src/objc/objc-class.h
src/objc/objc-config.h
src/objc/objc-env.h
src/objc/objc-exception.h
src/objc/objc-gdb.h
src/objc/objc.h
src/objc/objc-internal.h
src/objc/objc-runtime.h
src/objc/objc-sync.h
src/objc/runtime.h
)

#
# contents selected with patternfile ??-header--private-generic-headers
#
set( PRIVATE_GENERIC_HEADERS
src/import-private.h
src/include-private.h
)

#
# contents selected with patternfile ??-header--public-generic-headers
#
set( PUBLIC_GENERIC_HEADERS
src/import.h
src/include.h
)

#
# contents selected with patternfile ??-header--public-headers
#
set( PUBLIC_HEADERS
src/class.h
src/ivar.h
src/method.h
src/mulle-objc-compat.h
src/objc.h
src/object.h
src/property.h
src/protocol.h
src/runtime.h
src/selector.h
)

