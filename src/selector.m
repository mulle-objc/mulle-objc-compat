//
//  selector.m
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
#include "selector.h"

#include "include-private.h"

/*
 *
 */

SEL   sel_registerName( char *str)
{
   struct _mulle_objc_universe    *universe;
   struct mulle_allocator         *allocator;
   mulle_objc_methodid_t          methodid;
   struct _mulle_objc_descriptor  *desc;
   struct _mulle_objc_descriptor  *dup;
   size_t                         size;
   unsigned int                   n;
   static char  *fake_signatures[ 16] =
   {
      "@@:",
      "@@:@",
      "@@:@@",
      "@@:@@@",
      "@@:@@@@",
      "@@:@@@@@",
      "@@:@@@@@@",
      "@@:@@@@@@@",
      "@@:@@@@@@@@",
      "@@:@@@@@@@@@",
      "@@:@@@@@@@@@@",
      "@@:@@@@@@@@@@@",
      "@@:@@@@@@@@@@@@",
      "@@:@@@@@@@@@@@@@",
      "@@:@@@@@@@@@@@@@@",
      "@@:@@@@@@@@@@@@@@@"
   };

   if( ! str || ! str[ 0])
      return( 0);

   methodid = mulle_objc_methodid_from_string( str);
   universe = MulleObjCGetUniverse();
   desc     = _mulle_objc_universe_lookup_descriptor( universe, methodid);
   if( desc)
      return( methodid);

   allocator     = _mulle_objc_universe_get_allocator( universe);
   dup           = _mulle_allocator_malloc( allocator, sizeof( struct _mulle_objc_descriptor));
   dup->methodid = methodid;
   dup->name     = _mulle_allocator_strdup( allocator, str);

   n = mulle_objc_count_selector_arguments( str);
   if( n < 16)
      dup->signature = fake_signatures[ n];
   else
   {
      size           = mulle_objc_get_untypedsignature_length( n) + 1;
      dup->signature = _mulle_objc_universe_calloc( universe, 1, size);
      _mulle_objc_sprint_untypedsignature( dup->signature, size, n);
   }

   desc = _mulle_objc_universe_register_descriptor_nofail( universe, dup, NULL, NULL);
   if( desc != dup)
   {
      // collision: dup->signature when n >= 16 is already gifted by
      // _mulle_objc_universe_calloc, don't free it
      _mulle_allocator_free( allocator, dup->name);
      _mulle_allocator_free( allocator, dup);
   }
   else
   {
      // gift the non-gifted allocations (dup->signature is already gifted
      // by _mulle_objc_universe_calloc when n >= 16)
      mulle_objc_universe_add_gift_nofail( universe, dup->name);
      mulle_objc_universe_add_gift_nofail( universe, dup);
   }
   return( desc->methodid);
}


// good to have this non-inline for debuggers
SEL   sel_getUid( char *str)
{
    return( sel_registerName( str));
}
