/* A scroller keeps the knob style it is given, for themes to use.  The
   setter used to only log a warning, and the getter always answered the
   default style.  The scroller uses the theme and font backend, so the set
   is skipped when the backend is unavailable.
*/
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSGeometry.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSScroller.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSScroller *s;

  START_SET("NSScroller knobStyle")

  NS_DURING
  {
    [NSApplication sharedApplication];
  }
  NS_HANDLER
  {
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  }
  NS_ENDHANDLER

  s = AUTORELEASE([[NSScroller alloc] initWithFrame: NSMakeRect(0, 0, 16, 100)]);
  PASS([s knobStyle] == NSScrollerKnobStyleDefault,
    "a new scroller has the default knob style");
  [s setKnobStyle: NSScrollerKnobStyleLight];
  PASS([s knobStyle] == NSScrollerKnobStyleLight,
    "a scroller keeps the knob style it is given");

  END_SET("NSScroller knobStyle")

  [pool release];
  return 0;
}
