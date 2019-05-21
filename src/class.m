#include "class.h"

#include "include-private.h"

#include <assert.h>
#include <errno.h>
#include <stdlib.h>

#pragma clang diagnostic ignored "-Wparentheses"


Class   objc_allocateClassPair( Class superclass, char *name, size_t extraBytes)
{
   struct _mulle_objc_universe   *universe;
   struct _mulle_objc_classpair  *classpair;
   mulle_objc_classid_t          classid;

   if( extraBytes || ! name || ! name[ 0])
   {
       errno = EINVAL;  // not possible in mulle-objc
       return( Nil);
   }

   // name must be strduped here for API compatibility
   universe  = MulleObjCGetUniverse();
   name      = mulle_objc_universe_strdup( universe, name);
   classid   = mulle_objc_classid_from_string( name);
   classpair = mulle_objc_universe_new_classpair( universe, classid, name, 0, 0, superclass);
   if( ! classpair)
   {
      mulle_allocator_free( _mulle_objc_universe_get_allocator( universe),
                            name);
      return( Nil);
   }
   mulle_objc_universe_add_gift_nofail( universe, name);

   return( mulle_objc_classpair_get_infraclass( classpair));
}


//
// this is wrong and should be done in a 'load' if I remember correctly
// as this isn't using the waitqueues properly
//
void   objc_registerClassPair( Class infra)
{
   struct _mulle_objc_universe    *universe;
   struct _mulle_objc_metaclass   *meta;

   universe = MulleObjCGetUniverse();
   meta     = _mulle_objc_infraclass_get_metaclass( infra);

   // fix up missing stuff, since mulle-objc-runtime has special needs
   // empty lists will be added where required

   mulle_objc_infraclass_add_methodlist_nofail( infra, NULL);
   mulle_objc_metaclass_add_methodlist_nofail( meta, NULL);
   mulle_objc_infraclass_add_ivarlist_nofail( infra, NULL);
   mulle_objc_infraclass_add_propertylist_nofail( infra, NULL);

   mulle_objc_universe_add_infraclass_nofail( universe, infra);
}


//
// don't do it, s
//
void   objc_disposeClassPair( Class cls)
{
   struct _mulle_objc_universe    *universe;
   struct _mulle_objc_classpair   *classpair;
   struct mulle_allocator         *allocator;

   if( ! cls)
      return;

   universe  = MulleObjCGetUniverse();
   allocator = _mulle_objc_universe_get_allocator( universe);
   classpair = _mulle_objc_infraclass_get_classpair( cls);

   mulle_objc_universe_remove_infraclass( universe, cls);
   mulle_objc_classpair_free( classpair, allocator);
}


static struct _mulle_objc_methodlist  *
   universe_duplicate_methodlist( struct _mulle_objc_universe  *universe,
                                  struct _mulle_objc_methodlist *list)
{
   unsigned int                    n;
   struct _mulle_objc_methodlist   *dup;

   n   = _mulle_objc_methodlist_get_count( list);
   dup = mulle_objc_universe_alloc_methodlist( universe, n);
   memcpy( dup, list, mulle_objc_sizeof_methodlist( n));
   return( dup);
}


static void   class_copy_methodlists( struct _mulle_objc_class *dst,
                                      struct _mulle_objc_class *cls)
{
   struct mulle_concurrent_pointerarray             *array;
   struct mulle_concurrent_pointerarrayenumerator   rover;
   struct _mulle_objc_methodlist                    *list;
   struct _mulle_objc_methodlist                    *dup;
   struct _mulle_objc_universe                      *universe;

   universe = _mulle_objc_class_get_universe( dst);

   rover = mulle_concurrent_pointerarray_enumerate( &cls->methodlists);
   while( list = (struct _mulle_objc_methodlist *) mulle_concurrent_pointerarrayenumerator_next( &rover))
   {
      dup = universe_duplicate_methodlist( universe, list);
      mulle_objc_class_add_methodlist( dst, dup);
   }
   mulle_concurrent_pointerarrayenumerator_done( &rover);
}


static struct _mulle_objc_ivarlist  *
   universe_duplicate_ivarlist( struct _mulle_objc_universe *universe,
                                struct _mulle_objc_ivarlist *list)
{
   unsigned int                  n;
   struct _mulle_objc_ivarlist   *dup;

   n   = _mulle_objc_ivarlist_get_count( list);
   dup = mulle_objc_universe_alloc_ivarlist( universe, n);
   memcpy( dup, list, mulle_objc_sizeof_ivarlist( n));
   return( dup);
}


