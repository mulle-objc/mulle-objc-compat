cmake_minimum_required( VERSION 3.1)

project( mulle-objc-compat C)

# should be behind option but...
set( CREATE_OBJC_LOADER_INC OFF)

### mulle-sde environment

# add cmake module paths to search path
list( INSERT CMAKE_MODULE_PATH 0 "${PROJECT_SOURCE_DIR}/cmake/share")
list( INSERT CMAKE_MODULE_PATH 0 "${PROJECT_SOURCE_DIR}/cmake/reflect")
list( INSERT CMAKE_MODULE_PATH 0 "${PROJECT_SOURCE_DIR}/cmake")

include( Environment)

include( Files)

### Library

if( HEADERS_PHASE)
   install( FILES ${INSTALL_PUBLIC_HEADERS}  DESTINATION "include/mulle-objc-compat")
   install( FILES ${INSTALL_PRIVATE_HEADERS} DESTINATION "include/mulle-objc-compat/private")
   install( FILES ${CMAKE_INCLUDES}          DESTINATION "include/mulle-objc-compat/cmake")
   install( FILES ${OBJC_HEADERS}            DESTINATION "include/objc")

   # short cut out
   if( NOT COMPILE_PHASE AND NOT LINK_PHASE)
      return()
   endif()
endif()

if( LINK_PHASE)
   include( Dependencies OPTIONAL)
endif()

include( Library)
include( InstallLibrary)
include( FinalOutput OPTIONAL)
