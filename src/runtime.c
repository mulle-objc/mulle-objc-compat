#include "runtime.h"

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

   forward.descriptor.name      = "forward::";
   forward.descriptor.methodid  = mulle_objc_methodid_from_string( forward.descriptor.name);
   forward.descriptor.signature = "v@:@@";
   forward.implementation       = fwd;

   universe = mulle_objc_get_or_create_universe();
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

   universe = mulle_objc_get_universe();
   if ( _mulle_objc_universe_set_taggedpointerclass_at_index( universe, cls, index))
      mulle_objc_raise_inconsistency_exception( "Tagged pointer index %u is out of range", index);
}
