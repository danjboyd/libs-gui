/* The application's delegate is told when the screen parameters change,
   as the delegate is told of the other application notifications.  The
   delegate was not registered for this one, so it was never told.  The
   application needs the backend, so the set is skipped without it. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSNotification.h>

#include <AppKit/NSApplication.h>

@interface ScreenDelegate : NSObject
{
@public
  int count;
}
- (void) applicationDidChangeScreenParameters: (NSNotification *)n;
@end

@implementation ScreenDelegate
- (void) applicationDidChangeScreenParameters: (NSNotification *)n
{
  count++;
}
@end

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  ScreenDelegate *d;

  START_SET("NSApplication screen parameters delegate")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  d = AUTORELEASE([ScreenDelegate new]);
  [NSApp setDelegate: d];
  [[NSNotificationCenter defaultCenter]
    postNotificationName: NSApplicationDidChangeScreenParametersNotification
                  object: NSApp];
  PASS(d->count == 1,
    "the delegate is told that the screen parameters changed");
  [NSApp setDelegate: nil];

  END_SET("NSApplication screen parameters delegate")

  [pool release];
  return 0;
}
