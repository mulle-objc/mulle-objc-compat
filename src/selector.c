#include "selector.h"

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
   struct _mulle_objc_descriptor  tmp;
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
   universe = mulle_objc_get_universe();
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

   desc = _mulle_objc_universe_unfailingregister_descriptor( universe, dup);
   if( desc != dup)
   {
      // collision 
      if( n >= 16)
         _mulle_allocator_free( allocator, dup->signature);
      _mulle_allocator_free( allocator, dup->name);
      _mulle_allocator_free( allocator, dup);
   }
   else
   {
      // don't leak this
      if( n >= 16)
         mulle_objc_universe_unfailingadd_gift( universe, dup->name);
      mulle_objc_universe_unfailingadd_gift( universe, dup->name);
   }
   return( desc->methodid);
}
