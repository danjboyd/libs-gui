/* NSCountWindowsForContext counts the application's windows, as
 * NSCountWindows does: an application has a single context.  It used to
 * answer 0.  Windows need the backend, so the set skips without it.
 */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSGraphics.h>
#import <AppKit/NSWindow.h>

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSWindow *window;
  NSInteger count = -1;
  NSInteger all = -1;

  START_SET("NSCountWindowsForContext")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  window = AUTORELEASE([[NSWindow alloc]
    initWithContentRect: NSMakeRect(100, 100, 100, 100)
              styleMask: NSTitledWindowMask
                backing: NSBackingStoreBuffered
                  defer: NO]);
  [window setReleasedWhenClosed: NO];
  [window orderFront: nil];

  NSCountWindowsForContext(0, &count);
  NSCountWindows(&all);
  PASS(count >= 1, "the windows of the application are counted");
  PASS(count == all, "the count is that of NSCountWindows");

  [window orderOut: nil];

  END_SET("NSCountWindowsForContext")

  [pool release];
  return 0;
}
