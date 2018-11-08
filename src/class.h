#ifndef objc_mullecompat_class__h__
#define objc_mullecompat_class__h__

#include "include.h"

#include "ivar.h"
#include "method.h"
#include "property.h"
#include "protocol.h"


typedef mulle_objc_categoryid_t  Category;

/*
 * pointer indirection fits tests better
 */
#define _objc_msgForward  *mulle_objc_method_get_implementation( mulle_objc_global_inlineget_universe( MULLE_OBJC_DEFAULTUNIVERSEID)->classdefaults.forwardmethod)
#define _objc_msgForward_stret   _objc_msgForward

/*
 * runtime class
 */

Class   objc_allocateClassPair( Class superclass, char *name, size_t extraBytes);
void   objc_registerClassPair (Class cls);
void   objc_disposeClassPair( Class cls);
Class   objc_duplicateClass( Class original, char *name, size_t extraBytes);

Class   objc_lookUpClass(char *name);

// have to be const char because they are builtin functions in clang
id   objc_getClass( const char *name);
id   objc_getMetaClass(const char *name);
Class   objc_getRequiredClass( char *name);


int   objc_getClassList( Class  *buffer, int bufferCount);
Class   *objc_copyClassList( unsigned int *outCount);



/*
 * @class
 */
static inline void   class_setVersion(Class cls, int version)
{
   if( cls)
      _mulle_objc_infraclass_set_coderversion( cls, version);
}

static inline int   class_getVersion(Class cls)
{
   return( cls ? _mulle_objc_infraclass_get_coderversion( cls) : 0);
}

PROTOCOL *  class_copyProtocolList(Class cls, unsigned int *outCount);

static inline BOOL   class_conformsToProtocol(Class cls, PROTOCOL protocol)
{
   struct _mulle_objc_classpair   *pair;

   pair = mulle_objc_class_get_classpair( (struct _mulle_objc_class *) cls);
   return( __mulle_objc_classpair_conformsto_protocolid( pair, MULLE_OBJC_CLASS_DONT_INHERIT_SUPERCLASS, protocol));
}

BOOL   class_addIvar(Class cls, char *name, size_t size, uint8_t alignment, char *types);
BOOL   class_addMethod(Class cls, SEL name, IMP imp, char *types);
BOOL   class_addProperty(Class cls, char *name, objc_property_attribute_t *attributes, unsigned int attributeCount);
BOOL   class_addProtocol(Class cls, PROTOCOL protocol);

static inline BOOL   class_isMetaClass( Class cls)
{
   return( mulle_objc_class_is_metaclass( (struct _mulle_objc_class *) cls));
}


static inline BOOL   class_respondsToSelector( Class cls, SEL sel)
{
   IMP   imp;

   imp = (IMP) _mulle_objc_class_lookup_implementation_noforward( (struct _mulle_objc_class *) cls,
                                                                   (mulle_objc_methodid_t) sel);
   return( imp ? YES : NO);
}


static inline Class   class_getSuperclass( Class cls)
{
   return( (Class) mulle_objc_class_get_superclass( (struct _mulle_objc_class *) cls));
}


Class   class_setSuperclass( Class cls, Class superclass);


static inline char *  class_getName( Class cls)
{
   char   *s;

   s = mulle_objc_class_get_name( (struct _mulle_objc_class *) cls);
   return( s ? s : "nil");
}

//
// this will be with header. You must use objc_constructInstance
// to get the id from a self created objected
//
static inline size_t   class_getInstanceSize( Class cls)
{
   return( mulle_objc_class_get_instancesize( (struct _mulle_objc_class *) cls));
}

// this calls initialize
IMP  class_getMethodImplementation( Class cls, SEL sel);

static inline IMP   class_getMethodImplementation_stret( Class cls, SEL sel)
{
   return( class_getMethodImplementation( cls, sel));
}

IMP class_replaceMethod( Class cls, SEL name, IMP imp, char *types);
Ivar  *class_copyIvarList( Class cls, unsigned int *outCount);
Ivar class_getClassVariable( Class cls, char *name);
Ivar class_getInstanceVariable( Class cls, char *name);
Method  *class_copyMethodList( Class cls, unsigned int *outCount);

static inline Method   class_getInstanceMethod( Class cls, SEL sel)
{
   if( ! cls || ! sel)
      return( (Method) 0);

   return( mulle_objc_class_defaultsearch_method( (struct _mulle_objc_class *) cls, sel));
}

//
// https://github.com/RetVal/objc-runtime/blob/1614b34b287a4a926ae6aa0c6e0e2e494c206599/runtime/objc-class.mm#L691
//
static inline Method   class_getClassMethod( Class cls, SEL sel)
{
   struct _mulle_objc_metaclass  *meta;

   if( ! cls || ! sel)
      return( (Method) 0);

   meta = _mulle_objc_class_get_metaclass( (struct _mulle_objc_class *) cls);
   return( mulle_objc_class_defaultsearch_method( _mulle_objc_metaclass_as_class( meta), sel));
}

objc_property_t *class_copyPropertyList( Class cls, unsigned int *outCount);
objc_property_t class_getProperty( Class cls, char *name);
void class_replaceProperty( Class cls, char *name, objc_property_attribute_t *attributes, unsigned int attributeCount);


/***********************************************************************
* class_getIvarLayout
* nil means all-scanned. "" means non-scanned.
**********************************************************************/
static inline uint8_t   *class_getIvarLayout(Class cls)
{
   return( NULL);
}


/***********************************************************************
* class_getWeakIvarLayout
* nil means no weak ivars.
**********************************************************************/
static inline uint8_t   *class_getWeakIvarLayout(Class cls)
{
   return( NULL);  // no weak ivars
}

#endif