static void   infraclass_copy_ivarlists( struct _mulle_objc_infraclass *dst,
                                         struct _mulle_objc_infraclass *cls)
{
   struct mulle_concurrent_pointerarray             *array;
   struct mulle_concurrent_pointerarrayenumerator   rover;
   struct _mulle_objc_ivarlist                      *list;
   struct _mulle_objc_ivarlist                      *dup;
   struct _mulle_objc_universe                      *universe;

   universe = _mulle_objc_infraclass_get_universe( dst);

   rover = mulle_concurrent_pointerarray_enumerate( &cls->ivarlists);
   while( list = mulle_concurrent_pointerarrayenumerator_next( &rover))
   {
      dup = universe_duplicate_ivarlist( universe, list);
      mulle_objc_infraclass_add_ivarlist( dst, dup);
   }
   mulle_concurrent_pointerarrayenumerator_done( &rover);
}


static struct _mulle_objc_propertylist  *
   universe_duplicate_propertylist( struct _mulle_objc_universe *universe,
                                    struct _mulle_objc_propertylist *list)
{
   unsigned int                      n;
   struct _mulle_objc_propertylist   *dup;

   n   = _mulle_objc_propertylist_get_count( list);
   dup = mulle_objc_universe_alloc_propertylist( universe, n);
   memcpy( dup, list, mulle_objc_sizeof_propertylist( n));
   return( dup);
}


static void   infraclass_copy_propertylists( struct _mulle_objc_infraclass *dst,
                                             struct _mulle_objc_infraclass *cls)
{
   struct mulle_concurrent_pointerarray             *array;
   struct mulle_concurrent_pointerarrayenumerator   rover;
   struct _mulle_objc_propertylist                  *list;
   struct _mulle_objc_propertylist                  *dup;
   struct _mulle_objc_universe                      *universe;

   universe = _mulle_objc_infraclass_get_universe( dst);
   rover    = mulle_concurrent_pointerarray_enumerate( &cls->ivarlists);
   while( list = mulle_concurrent_pointerarrayenumerator_next( &rover))
   {
      dup = universe_duplicate_propertylist( universe, list);
      mulle_objc_infraclass_add_propertylist( dst, dup);
   }
   mulle_concurrent_pointerarrayenumerator_done( &rover);
}


static int   copy_protocolids( mulle_objc_protocolid_t protoid,
                               struct _mulle_objc_classpair *pair,
                               void *info)
{
   struct _mulle_objc_classpair *dst = info;

   _mulle_objc_classpair_add_protocolids( dst, 1, &protoid);
   return( 0);
}


static void  classpair_copy_protocolids( struct _mulle_objc_classpair *dst,
                                        struct _mulle_objc_classpair *pair)
{
   _mulle_objc_classpair_walk_protocolids( pair, 0, copy_protocolids, dst);
}


static int   copy_categoryids( mulle_objc_categoryid_t protoid,
                               struct _mulle_objc_classpair *pair,
                               void *info)
{
   struct _mulle_objc_classpair *dst = info;

   _mulle_objc_classpair_add_categoryids( dst, 1, &protoid);
   return( 0);
}


static void  classpair_copy_categoryids( struct _mulle_objc_classpair *dst,
                                         struct _mulle_objc_classpair *pair)
{
   _mulle_objc_classpair_walk_categoryids( pair, 0, copy_categoryids, dst);
}


static void   classpair_copy_protocolclasses( struct _mulle_objc_classpair *dst,
                                              struct _mulle_objc_classpair *pair)
{
   struct _mulle_objc_protocolclassenumerator   rover;
   struct _mulle_objc_infraclass                *infra;

   rover = _mulle_objc_classpair_enumerate_protocolclasses( pair);
   while( infra = _mulle_objc_protocolclassenumerator_next( &rover))
      _mulle_objc_classpair_add_protocolclass( dst, infra);
   _mulle_objc_protocolclassenumerator_done( &rover);
}


