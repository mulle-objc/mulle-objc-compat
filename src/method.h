#ifndef objc_mullecompat_method__h__
#define objc_mullecompat_method__h__

#include "include.h"

#include <stdint.h>


//
// provide some runtime glue, to map Apple runtime calls to
// MulleObjC runtime calls
// Obviously this can't be 100% perfect....
//
struct objc_method_description
{
   SEL    name;
   char   *types;
};

// this is done already in ns-ojc-type.h
// typedef struct _mulle_objc_method *Method;

/*
 * Method
 * This uses the MetaABI and is wildly incompatible, except
 * if you're only passing one or none objects around as a
 * parameter. We don't have stret class. Its better to fail
 * at link time.
 */
static inline id   method_invoke( id receiver, Method m, void *_param)
{
   mulle_objc_implementation_t   imp;

   imp = _mulle_objc_method_get_implementation( m);
   return( mulle_objc_implementation_invoke( imp,
                                             receiver,
                                             _mulle_objc_method_get_methodid( m),
                                             _param));
}


static inline SEL   method_getName(Method m)
{
   return( mulle_objc_method_get_methodid( m));
}


static inline IMP   method_getImplementation(Method m)
{
   return( (IMP) mulle_objc_method_get_implementation( m));
}


static inline char *   method_getTypeEncoding(Method m)
{
   return( mulle_objc_method_get_signature( m));
}

MULLE_OBJC_COMPAT_GLOBAL
char * method_copyReturnType(Method m);

MULLE_OBJC_COMPAT_GLOBAL
char * method_copyArgumentType(Method m, unsigned int index);

MULLE_OBJC_COMPAT_GLOBAL
void method_getReturnType(Method m, char *dst, size_t dst_len);

MULLE_OBJC_COMPAT_GLOBAL
void method_getArgumentType(Method m, unsigned int index, char *dst, size_t dst_len);


static inline unsigned int method_getNumberOfArguments( Method m)
{
   return( m ? mulle_objc_count_selector_arguments( m->descriptor.name) + 2 : 0);
}


//
// the objc_method_description is at an offset in the mulle descriptor!
//
static inline struct objc_method_description * method_getDescription( Method m)
{
   return( m ? (struct objc_method_description *) &m->descriptor : NULL);
}


// hmm, do this only for setup ?
static inline IMP   method_setImplementation( Method m, IMP imp)
{
   if( ! m || ! imp)
      return( NULL);
   return( (IMP) _mulle_atomic_functionpointer_set( &m->implementation,
                                                    (mulle_functionpointer_t) imp));
}


MULLE_OBJC_COMPAT_GLOBAL
void  method_exchangeImplementations(Method m1, Method m2);

#endif
