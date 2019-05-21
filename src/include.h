#ifndef mulle_objc_compat_include_h__
#define mulle_objc_compat_include_h__

/* This is a central include file to keep dependencies out of the library
   C files. It is usally included by .h files only.

   The advantage is that now .c and .h files become motile. They can
   be moved to other projects and don't need to be edited. Also less typing...

   Therefore it is important that this file is called "include.h" and
   not "mulle-objc-compat-include.h" to keep the #include statements in the
   library code uniform.

   The C-compiler will pick up the nearest one.
*/

/* Include the header file automatically generated by c-sourcetree-update.
   Here the prefix is harmless and serves disambiguation. If you have no
   sourcetree, then you don't need it.
 */

// define some stuff, if compiling with plain C

#ifndef __MULLE_OBJC__
# define __MULLE_OBJC_TPS__
# define __MULLE_OBJC_FMC__
# define __MULLE_OBJC_UNIVERSNAME__   falballa
#endif

#include "_mulle-objc-compat-include.h"

#include <MulleObjC/mulle-objc.h>

#endif
