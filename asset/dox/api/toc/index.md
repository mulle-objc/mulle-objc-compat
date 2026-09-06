# mulle-objc-compat Library Documentation for AI
<!-- Keywords: compatibility, runtime, selector, class, objc, porting, apple -->

## 1. Introduction & Purpose

**mulle-objc-compat** is a thin compatibility layer that maps Apple Objective-C
runtime functions (from `<objc/runtime.h>`, `<objc/message.h>`, etc.) onto their
`mulle-objc` counterparts. Its purpose is to ease porting of programs that use
Apple's Objective-C runtime C API to mulle-objc. It deliberately:

- does not include any runtime other than `mulle-objc-runtime`
- does not define any functionality that is not part of the Apple runtime
- does not implement everything that is in the Apple runtime

Key high-level features:

- Apple-named function/type/macro surface (`Class`, `id`, `SEL`, `Method`,
  `Ivar`, `objc_property_t`, `object_getClass`, `class_copyMethodList`, ...)
- Most entries are `static inline` wrappers delegating directly to the
  `mulle-objc-runtime`
- Drop-in include layout: `#include <objc/runtime.h>`, `#include <objc/message.h>`,
  `#include <objc/Protocol.h>` etc. resolve to shim headers under `src/objc/`
- Version macro `MULLE_OBJC_COMPAT_VERSION` (see `mulle-objc-compat.h`)

