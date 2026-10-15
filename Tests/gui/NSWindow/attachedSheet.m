/* -attachedSheet is a window method, as in Cocoa: a window answers its
   attached sheet, nil without one, and other objects do not respond to
   it.  GNUstep declared it on NSObject instead, where only NSWindow
   implemented it.  Windows need the backend, so the set is skipped
   without it. */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSWindow.h>

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  id object = AUTORELEASE([NSObject new]);
  NSWindow *w;

  START_SET("NSWindow attachedSheet")

  PASS(![object respondsToSelector: @selector(attachedSheet)],
    "a plain object does not respond to attachedSheet");

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  w = AUTORELEASE([[NSWindow alloc]
    initWithContentRect: NSMakeRect(0, 0, 120, 120)
              styleMask: NSTitledWindowMask
                backing: NSBackingStoreBuffered
                  defer: YES]);
  PASS([w attachedSheet] == nil, "a window without a sheet answers nil");

  END_SET("NSWindow attachedSheet")

  [pool release];
  return 0;
}
