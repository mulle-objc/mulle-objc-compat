//
//  protocol.h
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
#ifndef objc_mullecompat_protocol__h__
#define objc_mullecompat_protocol__h__

#include "include.h"

#include "method.h"
#include "property.h"


typedef struct _mulle_objc_protocol   Protocol;


/*
 * PROTOCOL
 * There exists a runtime mulle protocol struct, but it's not the same as PROTOCOL 
 * which is a unique ID. That means, that a protocol will be created and registered
 * as a Protocol *, but referenced only as PROTOCOL.
 */


//
// once registered the "Protocol" will not be retrievable from the runtime
// with objc_.. functions. All Method/Property functions are just placebos.
// Any of the protocol query functions except name are placebos.
// Query the class for protocol conformance.
//

/* protocol struct support (initialization only), this is not the same
   as @protocol() which is PROTOCOL which is a hash value
 */
MULLE_OBJC_COMPAT_GLOBAL
Protocol *objc_getProtocol( char *name);

MULLE_OBJC_COMPAT_GLOBAL
Protocol *objc_allocateProtocol( char *name);

MULLE_OBJC_COMPAT_GLOBAL
void objc_registerProtocol( Protocol *proto);

MULLE_OBJC_COMPAT_GLOBAL
void protocol_addMethodDescription( Protocol *proto, 
                                    SEL name, 
                                    char *types, 
                                    BOOL isRequiredMethod, 
                                    BOOL isInstanceMethod);

MULLE_OBJC_COMPAT_GLOBAL
void protocol_addProtocol( Protocol *proto, PROTOCOL addition);

MULLE_OBJC_COMPAT_GLOBAL
void protocol_addProperty( Protocol *proto, 
                           char *name, 
                           objc_property_attribute_t *attributes, 
                           unsigned int attributeCount, 
                           BOOL isRequiredProperty, 
                           BOOL isInstanceProperty);

static inline BOOL   protocol_conformsToProtocol( Protocol *proto, 
                                                  PROTOCOL other)
{
   if( ! proto)
      return( NO);
   return( _mulle_objc_protocol_get_protocolid( proto) == other);
}

static inline char *protocol_getName( Protocol *proto)
{
   if( ! proto)
      return( NULL);
   return( _mulle_objc_protocol_get_name( proto));
}

//
// none of this is really supported as protocol in mulle-objc are
// mostly just syntax constructs. The only tangible data left at
// runtime is the name and the selector
//
struct objc_method_description *
   protocol_copyMethodDescriptionList( Protocol *proto, 
                                       BOOL isRequiredMethod, 
                                       BOOL isInstanceMethod, 
                                       unsigned int *outCount);
struct objc_method_description 
    protocol_getMethodDescription( Protocol *proto, 
                                   SEL aSel, 
                                   BOOL isRequiredMethod, 
                                   BOOL isInstanceMethod);

MULLE_OBJC_COMPAT_GLOBAL
objc_property_t *protocol_copyPropertyList( Protocol *proto, 
                                            unsigned int *outCount);

MULLE_OBJC_COMPAT_GLOBAL
objc_property_t  protocol_getProperty( Protocol *proto, 
                                       char *name, 
                                       BOOL isRequiredProperty, 
                                       BOOL isInstanceProperty);

MULLE_OBJC_COMPAT_GLOBAL
PROTOCOL *protocol_copyProtocolList( Protocol *proto, 
                                     unsigned int *outCount);

MULLE_OBJC_COMPAT_GLOBAL
Protocol **objc_copyProtocolList(unsigned int *outCount);


static inline BOOL protocol_isEqual( Protocol *proto, Protocol *other)
{
   return( proto == other);
}



#endif
