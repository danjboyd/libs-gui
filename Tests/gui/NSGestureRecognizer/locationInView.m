/* -locationInView: locates the current event in the coordinates of the
   view, or of the window when there is no view.  It used to answer the
   zero point.  It needs a window and events, so the set is skipped when the
   backend is unavailable. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSDate.h>
#include <Foundation/NSGeometry.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSEvent.h>
#include <AppKit/NSGestureRecognizer.h>
#include <AppKit/NSView.h>
#include <AppKit/NSWindow.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSGestureRecognizer *recognizer;
  NSWindow *window;
  NSView *view;
  NSEvent *event;
  NSPoint location;

  START_SET("NSGestureRecognizer locationInView:")

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

  window = AUTORELEASE([[NSWindow alloc]
    initWithContentRect: NSMakeRect(80, 80, 240, 160)
              styleMask: NSBorderlessWindowMask
                backing: NSBackingStoreBuffered
                  defer: NO]);
  [window setReleasedWhenClosed: NO];
  view = AUTORELEASE([[NSView alloc] initWithFrame: NSMakeRect(40, 30, 100, 80)]);
  [[window contentView] addSubview: view];
  recognizer = AUTORELEASE([NSGestureRecognizer new]);

  event = [NSEvent mouseEventWithType: NSLeftMouseDown
                             location: NSMakePoint(60, 50)
                        modifierFlags: 0
                            timestamp: 0.0
                         windowNumber: [window windowNumber]
                              context: nil
                          eventNumber: 0
                           clickCount: 1
                             pressure: 1.0];
  [NSApp postEvent: event atStart: YES];
  event = [NSApp nextEventMatchingMask: NSLeftMouseDownMask
                             untilDate: [NSDate distantPast]
                                inMode: NSDefaultRunLoopMode
                               dequeue: YES];
  if (event == nil)
    {
      SKIP("the posted event was not delivered")
    }

  location = [recognizer locationInView: view];
  PASS(NSEqualPoints(location, NSMakePoint(20, 20)),
    "the current event is located in the view's coordinates");
  location = [recognizer locationInView: nil];
  PASS(NSEqualPoints(location, NSMakePoint(60, 50)),
    "without a view the event is located in the window's coordinates");

  END_SET("NSGestureRecognizer locationInView:")

  [pool release];
  return 0;
}