//
// this doesn't pass the test, because we can not shallow copy properties
// and ivars.
//
Class   objc_duplicateClass( Class original, char *name, size_t extraBytes)
{
   struct _mulle_objc_infraclass   *infra;
   struct _mulle_objc_metaclass    *meta;
   struct _mulle_objc_classpair    *pair;
   struct _mulle_objc_metaclass    *original_meta;
   struct _mulle_objc_classpair    *original_pair;

//    assert(original->isRealized());
   assert( ! _mulle_objc_class_is_metaclass( (struct _mulle_objc_class *) original));

   infra = objc_allocateClassPair( mulle_objc_infraclass_get_superclass( original),
                                   name,
                                   extraBytes);
   if( ! infra)
      return( infra);

   original_meta = _mulle_objc_infraclass_get_metaclass( original);
   meta          = _mulle_objc_infraclass_get_metaclass( infra);

   _mulle_objc_object_set_isa( infra,
                              _mulle_objc_object_get_isa( original));
   _mulle_objc_object_set_isa( meta,
                              _mulle_objc_object_get_isa( original_meta));

   _mulle_objc_class_set_superclass( _mulle_objc_metaclass_as_class( meta),
                                     (struct _mulle_objc_class *) _mulle_objc_metaclass_get_superclass( original_meta));

   _mulle_objc_infraclass_set_coderversion( infra,
                                            _mulle_objc_infraclass_get_coderversion( original));

   // duplicate ivars, properties on infra
   // these functions are not useful for cross-universe duplication

   infraclass_copy_propertylists( infra, original);
   infraclass_copy_ivarlists( infra, original);

   // duplicate methods on infra and meta
   // these functions are not useful for cross-universe duplication
   // methodlists are deep copies
   class_copy_methodlists( (struct _mulle_objc_class *) infra,
                           (struct _mulle_objc_class *) original);
   class_copy_methodlists( (struct _mulle_objc_class *) meta,
                           (struct _mulle_objc_class *) original_meta);

   // duplicate protocols and categories on pair
   // these functions are really copying too much
   original_pair = _mulle_objc_infraclass_get_classpair( original);
   pair          = _mulle_objc_infraclass_get_classpair( infra);

   classpair_copy_protocolids( pair, original_pair);
   classpair_copy_categoryids( pair, original_pair);
   classpair_copy_protocolclasses( pair, original_pair);

   return( infra);
}

/*
 *
 */
// https://github.com/RetVal/objc-runtime/blob/942d274d24f06ace04022100b01f17aee0766fdc/runtime/objc-runtime.mm#L140
Class   objc_lookUpClass( char *name)
{
    struct _mulle_objc_universe   *universe;
    mulle_objc_classid_t          classid;

    if( ! name)
    {
       errno = EINVAL;
       return( Nil);
    }
    universe = MulleObjCGetUniverse();
    classid  = mulle_objc_classid_from_string( name);
    return( _mulle_objc_universe_lookup_infraclass( universe, classid));
}


id   objc_getClass( const char *name)
{
    struct _mulle_objc_universe   *universe;
    mulle_objc_classid_t          classid;

    if( ! name)
    {
       errno = EINVAL;
       return( Nil);
    }

    universe = MulleObjCGetUniverse();
    classid  = mulle_objc_classid_from_string( (char *) name);
    return( (id) _mulle_objc_universe_lookup_infraclass( universe, classid));   // do we have a delayed class handler ?
}


id   objc_getMetaClass( const char *name)
{
    Class  infra;

    infra = objc_getClass( name);
    if( infra)
       return( (id) _mulle_objc_infraclass_get_metaclass( infra));
    return( Nil);
}


Class   objc_getRequiredClass( char *name)
{
    mulle_objc_classid_t   classid;

    if( ! name)
       return( Nil);

    classid  = mulle_objc_classid_from_string( name);
    return( mulle_objc_global_lookup_infraclass_nofail( MULLE_OBJC_DEFAULTUNIVERSEID, classid));
}


//
// deprecated anyway
//
Class   class_setSuperclass( Class cls, Class superclass)
{
   struct _mulle_objc_class      *old;
   struct _mulle_objc_universe   *universe;

   universe = MulleObjCGetUniverse();
   _mulle_objc_universe_lock( universe);
   {
      old = _mulle_objc_class_get_superclass((struct _mulle_objc_class *) cls);
      _mulle_objc_class_set_superclass( (struct _mulle_objc_class *) cls,
                                       (struct _mulle_objc_class *) superclass);

      _mulle_objc_universe_invalidate_classcaches( universe, NULL);
   }
   _mulle_objc_universe_unlock( universe);

   return( (Class) old);
}


/*
 *
 */
static mulle_objc_walkcommand_t  count_classes( struct _mulle_objc_universe *universe,
                                                void *p,
                                                enum mulle_objc_walkpointertype_t type,
                                                char *key,
                                                void *parent,
                                                void *userinfo)
{
    int   *count;

    count = userinfo;
    ++*count;
    return( mulle_objc_walk_ok);
}

struct copy_class_info
{
   struct _mulle_objc_class   **list;
   unsigned int               i;
   unsigned int               n;
   unsigned int               total;
};


static mulle_objc_walkcommand_t  copy_classes( struct _mulle_objc_universe *universe,
                                               void *p,
                                               enum mulle_objc_walkpointertype_t type,
                                               char *key,
                                               void *parent,
                                               void *userinfo)
{
    struct copy_class_info   *info;

    info = userinfo;
    info->total++;
    if( info->list && info->i < info->n)
        info->list[ info->i++] = p;
    return( mulle_objc_walk_ok);
}


