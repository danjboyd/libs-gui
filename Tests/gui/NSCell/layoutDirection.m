/* A cell keeps its user interface layout direction, left to right by
   default.  The setter was a stub, so the direction always read as left to
   right.  Cells need no backend for this. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <AppKit/NSCell.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSCell *c;

  START_SET("NSCell userInterfaceLayoutDirection")

  c = AUTORELEASE([[NSCell alloc] initTextCell: @"x"]);
  PASS([c userInterfaceLayoutDirection]
    == NSUserInterfaceLayoutDirectionLeftToRight,
    "a cell lays out left to right by default");
  [c setUserInterfaceLayoutDirection: NSUserInterfaceLayoutDirectionRightToLeft];
  PASS([c userInterfaceLayoutDirection]
    == NSUserInterfaceLayoutDirectionRightToLeft,
    "a cell keeps a right to left direction");
  PASS([AUTORELEASE([c copy]) userInterfaceLayoutDirection]
    == NSUserInterfaceLayoutDirectionRightToLeft,
    "a copy keeps the direction");

  END_SET("NSCell userInterfaceLayoutDirection")

  [pool release];
  return 0;
}
