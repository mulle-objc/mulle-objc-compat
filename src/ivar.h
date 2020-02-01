#ifndef objc_mullecompat_ivar__h__
#define objc_mullecompat_ivar__h__

#include "include.h"

// this is done already in ns-ojc-type.h
// typedef struct _mulle_objc_ivar  *Ivar;


/*
 * IVAR
 */
static inline char *   ivar_getName(Ivar v)
{
    return( v ? v->descriptor.name : NULL);
}


static inline char *   ivar_getTypeEncoding( Ivar v)
{
    return( v ? v->descriptor.signature : NULL);
}


static inline ptrdiff_t   ivar_getOffset(Ivar v)
{
    return( v ? v->offset : 0);
}

#endif
