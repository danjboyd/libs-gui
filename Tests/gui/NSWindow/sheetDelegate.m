/* A window's delegate is told when a sheet is about to begin on the window
   and when it has ended, as it is told of the other window notifications.
   The delegate was not registered for these two, so it was never told.
   The window needs the backend, so the set is skipped without it. */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSNotification.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSWindow.h>

@interface SheetDelegate : NSObject
{
@public
  int began;
  int ended;
}
@end

@implementation SheetDelegate
- (void) windowWillBeginSheet: (NSNotification *)n
{
  began++;
}
- (void) windowDidEndSheet: (NSNotification *)n
{
  ended++;
}
@end

int
main(int argc, const char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  SheetDelegate *d;
  NSWindow *w;

  START_SET("NSWindow sheet delegate")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  d = AUTORELEASE([SheetDelegate new]);
  w = AUTORELEASE([[NSWindow alloc]
    initWithContentRect: NSMakeRect(0, 0, 120, 120)
              styleMask: NSTitledWindowMask
                backing: NSBackingStoreBuffered
                  defer: YES]);
  [w setDelegate: d];

  [nc postNotificationName: NSWindowWillBeginSheetNotification object: w];
  PASS(d->began == 1, "the delegate is told that a sheet will begin");
  [nc postNotificationName: NSWindowDidEndSheetNotification object: w];
  PASS(d->ended == 1, "the delegate is told that a sheet has ended");

  [w setDelegate: nil];

  END_SET("NSWindow sheet delegate")

  [pool release];
  return 0;
}
