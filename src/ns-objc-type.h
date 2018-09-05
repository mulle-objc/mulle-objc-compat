#ifndef ns_type__h__
#define ns_type__h__

//#include "ns-objc_include.h"

//
// allow isa with cpp define
// The cast is not really type correct, as isa can be the metaclass
//
#ifdef MULLE_OBJC_ISA_HACK
# define isa   ((Class) _mulle_objc_object_get_isa( self))
#endif

//
// this should be C readable
// these are here in the header, but they are actually defined by the
// compiler. So you can't really change them.
//
// --- compiler defined begin ---
typedef void                            *id;
typedef struct _mulle_objc_infraclass   *Class;  // the meta-class is not "visible" to Class users

//
// "Protocol" as a valid keyword and a pseudo-class does not exist
// @protocol( Foo) returns a mulle_objc_protocolid_t, which is an "uint32_t"
// For other compilers say   `typedef Protocol   *PROTOCOL`
// and code will work on both sides.
//
typedef mulle_objc_methodid_t       SEL;
typedef mulle_objc_protocolid_t     PROTOCOL;
typedef struct _mulle_objc_method   *Method;
typedef struct _mulle_objc_ivar     *Ivar;
typedef id                          (*IMP)( id, SEL, void *);
typedef char                        BOOL;

// --- compiler defined end ---

// turn off this warning, because it's wrong for us
#pragma clang diagnostic ignored "-Wcast-of-sel-type"


//
// in AAM define some harmless syntax sugar, so more stuff compiles
//
#ifdef __OBJC_AAM__
# define __bridge
# define __unsafe_unretained
#endif


#define nil   ((id) 0)
#define Nil   ((Class) 0)

enum
{
   _NS_INFRA_IS_CLASSCLUSTER = (MULLE_OBJC_CLASS_FOUNDATION_BIT0 << 0),
   _NS_INFRA_IS_SINGLETON    = (MULLE_OBJC_CLASS_FOUNDATION_BIT0 << 1)
};

#ifndef YES
# define YES   1
# define NO    0
#endif

#endif