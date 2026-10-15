/* A window's delegate is told when the window's screen profile changes, as
   it is told of the other window notifications.  The delegate was not
   registered for this one, so it was never told.  The window needs the
   backend, so the set is skipped without it. */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSNotification.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSWindow.h>

@interface ProfileDelegate : NSObject
{
@public
  int count;
}
@end

@implementation ProfileDelegate
- (void) windowDidChangeScreenProfile: (NSNotification *)n
{
  count++;
}
@end

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  ProfileDelegate *d;
  NSWindow *w;

  START_SET("NSWindow screen profile delegate")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  d = AUTORELEASE([ProfileDelegate new]);
  w = AUTORELEASE([[NSWindow alloc]
    initWithContentRect: NSMakeRect(0, 0, 120, 120)
              styleMask: NSTitledWindowMask
                backing: NSBackingStoreBuffered
                  defer: YES]);
  [w setDelegate: d];
  [[NSNotificationCenter defaultCenter]
    postNotificationName: NSWindowDidChangeScreenProfileNotification object: w];
  PASS(d->count == 1, "the delegate is told that the screen profile changed");
  [w setDelegate: nil];

  END_SET("NSWindow screen profile delegate")

  [pool release];
  return 0;
}
