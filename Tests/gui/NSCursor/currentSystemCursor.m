/* +currentSystemCursor answers the cursor the application shows, the
   arrow until it sets one.  It used to answer nil.  Cursors need the
   backend, so the set is skipped without it. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <AppKit/NSApplication.h>
#include <AppKit/NSCursor.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];

  START_SET("NSCursor currentSystemCursor")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  PASS([NSCursor currentSystemCursor] != nil,
    "there is a current system cursor");
  [[NSCursor IBeamCursor] set];
  PASS([NSCursor currentSystemCursor] == [NSCursor IBeamCursor],
    "the current system cursor is the cursor the application shows");
  [[NSCursor arrowCursor] set];

  END_SET("NSCursor currentSystemCursor")

  [pool release];
  return 0;
}
