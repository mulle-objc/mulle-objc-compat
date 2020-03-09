#ifndef objc_mullecompat_object__h__
#define objc_mullecompat_object__h__

#include "include.h"

#include "class.h"


// convert objc_objectptr_t to id, callee must take ownership.
static inline id objc_retainedObject(void *pointer) { return (id) pointer; }

// convert objc_objectptr_t to id, without ownership transfer.
static inline id objc_unretainedObject(void *pointer) { return (id)pointer; }

// convert id to objc_objectptr_t, no ownership transfer.
static inline void *objc_unretainedPointer(id object) { return object; }


/*
 * id
 */
static inline Class    object_getClass( id obj)
{
   return( (Class) mulle_objc_object_get_isa( obj));
}


// not atomic in mulle-objc!
static inline Class   object_setClass( id obj, Class cls)
{
   Class   old;

   if( ! obj)
      return( Nil);

   old = object_getClass( obj);
   _mulle_objc_object_set_isa( obj, (struct _mulle_objc_class *) cls);
   return( old);
}


static inline id   class_createInstance( Class cls, size_t extraBytes)
{
    return( (id) mulle_objc_infraclass_alloc_instance_extra( cls, extraBytes));
}


static inline id   objc_constructInstance( Class cls, void *bytes)
{
   void  *obj;

   if( ! cls)
      return( nil);

   obj = _mulle_objc_objectheader_get_object( (struct _mulle_objc_objectheader *) bytes);
   _mulle_objc_object_set_isa( obj, _mulle_objc_infraclass_as_class( cls));
   return( obj);
}

//
// https://github.com/RetVal/objc-runtime/blob/1614b34b287a4a926ae6aa0c6e0e2e494c206599/runtime/objc-class-old.mm#L2368
//
static inline void   *objc_destructInstance( id obj)
{
   return( obj);
}

id   object_copy( id obj, size_t size);


static inline id   object_dispose( id obj)
{
   objc_destructInstance( obj);
   mulle_objc_instance_free( (struct _mulle_objc_object *) obj);
   return( nil);
}


static inline char   *object_getClassName( id obj)
{
   return( (char *) class_getName( object_getClass( obj)));
}


static inline void   object_setIvar( id obj, Ivar ivar, id value)
{
   if( ! obj || ! ivar)
      return;

   _mulle_objc_object_set_pointervalue_for_ivar( obj, ivar, value);
}


static inline id    object_getIvar( id obj, Ivar ivar)
{
   if( ! obj || ! ivar)
      return( nil);

   return( _mulle_objc_object_get_pointervalue_for_ivar( obj, ivar));
}


static inline void  *object_getIndexedIvars( id obj)
{
   void        *extra;
   uintptr_t   ivars;

   extra = mulle_objc_object_get_extra( obj);
   ivars = ((uintptr_t) extra + (sizeof( void *) - 1)) & ~(sizeof( void *) - 1);
   return( (void *) ivars);
}


Ivar  object_getInstanceVariable( id obj, char *name, void **outValue);
Ivar  object_setInstanceVariable( id obj, char *name, void *value);


static inline Class   gdb_class_getClass( Class cls)
{
   char *s;

   s = _mulle_objc_class_get_name( (struct _mulle_objc_class *) cls);
   if( ! s || ! s[ 0])
      return( Nil);

   return( (Class) objc_getClass( s));  // differs in that it will do the callback
}


static inline Class   gdb_object_getClass( id obj)
{
   if( ! obj)
     return( Nil);
   return( gdb_class_getClass( (Class) _mulle_objc_object_get_isa( obj)));
}


IMP   object_getMethodImplementation( id obj, SEL sel);
IMP   object_getMethodImplementation_stret( id obj, SEL sel);

#endif
