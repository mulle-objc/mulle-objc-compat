#ifndef objc_mullecompat_protocol__h__
#define objc_mullecompat_protocol__h__

#include "include.h"

#include "method.h"
#include "property.h"


typedef struct _mulle_objc_protocol   *Protocol;


/*
 * PROTOCOL
 * There exists a runtime mulle protocol struct, but it's not the same as PROTOCOL 
 * which is a unique ID. That means, that a protocol will be created and registered
 * as a Protocol *, but referenced only as PROTOCOL.
 */

/* runtime protocol support */
PROTOCOL  objc_getProtocol( char *name);
PROTOCOL  *objc_copyProtocolList(unsigned int *outCount);
Protocol *objc_allocateProtocol(const char *name);
void objc_registerProtocol(Protocol *proto);


/* protocol struct support (initialization only) */

void protocol_addMethodDescription( Protocol *proto, SEL name, char *types, BOOL isRequiredMethod, BOOL isInstanceMethod);
void protocol_addProtocol( Protocol *proto, PROTOCOL addition);
void protocol_addProperty( Protocol *proto, char *name, const objc_property_attribute_t *attributes, unsigned int attributeCount, BOOL isRequiredProperty, BOOL isInstanceProperty);
char *protocol_getName( Protocol *proto);

/* PROTOCOL support */

BOOL protocol_isEqual( PROTOCOL proto, PROTOCOL other);
struct objc_method_description protocol_copyMethodDescriptionList( PROTOCOL proto, BOOL isRequiredMethod, BOOL isInstanceMethod, unsigned int *outCount);
struct objc_method_description protocol_getMethodDescription( PROTOCOL proto, SEL aSel, BOOL isRequiredMethod, BOOL isInstanceMethod);
objc_property_t *protocol_copyPropertyList( PROTOCOL proto, unsigned int *outCount);
objc_property_t  protocol_getProperty( PROTOCOL proto, char *name, BOOL isRequiredProperty, BOOL isInstanceProperty);
PROTOCOL *protocol_copyProtocolList( PROTOCOL proto, unsigned int *outCount);
BOOL   protocol_conformsToProtocol( PROTOCOL proto,  PROTOCOL other);

#endif