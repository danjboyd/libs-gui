/* The system indigo and teal colours are RGB colours, like the other
 * system accent colours.  Both methods used to answer nil.  Colours are
 * plain value objects and need no backend.
 */
#include "Testing.h"
#include <Foundation/NSAutoreleasePool.h>
#include <AppKit/NSColor.h>
#include <AppKit/NSGraphics.h>

int main(int argc, char **argv)
{
  NSAutoreleasePool	*pool = [NSAutoreleasePool new];
  NSColor		*indigo;
  NSColor		*teal;

  START_SET("NSColor system accent colours")
    indigo = [NSColor systemIndigoColor];
    teal = [NSColor systemTealColor];
    PASS(indigo != nil, "systemIndigoColor answers a colour");
    PASS(teal != nil, "systemTealColor answers a colour");
    PASS([[indigo colorUsingColorSpaceName: NSCalibratedRGBColorSpace]
      blueComponent] > [[indigo colorUsingColorSpaceName:
      NSCalibratedRGBColorSpace] greenComponent],
      "the indigo colour is more blue than green");
    PASS(![indigo isEqual: teal], "indigo and teal differ");
  END_SET("NSColor system accent colours")

  [pool release];
  return 0;
}
