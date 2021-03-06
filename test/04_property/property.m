// TEST_CONFIG

#include "test.h"
#include "testroot.i"
#include <stdint.h>
#include <string.h>
#include <objc/objc-runtime.h>

@interface Super : TestRoot {
  @public
    char _superProp;
}

@property(readonly) char superProp;
@end

@implementation Super
@synthesize superProp = _superProp;
@end


@interface Sub : Super {
  @public
    uintptr_t _subProp;
}
@property(readonly) uintptr_t subProp;
@end

@implementation Sub
@synthesize subProp = _subProp;
@end


int main()
{
    /*
       Runtime layout of Sub:
         [0] _superProp
         [1] _subProp
    */

    objc_property_t prop;

    prop = class_getProperty([Sub class], "subProp");
    testassert(prop);

    prop = class_getProperty([Super class], "superProp");
    testassert(prop);
    testassert(prop == class_getProperty([Sub class], "superProp"));

    prop = class_getProperty([Super class], "subProp");
    testassert(!prop);

    prop = class_getProperty(object_getClass([Sub class]), "subProp");
    testassert(!prop);


    testassert(NULL == class_getProperty(NULL, "foo"));
    testassert(NULL == class_getProperty([Sub class], NULL));
    testassert(NULL == class_getProperty(NULL, NULL));

    succeed(__FILE__);
    return 0;
}