int   objc_getClassList( Class  *buffer, int bufferCount)
{
   struct _mulle_objc_universe   *universe;
   struct copy_class_info        info;

   info.list  = (struct _mulle_objc_class **) buffer;
   info.i     = 0;
   info.n     = bufferCount;
   info.total = 0;

   universe  = MulleObjCGetUniverse();
   mulle_objc_universe_walk_infraclasses( universe, copy_classes, &info);

   if( ! buffer)
      return( (int) info.total);
   return( (int) info.n);
}

//
// https://github.com/RetVal/objc-runtime/blob/1614b34b287a4a926ae6aa0c6e0e2e494c206599/runtime/objc-runtime-old.mm#L299
//
Class  *objc_copyClassList( unsigned int *outCount)
{
    int    size;
    Class  *list;

    size = objc_getClassList( NULL, 0);
    list = mulle_malloc( (size + 1) * sizeof( Class));

    objc_getClassList( list, size + 1);
    if( outCount)
      *outCount = size;

    return( list);
}

/*
 *
 */
BOOL   class_addIvar( Class cls, char *name, size_t size, uint8_t alignment, char *types)
{
   struct _mulle_objc_universe   *universe;
   struct _mulle_objc_ivar       *ivar;
   struct _mulle_objc_ivarlist   *ivarlist;
   struct mulle_allocator        *allocator;
   size_t                        offset;
   unsigned int                  type_size;
   unsigned int                  type_alignment;
   mulle_objc_classid_t          classid;

   // can't deal with empty name a
   if( ! cls || ! name || ! types || _mulle_objc_class_is_metaclass( (struct _mulle_objc_class *) cls))
      return( NO);

   if( size > UINT32_MAX)  // lets stay compatible
      return( NO);

   ivar = class_getInstanceVariable( cls, name);
   if( ivar)
      return( NO);

   // known to universe already ? Can't do
   universe  = _mulle_objc_infraclass_get_universe( cls);
   classid   = _mulle_objc_infraclass_get_classid( cls);
   if( _mulle_objc_universe_lookup_infraclass( universe, classid))
      return( NO);

   // we check size and alignment, we need size to be correct
   mulle_objc_signature_supply_size_and_alignment( types, &type_size, &type_alignment);
   if( size < type_size)
      return( NO);

   if( ! alignment)
      alignment = type_alignment;
   if( ! size)
      size = type_size;

   // use type_size and type_alignment from now on!

   offset = _mulle_objc_infraclass_get_instancesize( cls);
   if( offset & (alignment - 1))
      offset = (offset + alignment) & ~(alignment - 1);

   allocator = _mulle_objc_universe_get_allocator( universe);

   ivarlist = mulle_allocator_malloc( allocator, mulle_objc_sizeof_ivarlist( 1));
   ivarlist->n_ivars                        = 1;
   ivarlist->ivars[ 0].descriptor.ivarid    = mulle_objc_ivarid_from_string( name);
   ivarlist->ivars[ 0].descriptor.name      = mulle_allocator_strdup( allocator, name);
   ivarlist->ivars[ 0].descriptor.signature = mulle_allocator_strdup( allocator, types);
   ivarlist->ivars[ 0].offset               = _mulle_objc_infraclass_get_instancesize( cls);

   mulle_objc_universe_add_gift_nofail( universe, ivarlist->ivars[ 0].descriptor.name);
   mulle_objc_universe_add_gift_nofail( universe, ivarlist->ivars[ 0].descriptor.signature);

   // don't gift the ivarlist

   mulle_objc_infraclass_add_ivarlist( cls, ivarlist);

   // we recalculate the instance size
   __mulle_objc_infraclass_set_instancesize( cls, offset + size);

   return( YES);
}


Ivar   class_getClassVariable( Class cls, char *name)
{
   mulle_objc_ivarid_t                         ivarid;
   struct mulle_concurrent_hashmapenumerator   rover;
   char                                        *s;

   if( ! cls || ! name || _mulle_objc_class_is_metaclass( (struct _mulle_objc_class *) cls))
      return( NULL);

   // its not compatible the way we do class variables
   return( NULL);
}


Ivar   class_getInstanceVariable( Class cls, char *name)
{
   mulle_objc_ivarid_t   ivarid;

   if( ! cls || ! name || _mulle_objc_class_is_metaclass( (struct _mulle_objc_class *) cls))
      return( NULL);

   ivarid = mulle_objc_ivarid_from_string( name);
   return( _mulle_objc_infraclass_search_ivar( (struct _mulle_objc_infraclass *) cls,
                                               ivarid));
}


