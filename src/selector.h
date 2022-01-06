#ifndef objc_mullecompat_selector__h__
#define objc_mullecompat_selector__h__

#include "include.h"


/*
 * SEL
 */
static inline char  *sel_getName( SEL sel)
{
   char   *s;

   if( ! sel)
      return( "<null selector>");

   s = mulle_objc_global_lookup_methodname( MULLE_OBJC_DEFAULTUNIVERSEID, sel);
   return( s ? s : "<unknown selector>");
}


static inline BOOL   sel_isEqual( SEL lhs, SEL rhs)
{
    return( lhs == rhs);
}


MULLE_OBJC_COMPAT_EXTERN_GLOBAL
SEL   sel_registerName( char *str);

MULLE_OBJC_COMPAT_EXTERN_GLOBAL
SEL   sel_getUid( char *str);

#endif
