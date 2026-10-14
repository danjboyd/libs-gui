/* -selectSegmentWithTag: with a tag no segment has leaves the selection
   unchanged, as AppKit does.  It used to select the segment past the last
   one, which raised.  The cell touches the font backend, so the set is
   skipped when the backend is unavailable.
*/
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSSegmentedCell.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSSegmentedCell *cell;

  START_SET("NSSegmentedCell selectSegmentWithTag: unknown tag")

  NS_DURING
  {
    [NSApplication sharedApplication];
  }
  NS_HANDLER
  {
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  }
  NS_ENDHANDLER

  cell = AUTORELEASE([[NSSegmentedCell alloc] init]);
  [cell setSegmentCount: 3];
  [cell setTag: 10 forSegment: 0];
  [cell setTag: 11 forSegment: 1];
  [cell setTag: 12 forSegment: 2];

  [cell selectSegmentWithTag: 11];
  PASS([cell selectedSegment] == 1,
    "selectSegmentWithTag: selects the tagged segment");
  PASS_RUNS([cell selectSegmentWithTag: 99],
    "selectSegmentWithTag: does not raise for an unknown tag");
  PASS([cell selectedSegment] == 1,
    "selectSegmentWithTag: leaves the selection for an unknown tag");

  END_SET("NSSegmentedCell selectSegmentWithTag: unknown tag")

  [pool release];
  return 0;
}
