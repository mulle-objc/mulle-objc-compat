#include "object.h"



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
   size = _mulle_objc_class_get_instancesize( cls) - sizeof( struct _mulle_objc_objectheader);
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
