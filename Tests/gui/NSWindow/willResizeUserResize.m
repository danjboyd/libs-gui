/* When the window server resizes a window, as it does when the user drags
   its edge, the delegate is asked windowWillResize:toSize: and the window
   takes the size it answers, keeping its top edge.  The delegate was not
   asked.  The server's report of a frame the window set itself is not a
   resize by the server, and does not ask it.  The window needs the backend, so the set is skipped without it. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSEvent.h>
#include <AppKit/NSWindow.h>
#include <GNUstepGUI/GSDisplayServer.h>

@interface ResizeDelegate : NSObject
{
@public
  int asked;
  NSSize proposed;
}
@end
@implementation ResizeDelegate
- (NSSize) windowWillResize: (NSWindow *)window toSize: (NSSize)size
{
  asked++;
  proposed = size;
  return NSMakeSize(250, 170);
}
@end

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSWindow *window;
  ResizeDelegate *delegate;
  NSEvent *event;
  NSRect before;

  START_SET("NSWindow windowWillResize:toSize: on a server resize")

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
    initWithContentRect: NSMakeRect(100, 100, 240, 160)
	      styleMask: NSTitledWindowMask | NSResizableWindowMask
		backing: NSBackingStoreBuffered
		  defer: NO]);
  [window setReleasedWhenClosed: NO];
  delegate = AUTORELEASE([ResizeDelegate new]);
  [window setDelegate: delegate];
  before = [window frame];
  event = [NSEvent otherEventWithType: NSAppKitDefined
			     location: before.origin
			modifierFlags: 0
			    timestamp: 0
			 windowNumber: [window windowNumber]
			      context: nil
			      subtype: GSAppKitWindowResized
				data1: 300
				data2: 210];
  [window sendEvent: event];
  PASS(delegate->asked == 1 && NSEqualSizes(delegate->proposed, NSMakeSize(300, 210)),
    "the delegate is asked once about the size the server gave");
  PASS(NSEqualSizes([window frame].size, NSMakeSize(250, 170)),
    "the window takes the size the delegate answers");
  PASS(NSMaxY([window frame]) == NSMinY(before) + 210,
    "the window keeps the top edge the server gave it");

  delegate->asked = 0;
  [window setFrame: NSMakeRect(120, 120, 280, 190) display: NO];
  PASS(delegate->asked == 0
    && NSEqualSizes([window frame].size, NSMakeSize(280, 190)),
    "setting the frame does not ask the delegate");

  END_SET("NSWindow windowWillResize:toSize: on a server resize")

  [pool release];
  return 0;
}
