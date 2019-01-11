// test.h
// Common definitions for trivial test harness


#ifndef TEST_H
#define TEST_H

#define _GNU_SOURCE
#include <stdio.h>
#include <dlfcn.h> // questionable
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <libgen.h>
#include <unistd.h>
#include <pthread.h>
#include <sys/param.h>

#include <mulle-objc-runtime/mulle-objc-runtime.h>
#include <MulleObjC/mulle-objc.h>
#include <objc/objc-runtime.h>


#define OBJC_ROOT_CLASS
#define OBJC_INLINE inline
#ifndef __unused
# define __unused
#endif


static OBJC_INLINE void *objc_collectableZone(void) { return nil; }


// Configuration macros

#if !__LP64__ || TARGET_OS_WIN32 || __OBJC_GC__ || TARGET_IPHONE_SIMULATOR
#   define SUPPORT_NONPOINTER_ISA 0
#elif __x86_64__
#   define SUPPORT_NONPOINTER_ISA 1
#elif __arm64__
#   define SUPPORT_NONPOINTER_ISA 1
#else
#   error unknown architecture
#endif


// Test output

static inline void succeed(const char *name)  __attribute__((noreturn));
static inline void succeed(const char *name)
{
    if (name) {
        char path[MAXPATHLEN+1];
        strcpy(path, name);
        fprintf(stderr, "OK: %s\n", basename(path));
    } else {
        fprintf(stderr, "OK\n");
    }
    exit(0);
}

static inline void fail(const char *msg, ...)   __attribute__((noreturn));
static inline void fail(const char *msg, ...)
{
    if (msg) {
        char *msg2;
        asprintf(&msg2, "BAD: %s\n", msg);
        va_list v;
        va_start(v, msg);
        vfprintf(stderr, msg2, v);
        va_end(v);
        free(msg2);
    } else {
        fprintf(stderr, "BAD\n");
    }
    exit(1);
}

