// TEST_CONFIG

#include "test.h"

#import <objc/runtime.h>

int main() {
    // ensure various bits of API don't crash when tossed nil parameters
    class_conformsToProtocol( Nil, nil);
    method_setImplementation( NULL, NULL);
  
    succeed(__FILE__);
}
