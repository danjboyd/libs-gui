/* The NSAccessibilityCustomRotorItemLoadDelegate protocol exists at
   runtime.  It was only forward declared, so it had no protocol object.
   It needs no backend. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <AppKit/NSAccessibilityCustomRotor.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];

  START_SET("NSAccessibilityCustomRotorItemLoadDelegate")

  PASS(objc_getProtocol("NSAccessibilityCustomRotorItemLoadDelegate") != NULL,
    "the protocol exists at runtime");

  END_SET("NSAccessibilityCustomRotorItemLoadDelegate")

  [pool release];
  return 0;
}