It is the porting bridge used by codebases written against
[Apple's Objective-C runtime](https://developer.apple.com/documentation/objectivec/objective_c_runtime).

## 2. Key Concepts & Design Philosophy

- **Mapping, not reimplementation**: Public headers declare Apple-identical
  symbols but implement them as thin wrappers over
  `_mulle_objc_*` / `mulle_objc_*` runtime calls. Example
  (`object_getClass`): `return((Class) mulle_objc_object_get_isa(obj))`.
- **Inline where possible**: Accessors and simple state queries are
  `static inline`; heavier operations (`objc_allocateClassPair`,
  `class_copyMethodList`, `sel_registerName`, ...) are compiled in
  `mulle-objc-compat.m` / `selector.m` / `protocol.m` etc. and exported with
  `MULLE_OBJC_COMPAT_GLOBAL`.
- **Type fidelity**: The `objc/` *runtime* types from the mulle-objc runtime are
  reused (`Class`, `id`, `SEL`, `Method`, `Ivar`, `IMP`, `Protocol`).
  `Protocol` is `typedef struct _mulle_objc_protocol Protocol;` but is referenced
  as `PROTOCOL` (a unique hash ID of type `mulle_objc_protocolid_t`); a protocol
  is created/registered as a `Protocol *` but queried as a `PROTOCOL`.
- **Placebo semantics documented**: e.g. protocol query functions other than
  `protocol_getName` are placebos in mulle-objc — query the *class* for protocol
  conformance instead. `class_getIvarLayout` / `class_getWeakIvarLayout` always
  return `NULL` (no weak ivars in mulle-objc). `objc_collectingEnabled()` /
  `objc_collecting_enabled()` always return `NO`.
- **Single runtime**: only `mulle-objc-runtime` is used, and only the
  `MulleObjC` root-class collection is required on top.

## 3. Core API & Data Structures

The public API is organized by header. All signatures below are copied verbatim
from the headers under `src/`.

### 3.1. `mulle-objc-compat.h` (umbrella header)

- `#define MULLE_OBJC_COMPAT_VERSION ((0UL << 20) | (21 << 8) | 6)` — version
  `0.21.6`, layout `(major << 20) | (minor << 8) | patch`.
- Includes, in order: `runtime.h`, `method.h`, `ivar.h`, `class.h`, `object.h`,
  `property.h`, `protocol.h`, `selector.h`.
- Requires `mulle-objc-runtime` >= `0.16.0` (compile-time `#error` otherwise).

### 3.2. `runtime.h` — runtime-level glue

- **macros**: `OBJC_API_VERSION 2`, `OBJC_ROOT_CLASS`, `OBJC_ARC_UNAVAILABLE`,
  `OBJC_GC_UNAVAILABLE`, `OBJC_SWIFT_UNAVAILABLE(ignore)`,
  `OBJC_AVAILABLE(a,b,c,d,e)`, `OBJC_DEPRECATED(ignore)`, `OBJC_EXTERN`,
  `OBJC_IMPORT`, `OBJC_INLINE`, `OBJC_VISIBLE`. `OBJC_HAVE_TAGGED_POINTERS` is
  defined when `__MULLE_OBJC_TPS__` is set (tagged-pointer support).
- `static inline BOOL objc_collectingEnabled(void)` — always `NO`.
- `static inline BOOL objc_collecting_enabled(void)` — always `NO`.
- `MULLE_OBJC_COMPAT_GLOBAL void _objc_registerTaggedPointerClass(unsigned int index, Class cls)` —
  register a tagged-pointer class by index.
- `MULLE_OBJC_COMPAT_GLOBAL void objc_setForwardHandler(void *fwd, void *fwd_stret)` —
  install a message-forwarding handler. The `stret` parameter is ignored; this
  overrides forwarding in all present and future classes.

### 3.3. `class.h` — classes, metaclasses, and class morphing

Types:
- `typedef mulle_objc_categoryid_t Category;`
- Moniker macros: `_objc_msgForward` and `_objc_msgForward_stret` (the latter
  aliases the former).

Class acquisition:
- `Class objc_allocateClassPair(Class superclass, char *name, size_t extraBytes)` —
  allocate an unregistered class pair (must finish setup, then register).
- `void objc_registerClassPair(Class cls)` — make the pair visible to the runtime.
- `void objc_disposeClassPair(Class cls)` — unregister + dispose a class pair.
- `Class objc_duplicateClass(Class original, char *name, size_t extraBytes)`
- `Class objc_lookUpClass(char *name)` — lookup without lazy loading.
- `id objc_getClass(const char *name)` — lookup, triggers lazy loading/callback.
- `id objc_getMetaClass(const char *name)`
- `Class objc_getRequiredClass(char *name)` — aborts if the class is missing.
- `int objc_getClassList(Class *buffer, int bufferCount)` — fill `buffer` with up
  to `bufferCount` classes; returns the total number, or the required size if
  `buffer` is `NULL`.
- `Class *objc_copyClassList(unsigned int *outCount)` — malloc'ed array
  (class list).

Class introspection:
- `BOOL class_isMetaClass(Class cls)`
- `Class class_getSuperclass(Class cls)`
- `Class class_setSuperclass(Class cls, Class superclass)`
- `char *class_getName(Class cls)` — returns `"nil"` for a `nil` class.
- `size_t class_getInstanceSize(Class cls)` — allocation size including header.
- `BOOL class_respondsToSelector(Class cls, SEL sel)`
- `void class_setVersion(Class cls, int version)` / `int class_getVersion(Class cls)` —
  coder-version.
- `uint8_t *class_getIvarLayout(Class cls)` — always `NULL` (all-scanned).
- `uint8_t *class_getWeakIvarLayout(Class cls)` — always `NULL` (no weak ivars).

Method introspection/mutation:
- `Method *class_copyMethodList(Class cls, unsigned int *outCount)` —
  malloc'ed, NULL-terminated array; returns `NULL`/`0` for `nil` class or no methods.
- `Method class_getInstanceMethod(Class cls, SEL sel)`
- `Method class_getClassMethod(Class cls, SEL sel)`
- `IMP class_getMethodImplementation(Class cls, SEL sel)` — calls `+initialize`.
- `IMP class_getMethodImplementation_stret(Class cls, SEL sel)`
- `BOOL class_addMethod(Class cls, SEL name, IMP imp, char *types)` — does not
  replace existing methods (incl. inherited).
- `IMP class_replaceMethod(Class cls, SEL name, IMP imp, char *types)` — replaces
  existing methods, adds new ones; returns the old `IMP` (or `NULL`).

Ivar introspection/mutation:
- `Ivar *class_copyIvarList(Class cls, unsigned int *outCount)`
- `Ivar class_getClassVariable(Class cls, char *name)`
- `Ivar class_getInstanceVariable(Class cls, char *name)`
- `BOOL class_addIvar(Class cls, char *name, size_t size, uint8_t alignment, char *types)` —
  only before `objc_registerClassPair`.

Property introspection/mutation:
- `objc_property_t *class_copyPropertyList(Class cls, unsigned int *outCount)`
- `objc_property_t class_getProperty(Class cls, char *name)`
- `BOOL class_addProperty(Class cls, char *name, objc_property_attribute_t *attributes, unsigned int attributeCount)`
- `void class_replaceProperty(Class cls, char *name, objc_property_attribute_t *attributes, unsigned int attributeCount)`

Protocol conformance:
- `BOOL class_addProtocol(Class cls, PROTOCOL protocol)`
- `PROTOCOL *class_copyProtocolList(Class cls, unsigned int *outCount)`
- `BOOL class_conformsToProtocol(Class cls, PROTOCOL protocol)`

### 3.4. `object.h` — object-level operations

Ownership / pointer bridging:
- `static inline id objc_retainedObject(void *pointer)` — nil-patchable +1.
- `static inline id objc_unretainedObject(void *pointer)` — convert to `id` without ownership transfer.
- `static inline void *objc_unretainedPointer(id object)` — convert to pointer, no ownership transfer.

Class of an object:
- `Class object_getClass(id obj)`
- `Class object_setClass(id obj, Class cls)` — **not atomic in mulle-objc**;
  returns the old class, `Nil` for `nil` obj.
- `char *object_getClassName(id obj)`

Instance creation/disposal:
- `id class_createInstance(Class cls, size_t extraBytes)` — allocates + inits a
  default object header.
- `id objc_constructInstance(Class cls, void *bytes)` — construct an object in
  caller-provided memory (`bytes`); init'ed, returns `nil` for `NULL` cls.
- `void *objc_destructInstance(id obj)` — no-op, returns `obj`.
- `id object_copy(id obj, size_t size)`
- `id object_dispose(id obj)` — destructs then frees the instance, returns `nil`.

Ivar access:
- `void object_setIvar(id obj, Ivar ivar, id value)`
- `id object_getIvar(id obj, Ivar ivar)`
- `void *object_getIndexedIvars(id obj)` — pointer to extra (indexed) ivar region.
- `Ivar object_getInstanceVariable(id obj, char *name, void **outValue)`
- `Ivar object_setInstanceVariable(id obj, char *name, void *value)`

Method implementation:
- `IMP object_getMethodImplementation(id obj, SEL sel)`
- `IMP object_getMethodImplementation_stret(id obj, SEL sel)`

GDB/debug helpers:
- `Class gdb_class_getClass(Class cls)` — like `objc_getClass(class_getName)` (triggers callback).
- `Class gdb_object_getClass(id obj)`

### 3.5. `selector.h` — selectors

- `static inline char *sel_getName(SEL sel)` — `"<null selector>"` for `0`,
  `"<unknown selector>"` if unregistered.
- `static inline BOOL sel_isEqual(SEL lhs, SEL rhs)` — pointer equality.
- `MULLE_OBJC_COMPAT_GLOBAL SEL sel_registerName(char *str)` — register/get canonical `SEL`.
- `MULLE_OBJC_COMPAT_GLOBAL SEL sel_getUid(char *str)` — deprecated synonym for `sel_registerName`.

### 3.6. `method.h` — `Method`, method descriptions

- `struct objc_method_description { SEL name; char *types; };`
- `id method_invoke(id receiver, Method m, void *_param)` — MetaABI invocation;
  compatible only for pointer-sized params/return.
- `SEL method_getName(Method m)`
- `IMP method_getImplementation(Method m)`
- `char *method_getTypeEncoding(Method m)`
- `char *method_copyReturnType(Method m)` (malloc'ed)
- `char *method_copyArgumentType(Method m, unsigned int index)` (malloc'ed)
- `void method_getReturnType(Method m, char *dst, size_t dst_len)`
- `void method_getArgumentType(Method m, unsigned int index, char *dst, size_t dst_len)`
- `unsigned int method_getNumberOfArguments(Method m)` — `0` for `nil`.
- `struct objc_method_description *method_getDescription(Method m)` — points into
  the mulle descriptor.
- `IMP method_setImplementation(Method m, IMP imp)` — atomic swap, returns old `IMP`.
- `void method_exchangeImplementations(Method m1, Method m2)`

### 3.7. `ivar.h` — instance variables

- `char *ivar_getName(Ivar v)`
- `char *ivar_getTypeEncoding(Ivar v)` — type-encoding string.
- `ptrdiff_t ivar_getOffset(Ivar v)`

### 3.8. `property.h` — properties and property setters

Types:
- `typedef struct _mulle_objc_property *objc_property_t;`
- `typedef struct { char *name; char *value; } objc_property_attribute_t;`

Queries:
- `char *property_getName(objc_property_t property)`
- `char *property_getAttributes(objc_property_t property)`
- `char *property_copyAttributeValue(objc_property_t property, char *attributeName)`
- `objc_property_attribute_t *property_copyAttributeList(objc_property_t property, unsigned int *outCount)`

Property setting (the `@property` machinery entry points):
- `void objc_setProperty(id self, SEL _cmd, ptrdiff_t offset, id newValue, BOOL atomic, signed char shouldCopy)`
- `void objc_setProperty_nonatomic(id self, SEL _cmd, id newValue, ptrdiff_t offset)`
- `void objc_setProperty_nonatomic_copy(id self, SEL _cmd, id newValue, ptrdiff_t offset)`
- `void objc_setProperty_atomic(id self, SEL _cmd, id newValue, ptrdiff_t offset)`
- `void objc_setProperty_atomic_copy(id self, SEL _cmd, id newValue, ptrdiff_t offset)`

### 3.9. `protocol.h` — protocols

Types:
- `typedef struct _mulle_objc_protocol Protocol;`
- `PROTOCOL` (from the runtime, a unique hash ID) is the value used after registration.

Lifecycle:
- `Protocol *objc_getProtocol(char *name)`
- `Protocol *objc_allocateProtocol(char *name)`
- `void objc_registerProtocol(Protocol *proto)`

Mutation (registration-time):
- `void protocol_addMethodDescription(Protocol *proto, SEL name, char *types, BOOL isRequiredMethod, BOOL isInstanceMethod)`
- `void protocol_addProtocol(Protocol *proto, PROTOCOL addition)`
- `void protocol_addProperty(Protocol *proto, char *name, objc_property_attribute_t *attributes, unsigned int attributeCount, BOOL isRequiredProperty, BOOL isInstanceProperty)`

Queries (most are placebos; only `protocol_getName` is meaningful):
- `static inline BOOL protocol_conformsToProtocol(Protocol *proto, PROTOCOL other)` — compares protocol IDs.
- `static inline char *protocol_getName(Protocol *proto)`
- `struct objc_method_description *protocol_copyMethodDescriptionList(Protocol *proto, BOOL isRequiredMethod, BOOL isInstanceMethod, unsigned int *outCount)`
- `struct objc_method_description protocol_getMethodDescription(Protocol *proto, SEL aSel, BOOL isRequiredMethod, BOOL isInstanceMethod)`
- `objc_property_t *protocol_copyPropertyList(Protocol *proto, unsigned int *outCount)`
- `objc_property_t protocol_getProperty(Protocol *proto, char *name, BOOL isRequiredProperty, BOOL isInstanceProperty)`
- `PROTOCOL *protocol_copyProtocolList(Protocol *proto, unsigned int *outCount)`
- `Protocol **objc_copyProtocolList(unsigned int *outCount)`
- `static inline BOOL protocol_isEqual(Protocol *proto, Protocol *other)` — pointer equality.

### 3.10. Shim headers under `src/objc/`

Apple-compatible include layout. `objc/runtime.h` re-exports `mulle-objc-compat`
`runtime.h`, `class.h`, `object.h`, `selector.h`; `objc/message.h` includes
`<objc/objc.h>`, `<objc/runtime.h>` and `<mulle-objc-compat/method.h>`;
`objc/objc.h` includes `objc-api.h`; `objc/objc-runtime.h` includes `runtime.h`
and `message.h`; `objc/objc-class.h` includes `runtime.h`/`message.h`. The
remaining `objc/*.h` files (`objc-api.h`, `objc-auto.h`, `objc-cache.h`,
`objc-config.h`, `objc-env.h`, `objc-exception.h`, `objc-gdb.h`,
`objc-internal.h`, `objc-sync.h`, `objc-abi.h`, `Protocol.h`) are empty
include-placeholders for source compatibility.

## 4. Performance Characteristics

- Everything is a thin wrapper; most queries are O(1) hash/isa lookups into the
  `mulle-objc-runtime` (e.g. `object_getClass`, `class_getInstanceMethod` via
  `mulle_objc_class_defaultsearch_method`).
- `objc_getClass`/`sel_registerName` are string-keyed registrations in the global
  universe; `sel_registerName` returns a canonical unique `SEL` per name.
- `class_copyMethodList`/`class_copyPropertyList`/`class_copyIvarList` allocate
  fresh arrays (`malloc`) that the caller must `free()`.
- `class_addMethod`/`class_addIvar`/`class_addProperty`/`class_addProtocol` and
  ivar layout are only valid before `objc_registerClassPair` (ivars strictly so).
- **Thread-safety**: the library itself has not been scrutinized for
  thread-safety. Concurrency relies on the underlying `mulle-objc-runtime`
  (atomic function-pointer swaps in `method_setImplementation`, etc.). Assume
  `object_setClass` and runtime registration require external synchronization.

## 5. AI Usage Recommendations & Patterns

- **Best Practices**
  - Include the umbrella `#import <mulle-objc-compat/mulle-objc-compat.h>` or the
    Apple-style shims (`#import <objc/runtime.h>`).
  - Always `free()` arrays returned by the `*_copy*` family
    (`class_copyMethodList`, `class_copyPropertyList`, `objc_copyClassList`,
    `property_copyAttributeList`, `protocol_copyProtocolList`,
    `protocol_copyMethodDescriptionList`).
  - Create dynamic classes with the `objc_allocateClassPair` →
    `class_add*` → `objc_registerClassPair` → ... → `objc_disposeClassPair`
    lifecycle; add ivars **before** registration.
  - Treat `PROTOCOL` as an opaque hash ID: compare with
    `class_conformsToProtocol(cls, proto)`, not against `Protocol *`.
  - Use `class_getMethodImplementation` for forwarding/IMP lookups; it triggers
    `+initialize`.
  - In debuggers use `gdb_object_getClass` / `gdb_class_getClass` for callback-triggering lookups.
- **Common Pitfalls**
  - `objc_getClass` returns `id` (not `Class`) in this library's headers.
  - Many functions take `char *` (non-`const`) where Apple's runtime takes
    `const char *` — the literal `"..."` you pass is treated as mutable by the
    signature; it is never modified, but do not rely on `const`-correctness.
  - `class_addMethod` does **not** replace an existing (even inherited)
    implementation; use `class_replaceMethod` to replace.
  - `method_setImplementation` and `method_exchangeImplementations` exist —
    prefer them over hand-editing descriptor fields, and do not access
    `m->descriptor` / `m->implementation` directly.
  - `object_setClass` is non-atomic; a concurrently-read object may have a stale
    isa.
  - Protocol method/property query functions are placebos in mulle-objc; query
    the class instead. `class_getWeakIvarLayout` returns `NULL` — weak ivars are
    unsupported.
  - `objc_msgSend` follows the mulle-objc MetaABI: only compatible when there is
    exactly one pointer-sized parameter and a pointer-sized return.
  - `object_dispose` frees the instance; do not use the pointer afterwards.
- **Idiomatic usage**: prefer the inline accessors (`object_getClass`,
  `class_getName`, `sel_getName`, `ivar_getOffset`, `method_getName`) over the
  `*_copy*` variants for read-only inspection, to avoid allocation churn.
  Objective-C code from Apple projects typically needs only the shim headers plus
  `mulle-objc-compat` linked in.

## 6. Integration Examples

Coding style follows the library/test conventions: 3-space indent, Allman braces,
`return( expr);`.

### Example 1: Selector registration and naming

```objc
#include <objc/runtime.h>
#include <string.h>

int main()
{
   SEL   sel;

   sel = sel_registerName( "foo");
   if( sel == 0)
      return( 1);

   // @selector values unify with the runtime-wide selector table
   if( @selector(foo) != sel)
      return( 1);

   // sel_getName recognizes the zero SEL ...
   if( strcmp( "<null selector>", sel_getName( 0)) != 0)
      return( 1);
   return( 0);
}
```

### Example 2: Dynamic class creation with ivars, methods and a property

```objc
#include <objc/runtime.h>
#include <string.h>

static void   instance_fn( id self, SEL _cmd) {}

int main()
{
   Class                      cls;
   BOOL                       ok;
   objc_property_attribute_t  attrs[ 1];

   cls = objc_allocateClassPair( nil, "MyRuntimeClass", 0);
   if( ! cls)
      return( 1);

   // ivars must be added before registration
   ok = class_addIvar( cls, "ivar", sizeof( id), 3, "@");
   if( ! ok)
      return( 1);

   ok = class_addMethod( cls, sel_registerName( "instanceMethod"),
                         (IMP) &instance_fn, "v@:");
   if( ! ok)
      return( 1);

   attrs[ 0].name  = "T";
   attrs[ 0].value = "i";
   class_addProperty( cls, "i", attrs, 1);

   objc_registerClassPair( cls);

   // ... use the class ...
   if( strcmp( class_getName( cls), "MyRuntimeClass") != 0)
      return( 1);

   objc_disposeClassPair( cls);
   return( 0);
}
```

### Example 3: Instance creation and ivar access

```objc
#include <objc/runtime.h>
#include <string.h>

#pragma clang diagnostic ignored "-Wobjc-root-class"

// root class (isa is in the object header, not a declared ivar)
OBJC_ROOT_CLASS
@interface TestRoot @end
@implementation TestRoot
+(Class) class { return self; }
@end

// runtime layout of Sub: [0] superIvar  [1] subIvar
@interface Super : TestRoot { @public char superIvar; } @end
@implementation Super @end

@interface Sub : Super { @public id subIvar; } @end
@implementation Sub @end

int main()
{
   id    obj;
   Ivar  ivar;

   ivar = class_getInstanceVariable( [Sub class], "superIvar");
   if( ! ivar)
      return( 1);
   if( ivar_getOffset( ivar) != 0)
      return( 1);
   if( strcmp( ivar_getTypeEncoding( ivar), "c") != 0)
      return( 1);

   ivar = class_getInstanceVariable( [Sub class], "subIvar");
   if( ! ivar)
      return( 1);
   if( ivar_getOffset( ivar) != (ptrdiff_t) sizeof( intptr_t))
      return( 1);
   if( strcmp( ivar_getTypeEncoding( ivar), "@") != 0)
      return( 1);

   obj = class_createInstance( [Sub class], 0);
   if( ! obj)
      return( 1);
   object_setIvar( obj, ivar, obj);
   if( object_getIvar( obj, ivar) != obj)
      return( 1);

   object_dispose( obj);
   return( 0);
}
```

(Class layout and lifecycle mirror `test/02_ivar/ivar.m`; that test also
exercises `object_getInstanceVariable`/`object_setInstanceVariable`.)

### Example 4: Copying and inspecting the method list

```objc
#include <objc/runtime.h>

static void   instance_fn( id self, SEL _cmd) {}

int main()
{
   Method          *methods;
   unsigned int    count;
   unsigned int    i;
   Class           cls;

   // create a class with two methods, like Example 2
   cls = objc_allocateClassPair( nil, "MyRuntimeClass", 0);
   if( ! cls)
      return( 1);
   class_addMethod( cls, sel_registerName( "one"), (IMP) &instance_fn, "v@:");
   class_addMethod( cls, sel_registerName( "two"), (IMP) &instance_fn, "v@:");
   objc_registerClassPair( cls);

   count = 100;
   methods = class_copyMethodList( cls, &count);
   if( ! methods)
      return( 1);   // class has no methods

   // the array is NULL-terminated
   if( methods[ count] != NULL)
      return( 1);

   for( i = 0; i < count; i++)
   {
      if( method_getName( methods[ i]) == 0)
         return( 1);
   }

   free( methods);

   // a NULL class yields NULL and *outCount == 0
   count = 100;
   methods = class_copyMethodList( NULL, &count);
   if( methods || count != 0)
      return( 1);

   objc_disposeClassPair( cls);
   return( 0);
}
```

## 7. Dependencies

Direct `mulle-sde` dependencies (from `.mulle/etc/sourcetree/config`):

- `MulleObjC` — collection of Objective-C root classes for `mulle-objc`;
  provides `mulle-objc.h` (included via every public header's `include.h`).

Transitively required at the runtime level (not direct dependencies of this
project to link):

- `mulle-objc-runtime` — the actual runtime these functions map onto
  (compile-time version-gated, `>= 0.16.0`).
- `mulle-clang` — the compiler must be mulle-clang (multiverse support, MetaABI
  message sending).