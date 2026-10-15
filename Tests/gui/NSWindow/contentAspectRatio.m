/* A window keeps its content aspect ratio, which replaces its frame aspect
   ratio and is replaced by it or by resize increments, as in Cocoa.  The setter was a stub, and
   the getter always answered 1 by 1.  Windows need the backend, so the set
   is skipped without it. */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSWindow.h>

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSWindow *w;

  START_SET("NSWindow contentAspectRatio")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  w = AUTORELEASE([[NSWindow alloc]
    initWithContentRect: NSMakeRect(0, 0, 160, 90)
              styleMask: NSTitledWindowMask | NSResizableWindowMask
                backing: NSBackingStoreBuffered
                  defer: YES]);
  [w setAspectRatio: NSMakeSize(4, 3)];
  [w setContentAspectRatio: NSMakeSize(16, 9)];
  PASS(NSEqualSizes([w contentAspectRatio], NSMakeSize(16, 9)),
    "the content aspect ratio is kept");
  PASS(NSEqualSizes([w aspectRatio], NSZeroSize),
    "the content aspect ratio replaces the frame aspect ratio");

  [w setAspectRatio: NSMakeSize(4, 3)];
  PASS(NSEqualSizes([w contentAspectRatio], NSZeroSize),
    "the frame aspect ratio replaces the content aspect ratio");

  [w setContentAspectRatio: NSMakeSize(16, 9)];
  [w setResizeIncrements: NSMakeSize(2, 2)];
  PASS(NSEqualSizes([w contentAspectRatio], NSZeroSize),
    "resize increments replace the content aspect ratio");

  END_SET("NSWindow contentAspectRatio")

  [pool release];
  return 0;
}
