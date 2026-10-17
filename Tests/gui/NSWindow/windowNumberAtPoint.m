/* +[NSWindow windowNumberAtPoint:belowWindowWithWindowNumber:] answers the
   frontmost visible window containing a point, among the windows below a
   given one, and 0 when there is none.  It used to answer 0 always.
*/
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSDate.h>
#include <Foundation/NSRunLoop.h>
#include <AppKit/NSApplication.h>
#include <AppKit/NSWindow.h>

static NSWindow *
makeWindow(NSRect frame)
{
  NSWindow *w = [[NSWindow alloc] initWithContentRect: frame
					    styleMask: NSBorderlessWindowMask
					      backing: NSBackingStoreBuffered
						defer: NO];
  [w setReleasedWhenClosed: NO];
  return AUTORELEASE(w);
}

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSWindow *a;
  NSWindow *b;
  NSInteger top;
  NSInteger below;
  NSPoint inBoth;

  START_SET("NSWindow windowNumberAtPoint:belowWindowWithWindowNumber:")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  a = makeWindow(NSMakeRect(100, 100, 200, 200));
  b = makeWindow(NSMakeRect(150, 150, 200, 200));
  [a orderFront: nil];
  [b orderFront: nil];
  [[NSRunLoop currentRunLoop] runUntilDate:
    [NSDate dateWithTimeIntervalSinceNow: 0.2]];
  inBoth = NSMakePoint(200, 200);

  top = [NSWindow windowNumberAtPoint: inBoth belowWindowWithWindowNumber: 0];
  PASS(top == [a windowNumber] || top == [b windowNumber],
    "a window containing the point is found");
  below = [NSWindow windowNumberAtPoint: inBoth
	    belowWindowWithWindowNumber: top];
  PASS(below != top
    && (below == [a windowNumber] || below == [b windowNumber]),
    "the other window containing the point is below it");
  PASS([NSWindow windowNumberAtPoint: inBoth
	 belowWindowWithWindowNumber: below] == 0,
    "no window containing the point is below both");

  PASS([NSWindow windowNumberAtPoint: NSMakePoint(120, 120)
	 belowWindowWithWindowNumber: 0] == [a windowNumber],
    "a point in one window finds that window");
  PASS([NSWindow windowNumberAtPoint: NSMakePoint(5000, 5000)
	 belowWindowWithWindowNumber: 0] == 0,
    "a point in no window finds none");

  [b orderOut: nil];
  PASS([NSWindow windowNumberAtPoint: NSMakePoint(320, 320)
	 belowWindowWithWindowNumber: 0] == 0,
    "a window that is not visible is not found");

  END_SET("NSWindow windowNumberAtPoint:belowWindowWithWindowNumber:")

  [pool release];
  return 0;
}
