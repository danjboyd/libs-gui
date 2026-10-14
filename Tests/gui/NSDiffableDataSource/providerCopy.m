/* A table diffable data source keeps its own copy of its cell provider
   block, so a block that lived on the stack, or that its caller released,
   can still be called once the call that made the data source is over.
   The block used to be retained, which leaves a stack block dangling.  The
   collection view data source does the same with its item provider.  The
   views need the backend, so the set is skipped without it.
*/
#include "Testing.h"

#include <Foundation/NSArray.h>
#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSString.h>
#include <AppKit/NSApplication.h>
#include <AppKit/NSDiffableDataSource.h>
#include <AppKit/NSTableColumn.h>
#include <AppKit/NSTableView.h>
#include <AppKit/NSView.h>

#if __has_feature(blocks)
static NSView *marker = nil;

static NSTableViewDiffableDataSource *
makeDataSource(NSTableView *tv, int *calls)
{
  NSView *view = marker;

  /* A block capturing local variables starts out on the stack.  */
  return AUTORELEASE([[NSTableViewDiffableDataSource alloc]
    initWithTableView: tv
	 cellProvider: ^NSView *(NSTableView *t, NSTableColumn *c,
				 NSInteger row, id item)
	   {
	     (*calls)++;
	     return view;
	   }]);
}
#endif

int main()
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];

  START_SET("NSDiffableDataSource provider copy")

#if __has_feature(blocks)
  NSTableView *tv;
  NSTableColumn *col;
  NSTableViewDiffableDataSource *ds;
  NSDiffableDataSourceSnapshot *s;
  int calls = 0;

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  marker = AUTORELEASE([[NSView alloc] initWithFrame: NSMakeRect(0, 0, 10, 10)]);
  tv = AUTORELEASE([[NSTableView alloc] initWithFrame: NSMakeRect(0, 0, 200, 200)]);
  col = AUTORELEASE([[NSTableColumn alloc] initWithIdentifier: @"c"]);
  [tv addTableColumn: col];
  ds = makeDataSource(tv, &calls);

  s = AUTORELEASE([[NSDiffableDataSourceSnapshot alloc] init]);
  [s appendSectionsWithIdentifiers: [NSArray arrayWithObject: @"S"]];
  [s appendItemsWithIdentifiers: [NSArray arrayWithObject: @"A"]
      intoSectionWithIdentifier: @"S"];
  [ds applySnapshot: s animatingDifferences: NO];

  calls = 0;
  PASS([(id)ds tableView: tv viewForTableColumn: col row: 0] == marker,
    "the cell provider still answers after the block's scope has ended");
  PASS(calls == 1, "the cell provider is called once");
#else
  SKIP("the compiler does not support blocks")
#endif

  END_SET("NSDiffableDataSource provider copy")

  [pool release];
  return 0;
}