static void   _class_addMethod( Class cls,
                                struct _mulle_objc_descriptor *desc,
                                mulle_objc_methodid_t sel,
                                mulle_objc_implementation_t imp,
                                char *types)
{
   struct _mulle_objc_universe     *universe;
   struct _mulle_objc_methodlist   *list;
   size_t                          size;

   // selector must have been registered
   universe = _mulle_objc_class_get_universe( (struct _mulle_objc_class *) cls);

   size = mulle_objc_sizeof_methodlist( 1);
   list = _mulle_objc_universe_calloc( universe, 1, size);

   list->n_methods         = 1;
   list->methods[ 0].value = imp;

   // if types exist and diverge
   if( types && types[ 0] && strcmp( desc->signature, types))
   {
      types = _mulle_objc_universe_strdup( universe, types);
      list->methods[ 0].descriptor.signature = types;
      _mulle_objc_universe_add_gift( universe, types);
   }
   else
      list->methods[ 0].descriptor.signature = desc->signature;

   list->methods[ 0].descriptor.methodid  = sel;
   list->methods[ 0].descriptor.name      = desc->name;

   // this invalidates
   mulle_objc_class_add_methodlist( (struct _mulle_objc_class *) cls, list);
}

/*
 * the API does not provide a name just a SEL, this is not enough to
 * produce a proper method (in mulle-objc). Register your selector first
 * if it isn't defined by any(!) class/category/protocol yet.
 */
static IMP  _class_replaceMethod( Class cls, SEL sel, IMP imp, char *types, BOOL replace)
{
   struct _mulle_objc_universe     *universe;
   struct _mulle_objc_descriptor   *desc;
   BOOL                            flag;
   Method                          m;
   IMP                             old;

   if( ! cls || ! sel || ! imp)
      return( 0);

   universe = _mulle_objc_class_get_universe( (struct _mulle_objc_class *) cls);
   desc     = _mulle_objc_universe_lookup_descriptor( universe, sel);
   if( ! desc)
   {
      fprintf( stderr, "The selector %lx is unknown to the runtime.\n"
                       "Register it with `sel_registerName` first.\n", (unsigned long) sel);
      return( 0);
   }

   old = 0;
   _mulle_objc_universe_lock( universe);
   {
      m = _mulle_objc_class_lookup_method( (struct _mulle_objc_class *) cls, (mulle_objc_methodid_t) sel);
      if( m)
      {
         // replace
         old = method_getImplementation( m);
         if( replace)
            method_setImplementation( m, imp);
      }
      else
         _class_addMethod( cls, desc, sel, (mulle_objc_implementation_t) imp, types);
   }
   _mulle_objc_universe_unlock( universe);

   return( old);
}

IMP   class_replaceMethod( Class cls, SEL sel, IMP imp, char *types)
{
   return( _class_replaceMethod( cls, sel, imp, types, YES));
}


BOOL   class_addMethod( Class cls, SEL sel, IMP imp, char *types)
{
   IMP  old;

   old = _class_replaceMethod( cls, sel, imp, types, NO);
   return( ! old);
}



static char   *copyPropertyAttributeString( objc_property_attribute_t *attrs,
                                            unsigned int count,
                                            struct mulle_allocator *allocator)
{
    char *result;
    unsigned int i;

    if (count == 0) return( NULL);

#if DEBUG
    // debug build: sanitize input
    for (i = 0; i < count; i++) {
        assert(attrs[i].name);
        assert(strlen(attrs[i].name) > 0);
        assert(! strchr(attrs[i].name, ','));
        assert(! strchr(attrs[i].name, '"'));
        if (attrs[i].value) assert(! strchr(attrs[i].value, ','));
    }
#endif

    size_t len = 0;
    for (i = 0; i < count; i++) {
        if (attrs[i].value) {
            size_t namelen = strlen(attrs[i].name);
            if (namelen > 1) namelen += 2;  // long names get quoted
            len += namelen + strlen(attrs[i].value) + 1;
        }
    }

    result = (char *) mulle_allocator_malloc( allocator, len + 1);
    char *s = result;
    for (i = 0; i < count; i++) {
        if (attrs[i].value) {
            size_t namelen = strlen(attrs[i].name);
            if (namelen > 1) {
                s += sprintf(s, "\"%s\"%s,", attrs[i].name, attrs[i].value);
            } else {
                s += sprintf(s, "%s%s,", attrs[i].name, attrs[i].value);
            }
        }
    }

    // remove trailing ',' if any
    if (s > result) s[-1] = '\0';

    return result;
}


