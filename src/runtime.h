#ifndef objc_mullecompat_runtime__h__
#define objc_mullecompat_runtime__h__

#include "include.h"

#ifdef __MULLE_OBJC_TPS__
# define OBJC_HAVE_TAGGED_POINTERS   1
#endif


#define OBJC_ARC_UNAVAILABLE
#define OBJC_GC_UNAVAILABLE
#define OBJC_SWIFT_UNAVAILABLE( ignore)
#define OBJC_AVAILABLE( a, b, c, d, e)
#define OBJC_DEPRECATED( ignore)
#define OBJC_API_VERSION 2
#define OBJC_ISA_AVAILABILITY
#define OBJC_EXTERN extern
#define OBJC_IMPORT extern
#define OBJC_INLINE inline
#define OBJC_VISIBLE

#ifndef OBJC_ROOT_CLASS
# if __has_attribute( objc_root_class)
#  define OBJC_ROOT_CLASS __attribute__((objc_root_class))
# else
#  define OBJC_ROOT_CLASS
# endif
#endif

#ifdef __OBJC_GC__
# error Objective-C garbage collection is not supported.
#endif


//
// TODO: think about introducing using the runtime lock on this level
//
static inline BOOL   objc_collectingEnabled( void)
{
   return( NO);
}

static inline BOOL   objc_collecting_enabled( void)
{
   return( NO);
}


MULLE_OBJC_COMPAT_EXTERN_GLOBAL
void   _objc_registerTaggedPointerClass( unsigned int index, Class cls);
//
// stret parameter is ignored. Will install and override forwarding in
// all present and future classes
//
MULLE_OBJC_COMPAT_EXTERN_GLOBAL
void   objc_setForwardHandler( void *fwd, void *fwd_stret);

#endif
