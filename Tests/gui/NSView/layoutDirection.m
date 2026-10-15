/* A view keeps its user interface layout direction, left to right by
   default.  The setter was a stub, so the direction always read as left to
   right.  Views need no backend for this. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <AppKit/NSView.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSView *v;

  START_SET("NSView userInterfaceLayoutDirection")

  v = AUTORELEASE([[NSView alloc] initWithFrame: NSMakeRect(0, 0, 10, 10)]);
  PASS([v userInterfaceLayoutDirection]
    == NSUserInterfaceLayoutDirectionLeftToRight,
    "a view lays out left to right by default");
  [v setUserInterfaceLayoutDirection: NSUserInterfaceLayoutDirectionRightToLeft];
  PASS([v userInterfaceLayoutDirection]
    == NSUserInterfaceLayoutDirectionRightToLeft,
    "a view keeps a right to left direction");
  [v setUserInterfaceLayoutDirection: NSUserInterfaceLayoutDirectionLeftToRight];
  PASS([v userInterfaceLayoutDirection]
    == NSUserInterfaceLayoutDirectionLeftToRight,
    "the direction can be set back");

  END_SET("NSView userInterfaceLayoutDirection")

  [pool release];
  return 0;
}
