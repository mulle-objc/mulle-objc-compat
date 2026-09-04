//
//  runtime.m
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
#include "runtime.h"

#include "include-private.h"


static mulle_objc_walkcommand_t
   set_forward( struct _mulle_objc_universe *universe,
                void *cls,
                enum mulle_objc_walkpointertype_t type,
                char *key,
                void *parent,
                void *userinfo)
{
   struct _mulle_objc_method   *forward = userinfo;

   _mulle_objc_class_set_forwardmethod( cls, forward);
   return( mulle_objc_walk_ok);
}


void   objc_setForwardHandler( void *fwd, void *fwd_stret)
{
   struct _mulle_objc_universe       *universe;
   static struct _mulle_objc_method   forward;

   if( ! fwd)
      return;

   forward.descriptor.name      = "forward:";
   forward.descriptor.methodid  = mulle_objc_methodid_from_string( forward.descriptor.name);
   forward.descriptor.signature = "^v@:^v";
   _mulle_atomic_functionpointer_nonatomic_write( &forward.implementation,
                                                  fwd);

   universe = MulleObjCGetUniverse();
   _mulle_objc_universe_lock( universe);
   {
      universe->classdefaults.forwardmethod = &forward;
      // with meta
      _mulle_objc_universe_walk_classes( universe, 1, set_forward, &forward);
   }
   _mulle_objc_universe_unlock( universe);
}


void   _objc_registerTaggedPointerClass( unsigned int index, Class cls)
{
   struct _mulle_objc_universe   *universe;

   universe = MulleObjCGetUniverse();
   if ( _mulle_objc_universe_set_taggedpointerclass_at_index( universe, cls, index))
      mulle_objc_universe_fail_inconsistency( universe, "Tagged pointer index %u is out of range", index);
}