/***********************************************************************
* class_addProperty
* Adds a property to a class.
* Locking: acquires runtimeLock
**********************************************************************/
static BOOL
   _class_addProperty( Class cls,
                       char *name,
                       objc_property_attribute_t *attrs,
                       unsigned int count,
                       BOOL replace)
{
   struct _mulle_objc_universe       *universe;
   struct _mulle_objc_property       *prop;
   struct _mulle_objc_propertylist   *proplist;
   struct mulle_allocator            *allocator;
   char                              *s;

   if( ! cls || ! name || _mulle_objc_class_is_metaclass( (struct _mulle_objc_class *) cls))
   {
      errno = EINVAL;
      return( NO);
   }

   prop = class_getProperty( cls, name);
   if( prop && ! replace)
   {
      errno = EEXIST;
      return( NO);
   }

   //
   // mulle-objc can't add properties to classes that have run initialize
   // already... Or can it ? The property will not have a corresponding ivar.
   // Maybe not a problem.
   // if( _mulle_objc_infraclass_is_initialized( cls))
   //{
   //   errno = EBUSY;
   //   return( NO);
   //}

   universe  = _mulle_objc_infraclass_get_universe( cls);
   allocator = _mulle_objc_universe_get_allocator( universe);
   s         = copyPropertyAttributeString( attrs, count, allocator);
   if( s)
      mulle_objc_universe_add_gift_nofail( universe, s);
   else
      s = "";

   if( prop)
   {
      //
      // replace existing (old string is gifted to the runtime anway)
      // this should be atomic, but isn't, since the runtime isn't reading it
      // atomic
      //
      prop->signature = s;
      return( YES);
   }

   proplist = mulle_allocator_malloc( allocator, mulle_objc_sizeof_propertylist( 1));
   proplist->n_properties               = 1;
   proplist->properties[ 0].propertyid  = mulle_objc_propertyid_from_string( name);
   proplist->properties[ 0].name        = mulle_allocator_strdup( allocator, name);
   proplist->properties[ 0].signature   = s;

   mulle_objc_universe_add_gift_nofail( universe, proplist->properties[ 0].name);

   // don't gift the proplist
   mulle_objc_infraclass_add_propertylist( cls, proplist);

   return( YES);
}


BOOL   class_addProperty( Class cls,
                          char *name,
                          objc_property_attribute_t *attrs,
                          unsigned int n)
{
   return( _class_addProperty( cls, name, attrs, n, NO));
}


void   class_replaceProperty( Class cls,
                              char *name,
                              objc_property_attribute_t *attrs,
                              unsigned int n)
{
   _class_addProperty( cls, name, attrs, n, YES);
}


/***********************************************************************
* class_addProtocol
* Adds a protocol to a class.
* Locking: acquires runtimeLock
**********************************************************************/
BOOL   class_addProtocol( Class cls, PROTOCOL protocol)
{
   struct _mulle_objc_classpair      *pair;
   struct _mulle_objc_universe       *universe;
   struct _mulle_objc_protocollist   *protolist;
   struct mulle_allocator            *allocator;


   if( ! cls)
      return( NO);

   if( class_conformsToProtocol( cls, protocol))
      return( NO);

   //
   // adding a protocol at runtime is harmless, doesn't deal with
   // protocol classes though (which would not be harmless)...
   //
   universe  = _mulle_objc_infraclass_get_universe( cls);
   allocator = _mulle_objc_universe_get_allocator( universe);
   protolist = mulle_allocator_malloc( allocator, mulle_objc_sizeof_protocollist( 1));

   protolist->n_protocols               = 1;
   protolist->protocols[ 0].protocolid  = protocol;
   protolist->protocols[ 0].name        = "???";  // we don't and can't know it

   pair = _mulle_objc_infraclass_get_classpair( cls);
   mulle_objc_classpair_add_protocollist_nofail( pair, protolist);
   return( YES);
}

/***********************************************************************
* class_copyMethodList.  Returns a heap block containing the
* methods implemented by the class, or nil if the class
* implements no methods. Caller must free the block.
* Does not copy any superclass's methods.
**********************************************************************/
struct method_copy_ctxt
{
   Method   *p;
   Method   *sentinel;
};


static mulle_objc_walkcommand_t
   count_method( struct _mulle_objc_method *method,
                 struct _mulle_objc_methodlist *list,
                 struct _mulle_objc_class *cls,
                 void *info)
{
   unsigned int  *count = info;

   ++*count;
   return( mulle_objc_walk_ok);
}

static mulle_objc_walkcommand_t
   copy_method( struct _mulle_objc_method *method,
                struct _mulle_objc_methodlist *list,
                struct _mulle_objc_class *cls,
                void *info)
{
   struct method_copy_ctxt  *ctxt = info;

   if( ctxt->p >= ctxt->sentinel)
      return( mulle_objc_walk_done);
   *ctxt->p++ = method;
   return( mulle_objc_walk_ok);
}


