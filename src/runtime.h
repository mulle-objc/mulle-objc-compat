#ifndef objc_mullecompat_runtime__h__
#define objc_mullecompat_runtime__h__

#include "include.h"

#ifdef __MULLE_OBJC_TPS__
# define OBJC_HAVE_TAGGED_POINTERS   1
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


void   _objc_registerTaggedPointerClass( unsigned int index, Class cls);
//
// stret parameter is ignored. Will install and override forwarding in
// all present and future classes
//
void   objc_setForwardHandler( void *fwd, void *fwd_stret);

#endif