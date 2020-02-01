#ifndef objc_mullecompat_property__h__
#define objc_mullecompat_property__h__

#include "include.h"


//
// provide some runtime glue, to map Apple runtime calls to
// MulleObjC runtime calls
// Obviously this can't be 100% perfect....
//
typedef struct _mulle_objc_property  *objc_property_t;

typedef struct
{
   char   *name;
   char   *value;
} objc_property_attribute_t;

/*
 * @property
 */
static inline char   *property_getName( objc_property_t property)
{
   return( mulle_objc_property_get_name( property));
}


static inline char   *property_getAttributes( objc_property_t property)
{
   return( mulle_objc_property_get_signature( property));
}


char   *property_copyAttributeValue( objc_property_t property, char *attributeName);

objc_property_attribute_t *property_copyAttributeList( objc_property_t property,
                                                       unsigned int *outCount);



void   objc_setProperty( id self,
                         SEL _cmd,
                         ptrdiff_t offset,
                         id newValue,
                         BOOL atomic,
                         signed char shouldCopy);

void   objc_setProperty_nonatomic(id self, SEL _cmd, id newValue, ptrdiff_t offset);
void   objc_setProperty_nonatomic_copy(id self, SEL _cmd, id newValue, ptrdiff_t offset);

void   objc_setProperty_atomic(id self, SEL _cmd, id newValue, ptrdiff_t offset);
void   objc_setProperty_atomic_copy(id self, SEL _cmd, id newValue, ptrdiff_t offset);

#endif
