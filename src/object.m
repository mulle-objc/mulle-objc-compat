//
//  object.m
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
#include "object.h"

#include "include-private.h"


/*
 * id
 */

/*
 * https://github.com/RetVal/objc-runtime/blob/942d274d24f06ace04022100b01f17aee0766fdc/runtime/objc-runtime-new.mm#L6219
 */
id   object_copy( id obj, size_t extra)
{
   struct _mulle_objc_class    *cls;
   void                        *dup;
   size_t                      size;

   if( ! obj)
      return( obj);

   cls  = _mulle_objc_object_get_isa( obj);
   size = _mulle_objc_class_get_instancesize( cls);
   dup  = _mulle_objc_infraclass_alloc_instance_extra( (struct _mulle_objc_infraclass *) cls, extra);
   if( ! dup)
      return( dup);

   //
   // this function rarely makes sense, as the ivars aren't retained properly
   // it would be possible to do so, but Apple doesn't do it either
   //
   memcpy( dup, obj, extra + size);

   return( dup);
}


//
// https://github.com/RetVal/objc-runtime/blob/1614b34b287a4a926ae6aa0c6e0e2e494c206599/runtime/objc-class.mm#L401
// Curious named interface
//
static Ivar   _object_getInstanceVariable( id obj, char *name)
{
    struct _mulle_objc_infraclass  *infra;
    struct _mulle_objc_ivar        *ivar;
    mulle_objc_ivarid_t            ivarid;

    if( ! name || ! name[ 0])
       return( NULL);

    infra = mulle_objc_object_get_infraclass( obj);
    if( ! infra)
       return( NULL);

    ivarid = mulle_objc_ivarid_from_string( name);
    ivar   = _mulle_objc_infraclass_search_ivar( infra, ivarid);
    return( ivar);
}


Ivar   object_getInstanceVariable( id obj, char *name, void **outValue)
{
   struct _mulle_objc_ivar   *ivar;

   ivar = _object_getInstanceVariable( obj, name);
   if( outValue)
   {
       if( ivar)
           *outValue = object_getIvar( obj, ivar); // get Ivar does not return an Ivar!
       else
           *outValue = NULL;
   }
   return( ivar);
}


Ivar   object_setInstanceVariable( id obj, char *name, void *value)
{
    struct _mulle_objc_ivar   *ivar;

    ivar   = _object_getInstanceVariable( obj, name);
    if( ivar && value)
        object_setIvar( obj, ivar, value); // get Ivar does not return an Ivar!
    return( ivar);
}


IMP   object_getMethodImplementation( id obj, SEL sel)
{
   Class  cls;

   cls = object_getClass( obj);
   return( class_getMethodImplementation( cls, sel));
}


IMP   object_getMethodImplementation_stret( id obj, SEL sel)
{
   Class  cls;

   cls = object_getClass( obj);
   return( class_getMethodImplementation_stret( cls, sel));
}
