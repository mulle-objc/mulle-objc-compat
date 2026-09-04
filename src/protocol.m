//
//  protocol.m
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
#include "protocol.h"

#include "include-private.h"

/*
 * PROTOCOL
 * There exists a runtime mulle protocol struct, but it's not the same as PROTOCOL
 * which is a unique ID. That means, that a protocol will be created and registered
 * as a Protocol *, but referenced only as PROTOCOL.
 */

//
// once registered the "Protocol" will not be retrievable from the runtime
// with objc_.. functions
//
/* protocol struct support (initialization only) */

Protocol *objc_allocateProtocol( char *name)
{
   struct _mulle_objc_universe  *universe;
   Protocol                     *protocol;
   mulle_objc_protocolid_t      protocolid;

   if( ! name)
      return( NULL);

   universe   = MulleObjCGetUniverse();
   protocolid = mulle_objc_protocolid_from_string( name);
   if( _mulle_objc_universe_lookup_protocol( universe, protocolid))
      return( NULL);

   protocol             = mulle_objc_universe_calloc( universe, 1, sizeof( protocol));
   protocol->name       = mulle_objc_universe_strdup( universe, name);
   protocol->protocolid = protocolid;
   return( protocol);
}


void  objc_registerProtocol( Protocol *proto)
{
   struct _mulle_objc_universe  *universe;

   if( ! proto)
      return;

   universe = MulleObjCGetUniverse();
   _mulle_objc_universe_register_protocol( universe, proto);
}


void   protocol_addMethodDescription( Protocol *proto,
                                      SEL name,
                                      char *types,
                                      BOOL isRequiredMethod,
                                      BOOL isInstanceMethod)
{
   // silently ignore method description, since mulle-objc doesn't remember it
}


void protocol_addProtocol( Protocol *proto, PROTOCOL addition)
{
   // silently ignore PROTOCOL, since mulle-objc doesn't remember it
}


void protocol_addProperty( Protocol *proto,
                           char *name,
                           objc_property_attribute_t *attributes,
                           unsigned int attributeCount,
                           BOOL isRequiredProperty,
                           BOOL isInstanceProperty)
{
   // silently ignore property, since mulle-objc doesn't remember it
}


Protocol *objc_getProtocol( char *name)
{
   struct _mulle_objc_universe  *universe;
   mulle_objc_protocolid_t      protocolid;
   Protocol                     *proto;

   if( ! name)
   {
      errno = EINVAL;
      return( NULL);
   }

   protocolid = mulle_objc_protocolid_from_string( name);
   universe   = MulleObjCGetUniverse();
   proto      = _mulle_objc_universe_lookup_protocol( universe, protocolid);
   if( proto)
      return( proto);

   errno = ENOENT;
   return( NULL);
}

struct protocol_copy_ctxt
{
   Protocol   **p;
   Protocol   **sentinel;
};


mulle_objc_walkcommand_t   copy_protocol( struct _mulle_objc_universe  *universe,
                                          Protocol *p,
                                          void *userinfo)
{
   struct protocol_copy_ctxt   *ctxt = userinfo;

   if( ctxt->p == ctxt->sentinel)
      return( mulle_objc_walk_done);

   *(ctxt->p)++ = p;
   return( mulle_objc_walk_ok);
}


Protocol **objc_copyProtocolList( unsigned int *outCount)
{
   struct _mulle_objc_universe  *universe;
   unsigned int                 n;
   Protocol                     **list;
   struct protocol_copy_ctxt    ctxt;

   universe = MulleObjCGetUniverse();
   n        = _mulle_objc_universe_count_protocols( universe);
   if( outCount && *outCount < n)
   {
      *outCount = n;
      return( NULL);
   }

   list          = mulle_allocator_malloc( &mulle_stdlib_allocator,
                                           sizeof( Protocol *) * n);
   ctxt.p        = list;
   ctxt.sentinel = &ctxt.p[ n];

   _mulle_objc_universe_walk_protocols( universe, copy_protocol, &ctxt);

   return( list);
}


struct objc_method_description *
   protocol_copyMethodDescriptionList( Protocol *proto,
                                       BOOL isRequiredMethod,
                                       BOOL isInstanceMethod,
                                       unsigned int *outCount)
{
   if( outCount)
      *outCount = 0;
   return( NULL);
}


struct objc_method_description
   protocol_getMethodDescription( Protocol *proto,
                                  SEL aSel,
                                  BOOL isRequiredMethod,
                                  BOOL isInstanceMethod)
{
   struct objc_method_description   desc;

   desc.name =  (SEL) 0;
   desc.types = NULL;

   return( desc);
}

objc_property_t *protocol_copyPropertyList( Protocol *proto,
                                            unsigned int *outCount)
{
   if( outCount)
      *outCount = 0;
   return( NULL);
}

objc_property_t  protocol_getProperty( Protocol *proto,
                                       char *name,
                                       BOOL isRequiredProperty,
                                       BOOL isInstanceProperty)
{
   return( NULL);
}

PROTOCOL *protocol_copyProtocolList( Protocol *proto, unsigned int *outCount)
{
   if( outCount)
      *outCount = 0;
   return( NULL);
}

