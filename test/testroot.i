// testroot.i
// Implementation of class TestRoot
// Include this file into your main test file to use it.

#include "test.h"

#include <mulle-thread/mulle-thread.h>


mulle_atomic_pointer_t TestRootLoad;
mulle_atomic_pointer_t TestRootInitialize;
mulle_atomic_pointer_t TestRootAlloc;
mulle_atomic_pointer_t TestRootAllocWithZone;
mulle_atomic_pointer_t TestRootCopy;
mulle_atomic_pointer_t TestRootCopyWithZone;
mulle_atomic_pointer_t TestRootMutableCopy;
mulle_atomic_pointer_t TestRootMutableCopyWithZone;
mulle_atomic_pointer_t TestRootInit;
mulle_atomic_pointer_t TestRootDealloc;
mulle_atomic_pointer_t TestRootFinalize;
mulle_atomic_pointer_t TestRootRetain;
mulle_atomic_pointer_t TestRootRelease;
mulle_atomic_pointer_t TestRootAutorelease;
mulle_atomic_pointer_t TestRootRetainCount;
mulle_atomic_pointer_t TestRootTryRetain;
mulle_atomic_pointer_t TestRootIsDeallocating;
mulle_atomic_pointer_t TestRootPlusRetain;
mulle_atomic_pointer_t TestRootPlusRelease;
mulle_atomic_pointer_t TestRootPlusAutorelease;
mulle_atomic_pointer_t TestRootPlusRetainCount;


@implementation TestRoot

// These all use void* pending rdar://9310005.

static void *
retain_fn(void *self, SEL _cmd __unused) {
    _mulle_atomic_pointer_increment(&TestRootRetain);

    _mulle_objc_object_retain_inline(self);
    return( self);
}

static void
release_fn(void *self, SEL _cmd __unused) {
    _mulle_atomic_pointer_increment(&TestRootRelease);

    _mulle_objc_object_release_inline(self);
}

static void *
autorelease_fn(void *self, SEL _cmd __unused) {
    _mulle_atomic_pointer_increment(&TestRootAutorelease);
    return(self);
}

static unsigned long
retaincount_fn(void *self, SEL _cmd __unused) {
    _mulle_atomic_pointer_increment(&TestRootRetainCount);
    return( (unsigned long) mulle_objc_object_get_retaincount( self));
}

static void *
copywithzone_fn(void *self, SEL _cmd __unused, void *zone) {
    size_t                           size;
    struct _mulle_objc_class        *cls;
    struct _mulle_objc_infraclass   *infra;

    _mulle_atomic_pointer_increment(&TestRootCopyWithZone);
    cls   = _mulle_objc_object_get_isa( self);
    infra = _mulle_objc_class_as_infraclass( cls);
    size  = _mulle_objc_infraclass_get_instancesize( infra);
    return object_copy(self, size);
}

static void *
plusretain_fn(void *self __unused, SEL _cmd __unused) {
    _mulle_atomic_pointer_increment(&TestRootPlusRetain);
    return self;
}

static void
plusrelease_fn(void *self __unused, SEL _cmd __unused) {
    _mulle_atomic_pointer_increment(&TestRootPlusRelease);
}

static void *
plusautorelease_fn(void *self, SEL _cmd __unused) {
    _mulle_atomic_pointer_increment(&TestRootPlusAutorelease);
    return self;
}

static unsigned long
plusretaincount_fn(void *self __unused, SEL _cmd __unused) {
    _mulle_atomic_pointer_increment(&TestRootPlusRetainCount);
    return ULONG_MAX;
}

+(void) load {
    _mulle_atomic_pointer_increment(&TestRootLoad);

    // install methods that ARR refuses to compile
    class_addMethod(self, sel_registerName("retain"), (IMP)retain_fn, "");
    class_addMethod(self, sel_registerName("release"), (IMP)release_fn, "");
    class_addMethod(self, sel_registerName("autorelease"), (IMP)autorelease_fn, "");
    class_addMethod(self, sel_registerName("retainCount"), (IMP)retaincount_fn, "");
    class_addMethod(self, sel_registerName("copyWithZone:"), (IMP)copywithzone_fn, "");

    class_addMethod(object_getClass(self), sel_registerName("retain"), (IMP)plusretain_fn, "");
    class_addMethod(object_getClass(self), sel_registerName("release"), (IMP)plusrelease_fn, "");
    class_addMethod(object_getClass(self), sel_registerName("autorelease"), (IMP)plusautorelease_fn, "");
    class_addMethod(object_getClass(self), sel_registerName("retainCount"), (IMP)plusretaincount_fn, "");
}


+(void) initialize {
    _mulle_atomic_pointer_increment(&TestRootInitialize);
}

-(id) self {
    return self;
}

+(Class) class {
    return self;
}

-(Class) class {
    return object_getClass(self);
}

+(Class) superclass {
    return class_getSuperclass(self);
}

-(Class) superclass {
    return class_getSuperclass([self class]);
}

+(id) new {
    return [[self alloc] init];
}

+(id) alloc {
    _mulle_atomic_pointer_increment(&TestRootAlloc);
    return( (id) _mulle_objc_infraclass_alloc_instance( self));
}

+(id) allocWithZone:(void *)zone {
    _mulle_atomic_pointer_increment(&TestRootAllocWithZone);
    return( (id) _mulle_objc_infraclass_alloc_instance( self));
}

+(id) copy {
    return self;
}

+(id) copyWithZone:(void *) __unused zone {
    return self;
}

-(id) copy {
    _mulle_atomic_pointer_increment(&TestRootCopy);
    return [self copyWithZone:NULL];
}

+(id) mutableCopyWithZone:(void *) __unused zone {
    fail("+mutableCopyWithZone: called");
}

-(id) mutableCopy {
    _mulle_atomic_pointer_increment(&TestRootMutableCopy);
    return [self mutableCopyWithZone:NULL];
}

-(id) mutableCopyWithZone:(void *) __unused zone {
    _mulle_atomic_pointer_increment(&TestRootMutableCopyWithZone);
    return( (id) _mulle_objc_infraclass_alloc_instance( object_getClass(self)));
}

-(id) init {
    _mulle_atomic_pointer_increment(&TestRootInit);
    return( self);
}

+(void) dealloc {
    fail("+dealloc called");
}

-(void) dealloc {
    _mulle_atomic_pointer_increment(&TestRootDealloc);
    _mulle_objc_instance_free( ( struct _mulle_objc_object *) self);
}

+(void) finalize {
    fail("+finalize called");
}

-(void) finalize {
    _mulle_atomic_pointer_increment(&TestRootFinalize);
}

+(BOOL) _tryRetain {
    return YES;
}

-(BOOL) _tryRetain {
    _mulle_atomic_pointer_increment(&TestRootTryRetain);
    _mulle_objc_object_increment_retaincount(self);
    return( YES);
}

+(BOOL) _isDeallocating {
    return NO;
}

-(BOOL) _isDeallocating {
    _mulle_atomic_pointer_increment(&TestRootIsDeallocating);
    return( NO);
}

-(BOOL) allowsWeakReference {
    return ! [self _isDeallocating];
}

-(BOOL) retainWeakReference {
    return [self _tryRetain];
}


@end
