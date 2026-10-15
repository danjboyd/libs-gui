/* NSEvent keeps whether mouse coalescing is enabled, on by default.  The
   setter was a stub, so coalescing always read as enabled.  It needs no
   backend. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <AppKit/NSEvent.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];

  START_SET("NSEvent mouse coalescing")

  PASS([NSEvent isMouseCoalescingEnabled], "mouse coalescing is on by default");
  [NSEvent setMouseCoalescingEnabled: NO];
  PASS(![NSEvent isMouseCoalescingEnabled], "mouse coalescing can be turned off");
  [NSEvent setMouseCoalescingEnabled: YES];
  PASS([NSEvent isMouseCoalescingEnabled], "mouse coalescing can be turned on");

  END_SET("NSEvent mouse coalescing")

  [pool release];
  return 0;
}
