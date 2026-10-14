/* A resizable window shows its resize indicator until told not to.
   -setShowsResizeIndicator: used to only log that it was not implemented,
   so the indicator could not be turned off. */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSWindow.h>

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSWindow *w;

  START_SET("NSWindow showsResizeIndicator")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  w = AUTORELEASE([[NSWindow alloc]
    initWithContentRect: NSMakeRect(0, 0, 120, 120)
              styleMask: NSTitledWindowMask | NSResizableWindowMask
                backing: NSBackingStoreBuffered
                  defer: YES]);
  PASS([w showsResizeIndicator] == YES,
    "a resizable window shows its resize indicator");

  [w setShowsResizeIndicator: NO];
  PASS([w showsResizeIndicator] == NO,
    "the resize indicator can be turned off");

  [w setShowsResizeIndicator: YES];
  PASS([w showsResizeIndicator] == YES,
    "the resize indicator can be turned back on");

  END_SET("NSWindow showsResizeIndicator")

  [pool release];
  return 0;
}
