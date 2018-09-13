// TEST_CONFIG MEM=mrc,arc

#include "test.h"
#include <objc/runtime.h>
#include <objc/objc-abi.h>

#include "testroot.i"

@interface Base : TestRoot {
  @public
    id ivar;
}
@end
@implementation Base @end

int main()
{
    long   oldRetainCount;
    SEL _cmd = @selector(foo);
    Base *o = [Base new];
    ptrdiff_t offset = ivar_getOffset(class_getInstanceVariable([Base class], "ivar"));
    testassert(offset == 0);
    TestRoot *value = [TestRoot new];

    // fixme test atomicity

    // Original setter API

    testprintf("original nonatomic retain\n");
    o->ivar = nil;
    oldRetainCount = [value retainCount];
    TestRootCopyWithZone = 0;
    TestRootMutableCopyWithZone = 0;
    objc_setProperty(o, _cmd, offset, value, NO/*atomic*/, NO/*copy*/);
    testassert([value retainCount] == oldRetainCount + 1);
    testassert(TestRootCopyWithZone == 0);
    testassert(TestRootMutableCopyWithZone == 0);
    testassert(o->ivar == value);

    testprintf("original atomic retain\n");
    o->ivar = nil;
    oldRetainCount = [value retainCount];
    TestRootCopyWithZone = 0;
    TestRootMutableCopyWithZone = 0;
    objc_setProperty(o, _cmd, offset, value, YES/*atomic*/, NO/*copy*/);
    testassert([value retainCount] ==  oldRetainCount + 1);
    testassert(TestRootCopyWithZone == 0);
    testassert(TestRootMutableCopyWithZone == 0);
    testassert(o->ivar == value);

    testprintf("original nonatomic copy\n");
    o->ivar = nil;
    oldRetainCount = [value retainCount];
    TestRootCopyWithZone = 0;
    TestRootMutableCopyWithZone = 0;
    objc_setProperty(o, _cmd, offset, value, NO/*atomic*/, YES/*copy*/);
    testassert([value retainCount] == oldRetainCount);
    testassert(TestRootCopyWithZone == 1);
    testassert(TestRootMutableCopyWithZone == 0);
    testassert(o->ivar  &&  o->ivar != value);

    testprintf("original atomic copy\n");
    o->ivar = nil;
    oldRetainCount = [value retainCount];
    TestRootCopyWithZone = 0;
    TestRootMutableCopyWithZone = 0;
    objc_setProperty(o, _cmd, offset, value, YES/*atomic*/, YES/*copy*/);
    testassert([value retainCount] == oldRetainCount);
    testassert(TestRootCopyWithZone == 1);
    testassert(TestRootMutableCopyWithZone == 0);
    testassert(o->ivar  &&  o->ivar != value);

    testprintf("original nonatomic mutablecopy\n");
    o->ivar = nil;
    oldRetainCount = [value retainCount];
    TestRootCopyWithZone = 0;
    TestRootMutableCopyWithZone = 0;
    objc_setProperty(o, _cmd, offset, value, NO/*atomic*/, 2/*copy*/);
    testassert([value retainCount] == oldRetainCount);
    testassert(TestRootCopyWithZone == 0);
    testassert(TestRootMutableCopyWithZone == 1);
    testassert(o->ivar  &&  o->ivar != value);

    testprintf("original atomic mutablecopy\n");
    o->ivar = nil;
    oldRetainCount = [value retainCount];
    TestRootCopyWithZone = 0;
    TestRootMutableCopyWithZone = 0;
    objc_setProperty(o, _cmd, offset, value, YES/*atomic*/, 2/*copy*/);
    testassert([value retainCount] == oldRetainCount);
    testassert(TestRootCopyWithZone == 0);
    testassert(TestRootMutableCopyWithZone == 1);
    testassert(o->ivar  &&  o->ivar != value);


    // Optimized setter API

    testprintf("optimized nonatomic retain\n");
    o->ivar = nil;
    oldRetainCount = [value retainCount];
    TestRootCopyWithZone = 0;
    TestRootMutableCopyWithZone = 0;
    objc_setProperty_nonatomic(o, _cmd, value, offset);
    testassert([value retainCount] == oldRetainCount + 1);
    testassert(TestRootCopyWithZone == 0);
    testassert(TestRootMutableCopyWithZone == 0);
    testassert(o->ivar == value);

    testprintf("optimized atomic retain\n");
    o->ivar = nil;
    oldRetainCount = [value retainCount];
    TestRootCopyWithZone = 0;
    TestRootMutableCopyWithZone = 0;
    objc_setProperty_atomic(o, _cmd, value, offset);
    testassert( [value retainCount] == oldRetainCount + 1);
    testassert(TestRootCopyWithZone == 0);
    testassert(TestRootMutableCopyWithZone == 0);
    testassert(o->ivar == value);

    testprintf("optimized nonatomic copy\n");
    o->ivar = nil;
    oldRetainCount = [value retainCount];
    TestRootCopyWithZone = 0;
    TestRootMutableCopyWithZone = 0;
    objc_setProperty_nonatomic_copy(o, _cmd, value, offset);
    testassert([value retainCount] == oldRetainCount);
    testassert(TestRootCopyWithZone == 1);
    testassert(TestRootMutableCopyWithZone == 0);
    testassert(o->ivar  &&  o->ivar != value);

    testprintf("optimized atomic copy\n");
    o->ivar = nil;
    oldRetainCount = [value retainCount];
    TestRootCopyWithZone = 0;
    TestRootMutableCopyWithZone = 0;
    objc_setProperty_atomic_copy(o, _cmd, value, offset);
    testassert( [value retainCount] == oldRetainCount);
    testassert(TestRootCopyWithZone == 1);
    testassert(TestRootMutableCopyWithZone == 0);
    testassert(o->ivar  &&  o->ivar != value);

    succeed(__FILE__);
}