#define testassert(cond) \
    ((void) (((cond) != 0) ? (void)0 : __testassert(#cond, __FILE__, __LINE__)))
#define __testassert(cond, file, line) \
    (fail("failed assertion '%s' at %s:%u", cond, __FILE__, __LINE__))

/* time-sensitive assertion, disabled under valgrind */
#define timecheck(name, time, fast, slow)                                    \
    if (getenv("VALGRIND") && 0 != strcmp(getenv("VALGRIND"), "NO")) {  \
        /* valgrind; do nothing */                                      \
    } else if (time > slow) {                                           \
        fprintf(stderr, "SLOW: %s %llu, expected %llu..%llu\n",         \
                name, (uint64_t)(time), (uint64_t)(fast), (uint64_t)(slow)); \
    } else if (time < fast) {                                           \
        fprintf(stderr, "FAST: %s %llu, expected %llu..%llu\n",         \
                name, (uint64_t)(time), (uint64_t)(fast), (uint64_t)(slow)); \
    } else {                                                            \
        testprintf("time: %s %llu, expected %llu..%llu\n",              \
                   name, (uint64_t)(time), (uint64_t)(fast), (uint64_t)(slow)); \
    }


static inline void testprintf(const char *msg, ...)
{
    static int verbose = -1;
    if (verbose < 0) verbose = atoi(getenv("VERBOSE") ?: "0");

    // VERBOSE=1 prints test harness info only
    if (msg  &&  verbose >= 2) {
        char *msg2;
        asprintf(&msg2, "VERBOSE: %s", msg);
        va_list v;
        va_start(v, msg);
        vfprintf(stderr, msg2, v);
        va_end(v);
        free(msg2);
    }
}

// complain to output, but don't fail the test
// Use when warning that some test is being temporarily skipped
// because of something like a compiler bug.
static inline void testwarn(const char *msg, ...)
{
    if (msg) {
        char *msg2;
        asprintf(&msg2, "WARN: %s\n", msg);
        va_list v;
        va_start(v, msg);
        vfprintf(stderr, msg2, v);
        va_end(v);
        free(msg2);
    }
}

static inline void testnoop() { }

#define testexc()
#define testcollect()


// Synchronously run test code on another thread.
// This can help force GC to kill objects promptly, which some tests depend on.

// The block object is unsafe_unretained because we must not allow
// ARC to retain them in non-Foundation tests
static void (*testcodehack)( void);
static inline void *_testthread(void *arg __unused)
{
    //objc_registerThreadWithCollector();
    testcodehack();
    return NULL;
}
static inline void testonthread( void (*code) (void))
{
    pthread_t th;
    testcodehack = code;  // force GC not-thread-local, avoid ARC void* casts
    pthread_create(&th, NULL, _testthread, NULL);
    pthread_join(th, NULL);
}


static inline BOOL is_guardmalloc(void)
{
    const char *env = getenv("GUARDMALLOC");
    return (env  &&  0 == strcmp(env, "YES"));
}


/* Memory management compatibility macros */

static id self_fn(id x) __attribute__((used));
static id self_fn(id x) { return x; }

#if __has_feature(objc_arc)
    // ARC
#   define RELEASE_VAR(x)            x = nil
#   define WEAK_STORE(dst, val)      (dst = (val))
#   define WEAK_LOAD(src)            (src)
#   define SUPER_DEALLOC()
#   define RETAIN(x)                 (self_fn(x))
#   define RELEASE_VALUE(x)          ((void)self_fn(x))
#   define AUTORELEASE(x)            (self_fn(x))

#elif defined(__OBJC_GC__)
    // GC
#   define RELEASE_VAR(x)            x = nil
#   define WEAK_STORE(dst, val)      (dst = (val))
#   define WEAK_LOAD(src)            (src)
#   define SUPER_DEALLOC()           [super dealloc]
#   define RETAIN(x)                 [x self]
#   define RELEASE_VALUE(x)          (void)[x self]
#   define AUTORELEASE(x)            [x self]

#else
    // MRC
#   define RELEASE_VAR(x)            do { [x release]; x = nil; } while (0)
#   define WEAK_STORE(dst, val)      objc_storeWeak((id *)&dst, val)
#   define WEAK_LOAD(src)            objc_loadWeak((id *)&src)
#   define SUPER_DEALLOC()           [super dealloc]
#   define RETAIN(x)                 [x retain]
#   define RELEASE_VALUE(x)          [x release]
#   define AUTORELEASE(x)            [x autorelease]
#endif

/* gcc compatibility macros */
/* <rdar://problem/9412038> @autoreleasepool should generate objc_autoreleasePoolPush/Pop on 10.7/5.0 */
//#if !defined(__clang__)
#   define PUSH_POOL { void *pool = objc_autoreleasePoolPush();
#   define POP_POOL objc_autoreleasePoolPop(pool); }
//#else
//#   define PUSH_POOL @autoreleasepool
//#   define POP_POOL
//#endif

#if __OBJC__

/* General purpose root class */

OBJC_ROOT_CLASS
@interface TestRoot {
// @public
//    Class isa;  // not in mulle-objc
}

+(void) load;
+(void) initialize;

-(id) self;
-(Class) class;
-(Class) superclass;

+(id) new;
+(id) alloc;
+(id) allocWithZone:(void*)zone;
-(id) copy;
-(id) mutableCopy;
-(id) init;
-(void) dealloc;
-(void) finalize;
@end
@interface TestRoot (RR)
-(id) retain;
-(oneway void) release;
-(id) autorelease;
-(unsigned long) retainCount;
-(id) copyWithZone:(void *)zone;
-(id) mutableCopyWithZone:(void*)zone;
@end

// incremented for each call of TestRoot's methods
extern mulle_atomic_pointer_t TestRootLoad;
extern mulle_atomic_pointer_t TestRootInitialize;
extern mulle_atomic_pointer_t TestRootAlloc;
extern mulle_atomic_pointer_t TestRootAllocWithZone;
extern mulle_atomic_pointer_t TestRootCopy;
extern mulle_atomic_pointer_t TestRootCopyWithZone;
extern mulle_atomic_pointer_t TestRootMutableCopy;
extern mulle_atomic_pointer_t TestRootMutableCopyWithZone;
extern mulle_atomic_pointer_t TestRootInit;
extern mulle_atomic_pointer_t TestRootDealloc;
extern mulle_atomic_pointer_t TestRootFinalize;
extern mulle_atomic_pointer_t TestRootRetain;
extern mulle_atomic_pointer_t TestRootRelease;
extern mulle_atomic_pointer_t TestRootAutorelease;
extern mulle_atomic_pointer_t TestRootRetainCount;
extern mulle_atomic_pointer_t TestRootTryRetain;
extern mulle_atomic_pointer_t TestRootIsDeallocating;
extern mulle_atomic_pointer_t TestRootPlusRetain;
extern mulle_atomic_pointer_t TestRootPlusRelease;
extern mulle_atomic_pointer_t TestRootPlusAutorelease;
extern mulle_atomic_pointer_t TestRootPlusRetainCount;

#endif


// Struct that does not return in registers on any architecture

struct stret {
    int a;
    int b;
    int c;
    int d;
    int e;
    int f;
    int g;
    int h;
    int i;
    int j;
};

static inline BOOL stret_equal(struct stret a, struct stret b)
{
    return (a.a == b.a  &&
            a.b == b.b  &&
            a.c == b.c  &&
            a.d == b.d  &&
            a.e == b.e  &&
            a.f == b.f  &&
            a.g == b.g  &&
            a.h == b.h  &&
            a.i == b.i  &&
            a.j == b.j);
}

static struct stret STRET_RESULT __attribute__((used)) = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};

#endif
