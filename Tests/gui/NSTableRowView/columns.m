/* A row view on its own holds one view per column, in column order, so its
 * column count is the number of its views and -viewAtColumn: answers the
 * view at that index.  Both were stubs answering 0 and nil.  (Inside a
 * table view the table answers for its columns.)
 */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSGeometry.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSTableRowView.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSTableRowView *row;
  NSView *a;
  NSView *b;

  START_SET("NSTableRowView columns")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  row = AUTORELEASE([[NSTableRowView alloc]
    initWithFrame: NSMakeRect(0, 0, 200, 20)]);
  a = AUTORELEASE([[NSView alloc] initWithFrame: NSMakeRect(0, 0, 100, 20)]);
  b = AUTORELEASE([[NSView alloc] initWithFrame: NSMakeRect(100, 0, 100, 20)]);
  [row addSubview: a];
  [row addSubview: b];

  PASS([row numberOfColumns] == 2, "a row view counts its column views");
  PASS([row viewAtColumn: 0] == a && [row viewAtColumn: 1] == b,
    "a row view answers the view of each column");
  PASS([row viewAtColumn: 2] == nil && [row viewAtColumn: -1] == nil,
    "a row view answers no view for a column it does not have");

  END_SET("NSTableRowView columns")

  [pool release];
  return 0;
}