Method   *class_copyMethodList( Class cls, unsigned int *outCount)
{
   Method                    *result;
   Method                    *p;
   unsigned int              count;
   struct method_copy_ctxt   ctxt;

   if( ! cls)
   {
      if( outCount)
         *outCount = 0;
      return( NULL);
   }

   count = 0;
   _mulle_objc_class_walk_methods( (struct _mulle_objc_class *) cls,
                                   MULLE_OBJC_CLASS_DONT_INHERIT_SUPERCLASS,
                                   count_method,
                                   &count);
   result = NULL;
   if( count)
   {
      result = (Method *) mulle_allocator_malloc( &mulle_stdlib_allocator,
                                                (count + 1) * sizeof( Method));
      ctxt.p         = result;
      ctxt.sentinel  = &result[ count];
      result[ count] = 0;

      _mulle_objc_class_walk_methods( (struct _mulle_objc_class *) cls,
                                      MULLE_OBJC_CLASS_DONT_INHERIT_SUPERCLASS,
                                      copy_method,
                                      &ctxt);
   }

   if( outCount)
      *outCount = count;
   return( result);
}

/***********************************************************************
* class_copyIvarList.  Returns a heap block containing the
* ivars declared in the class, or nil if the class
* declares no ivars. Caller must free the block.
* Does not copy any superclass's ivars.
**********************************************************************/
struct ivar_copy_ctxt
{
   Ivar   *p;
   Ivar   *sentinel;
};

static mulle_objc_walkcommand_t
   count_ivar( struct _mulle_objc_ivar *ivar,
               struct _mulle_objc_infraclass *cls,
               void *info)
{
   unsigned int  *count = info;

   ++*count;
   return( mulle_objc_walk_ok);
}


static mulle_objc_walkcommand_t
   copy_ivar( struct _mulle_objc_ivar *ivar,
              struct _mulle_objc_infraclass *cls,
              void *info)
{
   struct ivar_copy_ctxt  *ctxt = info;

   if( ctxt->p >= ctxt->sentinel)
      return( mulle_objc_walk_done);
   *ctxt->p++ = ivar;
   return( mulle_objc_walk_ok);
}


static int   compare_ivar_by_offset( const void *a, const void *b)
{
   Ivar  aIvar = *(Ivar *) a;
   Ivar  bIvar = *(Ivar *) b;

   return( aIvar->offset - bIvar->offset);
}

Ivar   *class_copyIvarList( Class cls, unsigned int *outCount)
{
   Ivar                    *result;
   Ivar                    *p;
   unsigned int            count;
   struct ivar_copy_ctxt   ctxt;

   if( ! cls || _mulle_objc_class_is_metaclass( (struct _mulle_objc_class *) cls))
   {
      if( outCount)
         *outCount = 0;
      return( NULL);
   }

   count = 0;
   _mulle_objc_infraclass_walk_ivars( cls,
                                      MULLE_OBJC_CLASS_DONT_INHERIT_SUPERCLASS,
                                      count_ivar,
                                      &count);
   result = NULL;
   if( count)
   {
      result = (Ivar *) mulle_allocator_malloc( &mulle_stdlib_allocator,
                                                (count + 1) * sizeof( Ivar));
      ctxt.p         = result;
      ctxt.sentinel  = &result[ count];
      result[ count] = 0;

      _mulle_objc_infraclass_walk_ivars( cls,
                                         MULLE_OBJC_CLASS_DONT_INHERIT_SUPERCLASS,
                                         copy_ivar,
                                         &ctxt);

      qsort( result, count, sizeof( Ivar), compare_ivar_by_offset);
   }

   if( outCount)
      *outCount = count;
   return( result);
}


/***********************************************************************
* class_copyPropertyList. Returns a heap block containing the
* properties declared in the class, or nil if the class
* declares no properties. Caller must free the block.
* Does not copy any superclass's properties.
**********************************************************************/
struct property_copy_ctxt
{
   objc_property_t   *p;
   objc_property_t   *sentinel;
};

static mulle_objc_walkcommand_t
   count_property( struct _mulle_objc_property *property,
                   struct _mulle_objc_infraclass *cls,
                   void *info)
{
   unsigned int  *count = info;

   ++*count;
   return( mulle_objc_walk_ok);
}


static mulle_objc_walkcommand_t
   copy_property( struct _mulle_objc_property *property,
                  struct _mulle_objc_infraclass *cls,
                  void *info)
{
   struct property_copy_ctxt  *ctxt = info;

   if( ctxt->p >= ctxt->sentinel)
      return( mulle_objc_walk_done);
   *ctxt->p++ = property;
   return( mulle_objc_walk_ok);
}


