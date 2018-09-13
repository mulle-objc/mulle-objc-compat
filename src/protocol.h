#ifndef objc_mullecompat_protocol__h__
#define objc_mullecompat_protocol__h__

#include "include.h"

#include "method.h"
#include "property.h"


typedef struct _mulle_objc_protocol   Protocol;


/*
 * PROTOCOL
 * There exists a runtime mulle protocol struct, but it's not the same as PROTOCOL 
 * which is a unique ID. That means, that a protocol will be created and registered
 * as a Protocol *, but referenced only as PROTOCOL.
 */


//
// once registered the "Protocol" will not be retrievable from the runtime
// with objc_.. functions. All Method/Property functions are just placebos.
// Any of the protocol query functions except name are placebos.
// Query the class for protocol conformance.
//

/* protocol struct support (initialization only), this is not the same
   as @protocol() which is PROTOCOL which is a hash value
 */
Protocol *objc_getProtocol( char *name);

Protocol *objc_allocateProtocol( char *name);
void objc_registerProtocol( Protocol *proto);
void protocol_addMethodDescription( Protocol *proto, 
                                    SEL name, 
                                    char *types, 
                                    BOOL isRequiredMethod, 
                                    BOOL isInstanceMethod);
void protocol_addProtocol( Protocol *proto, PROTOCOL addition);
void protocol_addProperty( Protocol *proto, 
                           char *name, 
                           objc_property_attribute_t *attributes, 
                           unsigned int attributeCount, 
                           BOOL isRequiredProperty, 
                           BOOL isInstanceProperty);

static inline BOOL   protocol_conformsToProtocol( Protocol *proto, 
                                                  PROTOCOL other)
{
   if( ! proto)
      return( NO);
   return( _mulle_objc_protocol_get_protocolid( proto) == other);
}

static inline char *protocol_getName( Protocol *proto)
{
   if( ! proto)
      return( NULL);
   return( _mulle_objc_protocol_get_name( proto));
}

//
// none of this is really supported as protocol in mulle-objc are
// mostly just syntax constructs. The only tangible data left at
// runtime is the name and the selector
//
struct objc_method_description *
   protocol_copyMethodDescriptionList( Protocol *proto, 
                                       BOOL isRequiredMethod, 
                                       BOOL isInstanceMethod, 
                                       unsigned int *outCount);
struct objc_method_description 
    protocol_getMethodDescription( Protocol *proto, 
                                   SEL aSel, 
                                   BOOL isRequiredMethod, 
                                   BOOL isInstanceMethod);
objc_property_t *protocol_copyPropertyList( Protocol *proto, 
                                            unsigned int *outCount);
objc_property_t  protocol_getProperty( Protocol *proto, 
                                       char *name, 
                                       BOOL isRequiredProperty, 
                                       BOOL isInstanceProperty);

PROTOCOL *protocol_copyProtocolList( Protocol *proto, 
                                     unsigned int *outCount);

Protocol **objc_copyProtocolList(unsigned int *outCount);


static inline BOOL protocol_isEqual( Protocol *proto, Protocol *other)
{
   return( proto == other);
}



#endif