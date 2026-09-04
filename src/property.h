//
//  property.h
//  mulle-objc-compat
//
//  Copyright (c) 2018 Nat! - Mulle kybernetiK.
//  All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  Neither the name of Mulle kybernetiK nor the names of its contributors
//  may be used to endorse or promote products derived from this software
//  without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
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


MULLE_OBJC_COMPAT_GLOBAL
char   *property_copyAttributeValue( objc_property_t property, char *attributeName);

MULLE_OBJC_COMPAT_GLOBAL
objc_property_attribute_t *property_copyAttributeList( objc_property_t property,
                                                       unsigned int *outCount);


MULLE_OBJC_COMPAT_GLOBAL
void   objc_setProperty( id self,
                         SEL _cmd,
                         ptrdiff_t offset,
                         id newValue,
                         BOOL atomic,
                         signed char shouldCopy);

MULLE_OBJC_COMPAT_GLOBAL
void   objc_setProperty_nonatomic(id self, SEL _cmd, id newValue, ptrdiff_t offset);

MULLE_OBJC_COMPAT_GLOBAL
void   objc_setProperty_nonatomic_copy(id self, SEL _cmd, id newValue, ptrdiff_t offset);

MULLE_OBJC_COMPAT_GLOBAL
void   objc_setProperty_atomic(id self, SEL _cmd, id newValue, ptrdiff_t offset);

MULLE_OBJC_COMPAT_GLOBAL
void   objc_setProperty_atomic_copy(id self, SEL _cmd, id newValue, ptrdiff_t offset);

#endif