objc_property_t   *class_copyPropertyList( Class cls, unsigned int *outCount)
{
   objc_property_t            *result;
   objc_property_t            *p;
   unsigned int                count;
   struct property_copy_ctxt   ctxt;

   if( ! cls || _mulle_objc_class_is_metaclass( (struct _mulle_objc_class *) cls))
   {
      if( outCount)
         *outCount = 0;
      return( NULL);
   }

   count = 0;
   _mulle_objc_infraclass_walk_properties( cls,
                                           MULLE_OBJC_CLASS_DONT_INHERIT_SUPERCLASS,
                                           count_property,
                                           &count);
   result = NULL;
   if( count)
   {
      result = (objc_property_t *) mulle_allocator_malloc( &mulle_stdlib_allocator,
                                                (count + 1) * sizeof( objc_property_t *));
      ctxt.p         = result;
      ctxt.sentinel  = &result[ count];
      result[ count] = 0;

      _mulle_objc_infraclass_walk_properties( cls,
                                              MULLE_OBJC_CLASS_DONT_INHERIT_SUPERCLASS,
                                              copy_property,
                                              &ctxt);
   }

   if( outCount)
      *outCount = count;
   return( result);
}


/***********************************************************************
* class_copyProtocolList.  Returns a heap block containing the
* protocols implemented by the class, or nil if the class
* implements no protocols. Caller must free the block.
* Does not copy any superclass's protocols.
**********************************************************************/
struct protocol_copy_ctxt
{
   PROTOCOL   *p;
   PROTOCOL   *sentinel;
};

static mulle_objc_walkcommand_t
   count_protocol( mulle_objc_protocolid_t proto,
                   struct _mulle_objc_classpair *pair,
                   void *info)
{
   unsigned int  *count = info;

   ++*count;
   return( mulle_objc_walk_ok);
}


static mulle_objc_walkcommand_t
   copy_protocol( mulle_objc_protocolid_t proto,
                  struct _mulle_objc_classpair *pair,
                  void *info)
{
   struct protocol_copy_ctxt  *ctxt = info;

   if( ctxt->p >= ctxt->sentinel)
      return( mulle_objc_walk_done);
   *ctxt->p++ = proto;
   return( mulle_objc_walk_ok);
}


PROTOCOL   *class_copyProtocolList( Class cls, unsigned int *outCount)
{
   PROTOCOL                       *result;
   PROTOCOL                       *p;
   unsigned int                   count;
   struct protocol_copy_ctxt      ctxt;
   struct _mulle_objc_classpair   *pair;

   if( ! cls)
   {
      if( outCount)
         *outCount = 0;
      return( NULL);
   }

   pair  = _mulle_objc_class_get_classpair( (struct _mulle_objc_class *) cls);
   count = 0;
   _mulle_objc_classpair_walk_protocolids( pair,
                                           MULLE_OBJC_CLASS_DONT_INHERIT_SUPERCLASS,
                                           count_protocol,
                                           &count);
   result = NULL;
   if( count)
   {
      result = (PROTOCOL *) mulle_allocator_malloc( &mulle_stdlib_allocator,
                                                    (count + 1) * sizeof( PROTOCOL));
      ctxt.p         = result;
      ctxt.sentinel  = &result[ count];
      result[ count] = 0;

      _mulle_objc_classpair_walk_protocolids( pair,
                                              MULLE_OBJC_CLASS_DONT_INHERIT_SUPERCLASS,
                                              copy_protocol,
                                              &ctxt);
   }

   if( outCount)
      *outCount = count;
   return( result);
}


/***********************************************************************
* class_getProperty.  Return the named property.
**********************************************************************/
objc_property_t class_getProperty(Class cls, char *name)
{
   mulle_objc_propertyid_t  propertyid;

   if( ! cls || ! name || _mulle_objc_class_is_metaclass( (struct _mulle_objc_class *) cls))
      return( NULL);

   propertyid = mulle_objc_propertyid_from_string( name);
   return( _mulle_objc_infraclass_search_property( cls, propertyid));
}


IMP  class_getMethodImplementation( Class aClass, SEL sel)
{
   IMP                        imp;
   struct _mulle_objc_class   *cls;

   if( ! aClass || ! sel)
      return( (IMP) 0);

   cls = (struct _mulle_objc_class *) aClass;

   // this apparently needs to run always
   // maybe because the initializer might setup more methods

   if( ! _mulle_objc_class_get_state_bit( cls, MULLE_OBJC_CLASS_INITIALIZE_DONE))
      _mulle_objc_class_setup( cls);

   // this should cache and resolve
   imp = (IMP) _mulle_objc_class_lookup_implementation( cls,
                                                       (mulle_objc_methodid_t) sel);
   return( imp);
}

