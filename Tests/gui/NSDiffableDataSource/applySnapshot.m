/* -applySnapshot:animatingDifferences: installs a copy of the snapshot it
   is given, so the data source answers for its sections and items, and
   later changes to the caller's snapshot do not show.  Both the table and
   the collection view data sources used to install an empty snapshot
   instead.  The views need the backend, so the set is skipped without it.
*/
#include "Testing.h"

#include <Foundation/NSArray.h>
#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSIndexPath.h>
#include <Foundation/NSString.h>
#include <AppKit/NSApplication.h>
#include <AppKit/NSCollectionView.h>
#include <AppKit/NSDiffableDataSource.h>
#include <AppKit/NSTableColumn.h>
#include <AppKit/NSTableView.h>

static NSDiffableDataSourceSnapshot *
makeSnapshot(void)
{
  NSDiffableDataSourceSnapshot *s;

  s = AUTORELEASE([[NSDiffableDataSourceSnapshot alloc] init]);
  [s appendSectionsWithIdentifiers:
    [NSArray arrayWithObjects: @"S1", @"S2", nil]];
  [s appendItemsWithIdentifiers: [NSArray arrayWithObjects: @"A", @"B", nil]
      intoSectionWithIdentifier: @"S1"];
  [s appendItemsWithIdentifiers: [NSArray arrayWithObject: @"C"]
      intoSectionWithIdentifier: @"S2"];
  return s;
}

int main()
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSIndexPath *pathC = [NSIndexPath indexPathForItem: 0 inSection: 1];
  NSDiffableDataSourceSnapshot *s;

  START_SET("NSDiffableDataSource applySnapshot:animatingDifferences:")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  {
    NSTableView *tv = AUTORELEASE([[NSTableView alloc]
      initWithFrame: NSMakeRect(0, 0, 200, 200)]);
    NSTableViewDiffableDataSource *ds;

    [tv addTableColumn: AUTORELEASE([[NSTableColumn alloc]
      initWithIdentifier: @"c"])];
    ds = AUTORELEASE([[NSTableViewDiffableDataSource alloc]
      initWithTableView: tv cellProvider: NULL]);
    s = makeSnapshot();
    [ds applySnapshot: s animatingDifferences: NO];
    [s appendItemsWithIdentifiers: [NSArray arrayWithObject: @"D"]
        intoSectionWithIdentifier: @"S2"];

    PASS([[ds snapshot] numberOfSections] == 2
      && [[ds snapshot] numberOfItems] == 3,
      "a table data source holds the applied snapshot, not the caller's");
    PASS_EQUAL([ds indexPathForItemIdentifier: @"C"], pathC,
      "a table data source finds the index path of an item");
    PASS_EQUAL([ds itemIdentifierForIndexPath: pathC], @"C",
      "a table data source finds the item at an index path");
  }

  {
    NSCollectionView *cv = AUTORELEASE([[NSCollectionView alloc]
      initWithFrame: NSMakeRect(0, 0, 200, 200)]);
    NSCollectionViewDiffableDataSource *ds;

    ds = AUTORELEASE([[NSCollectionViewDiffableDataSource alloc]
      initWithCollectionView: cv itemProvider: NULL]);
    s = makeSnapshot();
    [ds applySnapshot: s animatingDifferences: NO];
    [s deleteSectionsWithIdentifiers: [NSArray arrayWithObject: @"S2"]];

    PASS([[ds snapshot] numberOfSections] == 2
      && [ds numberOfSectionsInCollectionView: cv] == 2,
      "a collection data source holds the applied snapshot, not the caller's");
    PASS_EQUAL([ds indexPathForItemIdentifier: @"C"], pathC,
      "a collection data source finds the index path of an item");
    PASS_EQUAL([ds itemIdentifierForIndexPath: pathC], @"C",
      "a collection data source finds the item at an index path");
  }

  END_SET("NSDiffableDataSource applySnapshot:animatingDifferences:")

  [pool release];
  return 0;
}
