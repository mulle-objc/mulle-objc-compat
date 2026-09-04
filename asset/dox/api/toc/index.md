# mulle-objc-compat Library Documentation for AI
<!-- Keywords: compatibility, apple-runtime -->

## 1. Introduction & Purpose

**mulle-objc-compat** is a compatibility layer that maps Apple Objective-C runtime functions to their mulle-objc equivalents. This enables easy porting of programs using Apple's Objective-C runtime to mulle-objc, providing a familiar API for developers transitioning from standard Objective-C.

This library is particularly useful for:
- Porting existing Objective-C code to mulle-objc
- API compatibility between Apple and mulle-objc runtimes
- Cross-platform code that works on both runtimes
- Reducing code changes when migrating projects
- Familiar Apple runtime API in mulle-objc environment

## 2. Key Concepts & Design Philosophy

- **API Compatibility**: Implements Apple Objective-C runtime interface
- **Limited Scope**: Only implements available mulle-objc features
- **Portability**: Enable code written for Apple runtime to work with mulle-objc
- **Single Runtime**: Works exclusively with mulle-objc-runtime
- **Familiar Functions**: Use standard Apple runtime function names

## 3. Core API & Data Structures

### Class Operations

- `Class objc_getClass(const char *name)`
  - Get class by name
  - Apple API equivalent: Standard Objective-C class lookup

- `Class object_getClass(id obj)`
  - Get class of object
  - Get object's runtime class

- `BOOL class_isMetaClass(Class cls)`
  - Check if class is metaclass

### Object Inspection

- `const char *object_getClassName(id obj)`
  - Get class name of object

- `Class object_setClass(id obj, Class cls)`
  - Change object's class at runtime

### Method Inspection

- `Method *class_copyMethodList(Class cls, unsigned int *outCount)`
  - Get list of methods in class
  - Returns array of Method pointers

- `Method class_getInstanceMethod(Class cls, SEL name)`
  - Get instance method by name

- `Method class_getClassMethod(Class cls, SEL name)`
  - Get class method by name

- `const char *sel_getName(SEL sel)`
  - Get selector name as string

- `SEL sel_registerName(const char *str)`
  - Register or get selector from string

### Protocol Operations

- `Protocol **class_copyProtocolList(Class cls, unsigned int *outCount)`
  - Get protocols implemented by class

- `BOOL class_conformsToProtocol(Class cls, Protocol *protocol)`
  - Check if class implements protocol

### Property Inspection

- `objc_property_t *class_copyPropertyList(Class cls, unsigned int *outCount)`
  - Get properties of class

- `const char *property_getName(objc_property_t property)`
  - Get property name

### Method Dispatch

- `IMP class_getMethodImplementation(Class cls, SEL name)`
  - Get method implementation

- `id objc_msgSend(id self, SEL op, ...)`
  - Send message (basic case)
  - Limited to single pointer-sized parameter and return

## 4. Limitations & Compatibility Notes

- **Thread Safety**: Not thoroughly scrutinized for thread-safety
- **Limited Features**: Does not implement all Apple runtime features (e.g., weak variables)
- **Message Sending**: `objc_msgSend` limited to pointer-sized parameters/returns
- **Compiler**: Must be compiled with mulle-clang (requires multiverse support)
- **Incomplete Implementation**: Only features supported by mulle-objc runtime

## 5. Integration Examples

### Example 1: Class Lookup
```objc
Class cls = objc_getClass("NSString");
if (cls) {
    NSLog(@"Found NSString class");
}
```

### Example 2: Object Inspection
```objc
NSString *str = @"Hello";
const char *className = object_getClassName(str);
printf("Object class: %s\n", className);
```

### Example 3: Method Listing
```objc
Class cls = objc_getClass("NSArray");
unsigned int methodCount = 0;
Method *methods = class_copyMethodList(cls, &methodCount);

for (unsigned int i = 0; i < methodCount; i++) {
    const char *methodName = sel_getName(method_getName(methods[i]));
    printf("Method: %s\n", methodName);
}

free(methods);
```

### Example 4: Protocol Checking
```objc
Class cls = [MyClass class];
Protocol *proto = NSProtocolFromString(@"NSCoding");

if (class_conformsToProtocol(cls, proto)) {
    printf("Class implements NSCoding\n");
}
```

### Example 5: Dynamic Message Sending
```objc
id obj = [[NSString alloc] init];
SEL selector = sel_registerName("length");
IMP imp = class_getMethodImplementation([obj class], selector);

if (imp) {
    NSUInteger length = ((NSUInteger (*)(id, SEL))(void *)imp)(obj, selector);
}
```

## 6. Dependencies

- **mulle-objc-runtime** - mulle Objective-C runtime
- **mulle-clang** - Compiler with multiverse support
- Standard C library

## 7. Standards & References

- **Apple Objective-C Runtime**: Reference implementation
- **mulle-objc Runtime**: Target runtime environment

## 8. Version Information

mulle-objc-compat version macro: `MULLE_OBJC_COMPAT_VERSION`
Format: `(major << 20) | (minor << 8) | patch`
