/* NSTableHeaderCell draws its sort indicators from the standard images, so
   the images must exist, or nothing is drawn. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSGeometry.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSImage.h>
#include <AppKit/NSTableHeaderCell.h>

int
main(int argc, char **argv)
{
  NSTableHeaderCell *cell;
  NSRect rect;

  START_SET("NSTableHeaderCell sort indicator")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  PASS([NSImage imageNamed: @"NSAscendingSortIndicator"] != nil,
    "the ascending indicator image exists");
  PASS([NSImage imageNamed: @"NSDescendingSortIndicator"] != nil,
    "the descending indicator image exists");
  PASS([NSImage imageNamed: @"NSAscendingSortIndicator"]
    != [NSImage imageNamed: @"NSDescendingSortIndicator"],
    "the two indicators differ");

  cell = AUTORELEASE([[NSTableHeaderCell alloc] initTextCell: @"Header"]);
  rect = [cell sortIndicatorRectForBounds: NSMakeRect(0, 0, 96, 24)];
  PASS(rect.size.width > 0 && rect.size.height > 0,
    "the indicator rectangle isn't empty");
  PASS(NSMaxX(rect) == 96, "the indicator is at the right of the bounds");

  END_SET("NSTableHeaderCell sort indicator")

  return 0;
}
