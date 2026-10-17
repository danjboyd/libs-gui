/* -[NSCollectionView moveItemAtIndexPath:toIndexPath:] and
   -moveSection:toSection: are sent after the data source has moved an item
   or a section; the collection view then shows the items at their new index
   paths.  A moved item keeps its item object and view, as on Cocoa.  Both
   methods used to be empty, so the view kept the items it had loaded at
   their old index paths.
   The view uses the theme and font backend, so the set is skipped when the
   backend is unavailable.
*/
#include "Testing.h"

#include <Foundation/NSArray.h>
#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSGeometry.h>
#include <Foundation/NSIndexPath.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSCollectionView.h>
#include <AppKit/NSCollectionViewFlowLayout.h>
#include <AppKit/NSCollectionViewItem.h>
#include <AppKit/NSView.h>

@interface Source : NSObject <NSCollectionViewDataSource>
{
@public
  NSMutableArray *sections;
}
@end
@implementation Source
- (NSInteger) numberOfSectionsInCollectionView: (NSCollectionView *)cv
{
  return [sections count];
}
- (NSInteger) collectionView: (NSCollectionView *)cv
       numberOfItemsInSection: (NSInteger)section
{
  return [[sections objectAtIndex: section] count];
}
- (NSCollectionViewItem *) collectionView: (NSCollectionView *)cv
        itemForRepresentedObjectAtIndexPath: (NSIndexPath *)indexPath
{
  NSCollectionViewItem *item = AUTORELEASE([[NSCollectionViewItem alloc] init]);
  NSView *view = [[NSView alloc] initWithFrame: NSMakeRect(0, 0, 40, 30)];

  [item setView: view];
  RELEASE(view);
  [item setRepresentedObject: [[sections objectAtIndex: [indexPath section]]
    objectAtIndex: [indexPath item]]];
  return item;
}
@end

static NSCollectionViewItem *
itemAt(NSCollectionView *cv, NSInteger item, NSInteger section)
{
  return [cv itemAtIndexPath:
    [NSIndexPath indexPathForItem: item inSection: section]];
}

static id
objectAt(NSCollectionView *cv, NSInteger item, NSInteger section)
{
  return [[cv itemAtIndexPath:
    [NSIndexPath indexPathForItem: item inSection: section]]
    representedObject];
}

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSCollectionView *cv;
  Source *source;
  NSMutableArray *first;
  NSMutableArray *second;
  NSCollectionViewItem *a;
  NSCollectionViewItem *x;
  NSCollectionViewItem *y;

  START_SET("NSCollectionView moving items and sections")

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

  first = [NSMutableArray arrayWithObjects: @"a", @"b", @"c", nil];
  second = [NSMutableArray arrayWithObjects: @"x", @"y", nil];
  source = AUTORELEASE([Source new]);
  source->sections = [NSMutableArray arrayWithObjects: first, second, nil];
  cv = AUTORELEASE([[NSCollectionView alloc]
    initWithFrame: NSMakeRect(0, 0, 400, 300)]);
  [cv setCollectionViewLayout:
    AUTORELEASE([[NSCollectionViewFlowLayout alloc] init])];
  [cv setDataSource: source];
  [cv reloadData];
  PASS_EQUAL(objectAt(cv, 0, 0), @"a", "the first item is loaded");
  a = itemAt(cv, 0, 0);
  x = itemAt(cv, 0, 1);
  y = itemAt(cv, 1, 1);

  /* Move "a" to the end of its section. */
  [first removeObjectAtIndex: 0];
  [first addObject: @"a"];
  [cv moveItemAtIndexPath: [NSIndexPath indexPathForItem: 0 inSection: 0]
	      toIndexPath: [NSIndexPath indexPathForItem: 2 inSection: 0]];
  PASS_EQUAL(objectAt(cv, 0, 0), @"b",
    "the item after a moved item takes its index path");
  PASS_EQUAL(objectAt(cv, 2, 0), @"a",
    "a moved item is at its new index path");
  PASS(itemAt(cv, 2, 0) == a, "a moved item keeps its item object");
  PASS_EQUAL([cv indexPathForItem: a],
    [NSIndexPath indexPathForItem: 2 inSection: 0],
    "a moved item answers its new index path");
  /* The flow layout counts reflowed rows as it is asked, so the frame it
     gives an index path changes from one call to the next; check only
     that the view stays in the collection view. */
  PASS([[a view] superview] == cv, "a moved item's view stays in the view");

  /* Move "x" to the start of the first section. */
  [second removeObjectAtIndex: 0];
  [first insertObject: @"x" atIndex: 0];
  [cv moveItemAtIndexPath: [NSIndexPath indexPathForItem: 0 inSection: 1]
	      toIndexPath: [NSIndexPath indexPathForItem: 0 inSection: 0]];
  PASS_EQUAL(objectAt(cv, 0, 0), @"x",
    "an item moved to another section is at its new index path");
  PASS(itemAt(cv, 0, 0) == x, "an item moved to another section is kept");
  PASS_EQUAL(objectAt(cv, 0, 1), @"y",
    "the section an item left shows its remaining items");
  PASS(objectAt(cv, 1, 1) == nil,
    "the section an item left has no item past its end");
  PASS([[cv visibleItems] count] == 5, "the view still holds five items");

  /* Swap the sections. */
  [source->sections exchangeObjectAtIndex: 0 withObjectAtIndex: 1];
  [cv moveSection: 1 toSection: 0];
  PASS_EQUAL(objectAt(cv, 0, 0), @"y",
    "a moved section's items are at its new index");
  PASS(itemAt(cv, 0, 0) == y, "a moved section keeps its items");
  PASS_EQUAL(objectAt(cv, 0, 1), @"x",
    "the displaced section's items are at its new index");
  PASS([[cv visibleItems] count] == 5,
    "moving a section keeps the number of items");

  END_SET("NSCollectionView moving items and sections")

  [pool release];
  return 0;
}
