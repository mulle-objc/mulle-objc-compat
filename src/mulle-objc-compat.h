#include <stdint.h>

/*
 *  (c) 2018 nat
 *
 *  version:  major, minor, patch
 */
#define MULLE_OBJC_COMPAT_VERSION  ((0 << 20) | (14 << 8) | 0)

#include "runtime.h"
#include "method.h"
#include "ivar.h"
#include "class.h"
#include "object.h"
#include "property.h"
#include "protocol.h"

#ifdef MULLE_OBJC_RUNTIME_VERSION
# if MULLE_OBJC_RUNTIME_VERSION < ((0 << 20) | (14 << 8) | 0)
#  error "mulle-objc-runtime is too old"
# endif
#endif
