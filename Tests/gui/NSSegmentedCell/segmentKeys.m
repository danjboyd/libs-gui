/* -makeNextSegmentKey and -makePreviousSegmentKey move the selection to the
   next or previous segment, wrapping around at either end, and select the
   first or last segment when nothing is selected.  They used to raise past
   the last segment, stop at the first one, and raise when nothing was
   selected.  The cell touches the font backend, so the set is skipped when
   the backend is unavailable.
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

  START_SET("NSSegmentedCell segment keys")

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
  PASS_RUNS([cell makeNextSegmentKey],
    "makeNextSegmentKey does nothing on a cell without segments");

  [cell setSegmentCount: 3];
  PASS_RUNS([cell makeNextSegmentKey],
    "makeNextSegmentKey does not raise without a selection");
  PASS([cell selectedSegment] == 0,
    "makeNextSegmentKey selects the first segment without a selection");

  [cell makeNextSegmentKey];
  PASS([cell selectedSegment] == 1, "makeNextSegmentKey selects the next segment");
  [cell makeNextSegmentKey];
  PASS_RUNS([cell makeNextSegmentKey],
    "makeNextSegmentKey does not raise on the last segment");
  PASS([cell selectedSegment] == 0,
    "makeNextSegmentKey wraps around after the last segment");
  PASS([cell isSelectedForSegment: 2] == NO,
    "the segment left behind is deselected");

  PASS_RUNS([cell makePreviousSegmentKey],
    "makePreviousSegmentKey does not raise on the first segment");
  PASS([cell selectedSegment] == 2,
    "makePreviousSegmentKey wraps around before the first segment");
  [cell makePreviousSegmentKey];
  PASS([cell selectedSegment] == 1,
    "makePreviousSegmentKey selects the previous segment");

  [cell setSelected: NO forSegment: 1];
  PASS_RUNS([cell makePreviousSegmentKey],
    "makePreviousSegmentKey does not raise without a selection");
  PASS([cell selectedSegment] == 2,
    "makePreviousSegmentKey selects the last segment without a selection");

  [cell setSegmentCount: 2];
  PASS([cell selectedSegment] == -1,
    "removing the selected segment leaves no selection");
  PASS_RUNS([cell makeNextSegmentKey],
    "makeNextSegmentKey does not raise after the selected segment is removed");
  PASS([cell selectedSegment] == 0,
    "makeNextSegmentKey then selects the first segment");

  END_SET("NSSegmentedCell segment keys")

  [pool release];
  return 0;
}
