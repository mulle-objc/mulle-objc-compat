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

   s = mulle_objc_lookup_methodname( sel);
   return( s ? s : "<unknown selector>");
}


static inline BOOL   sel_isEqual( SEL lhs, SEL rhs)
{
    return( lhs == rhs);
}


SEL   sel_registerName( char *str);


static inline SEL   sel_getUid( char *str)
{   
    return( sel_registerName( str));
}

#endif
