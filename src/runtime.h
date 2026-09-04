//
//  runtime.h
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
#ifndef objc_mullecompat_runtime__h__
#define objc_mullecompat_runtime__h__

#include "include.h"

#ifdef __MULLE_OBJC_TPS__
# define OBJC_HAVE_TAGGED_POINTERS   1
#endif


#define OBJC_ARC_UNAVAILABLE
#define OBJC_GC_UNAVAILABLE
#define OBJC_SWIFT_UNAVAILABLE( ignore)
#define OBJC_AVAILABLE( a, b, c, d, e)
#define OBJC_DEPRECATED( ignore)
#define OBJC_API_VERSION 2
#define OBJC_ISA_AVAILABILITY
#define OBJC_EXTERN extern
#define OBJC_IMPORT extern
#define OBJC_INLINE inline
#define OBJC_VISIBLE

#ifndef OBJC_ROOT_CLASS
# if __has_attribute( objc_root_class)
#  define OBJC_ROOT_CLASS __attribute__((objc_root_class))
# else
#  define OBJC_ROOT_CLASS
# endif
#endif

#ifdef __OBJC_GC__
# error Objective-C garbage collection is not supported.
#endif


//
// TODO: think about introducing using the runtime lock on this level
//
static inline BOOL   objc_collectingEnabled( void)
{
   return( NO);
}

static inline BOOL   objc_collecting_enabled( void)
{
   return( NO);
}


MULLE_OBJC_COMPAT_GLOBAL
void   _objc_registerTaggedPointerClass( unsigned int index, Class cls);
//
// stret parameter is ignored. Will install and override forwarding in
// all present and future classes
//
MULLE_OBJC_COMPAT_GLOBAL
void   objc_setForwardHandler( void *fwd, void *fwd_stret);

#endif
