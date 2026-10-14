/* -isVertical answers -1 until the slider has been laid out, as documented.
   The value was kept in a BOOL ivar, so the -1 read back as 255. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSSliderCell.h>

int main()
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSSliderCell *cell;

  START_SET("NSSliderCell isVertical")

  NS_DURING
  {
    [NSApplication sharedApplication];
  }
  NS_HANDLER
  {
    if ([[localException name] isEqualToString: NSInternalInconsistencyException ])
       SKIP("It looks like GNUstep backend is not yet installed")
  }
  NS_ENDHANDLER

  cell = AUTORELEASE([[NSSliderCell alloc] init]);
  PASS([cell isVertical] == -1,
    "a slider that has not been laid out answers -1 for isVertical");

  END_SET("NSSliderCell isVertical")

  [pool release];
  return 0;
}
