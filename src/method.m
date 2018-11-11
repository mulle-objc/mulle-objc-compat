#include "method.h"

#include "include-private.h"

#include <stdarg.h>
#include <ctype.h>

//
// this would infact be horribly slow
// a) would need to construct new stackframe based on argument types
// b) would not be able to pass varargs (no way to figure that out)
// c) would not be able to return struct values
//

struct type_range
{
   int   offset;
   int   length;
};


static void   strrangecpy( char *dst, size_t dst_len, char *src, struct type_range src_range)
{
   // stay compatible, though I 'd never write it like this
   strncpy( dst, &src[ src_range.offset], src_range.length > dst_len ? dst_len : src_range.length);
   if( src_range.length < dst_len)
      memset( &dst[ src_range.length], 0, dst_len - src_range.length);
}


static struct type_range  _signature_findTypeRange_skip( char *start, unsigned int skip)
{
   char                        *next;
   size_t                       len;
   char                         *s;
   char                         offset;
   struct type_range            range;
   struct mulle_objc_typeinfo   info;

   s = start;
   while( skip)
   {
      s = mulle_objc_signature_next_type( s);
      --skip;
   }

   if( ! s)
      return( (struct type_range) { -1, 0 } );

   mulle_objc_signature_supply_next_typeinfo( s, &info);
   range.offset = (int) (info.type - start);
   range.length = (int) (info.pure_type_end - info.type);
   return( range);
}


// skip 0: rval
// skip 1: self
// skip 2: _cmd
// skip 3: arg 0
static void  _signature_getType_skip( char *s, unsigned int skip, char *dst, size_t dst_len)
{
   size_t              len;
   struct type_range   range;

   range = _signature_findTypeRange_skip( s, skip);
   if( range.offset == -1)
   {
      strncpy( dst, "", dst_len);
      return;
   }

   strrangecpy( dst, dst_len, s, range);
}


//
// https://github.com/RetVal/objc-runtime/blob/7c1a317710f5e8ed738e7105591905c808d208e7/runtime/objc-typeencoding.mm#L274
//
void   method_getReturnType(Method m, char *dst, size_t dst_len)
{
   char   *s;

   if( ! dst)
      return;

   s = m && m->descriptor.signature ? m->descriptor.signature : NULL;

   _signature_getType_skip( s, 0, dst, dst_len);
}


// in a bizare twist this considers
// index 0: self
// index 1: _cmd
// index 2: arg 0
void   method_getArgumentType( Method m, unsigned int index, char *dst, size_t dst_len)
{
   char   *s;

   if( ! dst)
      return;
   if( (int) index < 0)
   {
      strncpy( dst, "", dst_len);
      return;
   }
   s = m && m->descriptor.signature ? m->descriptor.signature : NULL;
   _signature_getType_skip( s, index + 1, dst, dst_len);
}


//
// https://github.com/RetVal/objc-runtime/blob/1614b34b287a4a926ae6aa0c6e0e2e494c206599/runtime/objc-class.mm#L932
//

// skip 0: rval
// skip 1: self
// skip 2: _cmd
// skip 3: arg 0
static char   *method_copyType_skip( Method m, unsigned int skip)
{
   struct type_range   range;
   char                *s;
   char                *dst;

   s     = (m && m->descriptor.signature) ? m->descriptor.signature : NULL;
   range = _signature_findTypeRange_skip( s, skip);
   if( range.offset == -1)
      return( NULL);

   dst = mulle_allocator_malloc( &mulle_stdlib_allocator, range.length + 1);
   memcpy( dst, &s[ range.offset], range.length);

   dst[ range.length] = 0;
   return( dst);
}

char   *method_copyReturnType( Method m)
{
   // use negative skip to get at actual arg #0
   return( method_copyType_skip( m, 0));
}


// in a bizare twist this considers
// self arg: 0
// _cmd arg: 1
 // arg 0: 2
char   *method_copyArgumentType( Method m, unsigned int index)
{
   if( (int) index < 0)
      return( NULL);
   return( method_copyType_skip( m, index + 1));
}


//
// this is not really thread safe as this can't be done properly atomically
// since it needs two atomic operations
//
void  method_exchangeImplementations( Method m1, Method m2)
{
   struct _mulle_objc_universe   *universe;
   mulle_objc_implementation_t   m1_imp;
   mulle_objc_implementation_t   m2_imp;

   if ( ! m1 || !m2)
      return;

   universe = MulleObjCGetUniverse();

   // lock that operates on the scope of compat only
   _mulle_objc_universe_lock( universe);

   m1_imp = _mulle_objc_method_get_implementation( m1);
   m2_imp = _mulle_objc_method_get_implementation( m2);
   _mulle_objc_method_set_implementation( m1, m2_imp);
   _mulle_objc_method_set_implementation( m2, m1_imp);

   _mulle_objc_universe_invalidate_classcaches( universe, NULL);

   _mulle_objc_universe_unlock( universe);
}
