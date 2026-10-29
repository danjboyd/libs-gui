/* -[NSCollectionView insertItemsAtIndexPaths:], -deleteItemsAtIndexPaths:,
   -insertSections: and -deleteSections: are sent after the data source has
   changed; the collection view then shows the items the data source now
   has.  All four methods used to be empty, so the view kept the items it
   had loaded.
   The view uses the theme and font backend, so the set is skipped when the
   backend is unavailable.
*/
#include "Testing.h"

#include <Foundation/NSArray.h>
#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSGeometry.h>
#include <Foundation/NSIndexPath.h>
#include <Foundation/NSIndexSet.h>
#include <Foundation/NSSet.h>

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

static id
objectAt(NSCollectionView *cv, NSInteger item, NSInteger section)
{
  return [[cv itemAtIndexPath:
    [NSIndexPath indexPathForItem: item inSection: section]]
    representedObject];
}

static NSSet *
pathSet(NSInteger item, NSInteger section)
{
  return [NSSet setWithObject:
    [NSIndexPath indexPathForItem: item inSection: section]];
}

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSCollectionView *cv;
  Source *source;
  NSMutableArray *first;

  START_SET("NSCollectionView inserting and deleting items and sections")

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
  source = AUTORELEASE([Source new]);
  source->sections = [NSMutableArray arrayWithObjects: first,
    [NSMutableArray arrayWithObjects: @"x", @"y", nil], nil];
  cv = AUTORELEASE([[NSCollectionView alloc]
    initWithFrame: NSMakeRect(0, 0, 400, 300)]);
  [cv setCollectionViewLayout:
    AUTORELEASE([[NSCollectionViewFlowLayout alloc] init])];
  [cv setDataSource: source];
  [cv reloadData];
  PASS([[cv visibleItems] count] == 5, "the view loads five items");

  [first insertObject: @"n" atIndex: 1];
  [cv insertItemsAtIndexPaths: pathSet(1, 0)];
  PASS_EQUAL(objectAt(cv, 1, 0), @"n", "an inserted item is loaded");
  PASS_EQUAL(objectAt(cv, 3, 0), @"c",
    "the items after an inserted item move down");
  PASS([[cv visibleItems] count] == 6, "inserting an item adds one item");

  [first removeObjectAtIndex: 0];
  [cv deleteItemsAtIndexPaths: pathSet(0, 0)];
  PASS_EQUAL(objectAt(cv, 0, 0), @"n",
    "the item after a deleted item takes its index path");
  PASS(objectAt(cv, 3, 0) == nil, "no item is left past the section's end");
  PASS([[cv visibleItems] count] == 5, "deleting an item removes one item");

  [source->sections insertObject: [NSMutableArray arrayWithObject: @"s"]
			 atIndex: 1];
  [cv insertSections: [NSIndexSet indexSetWithIndex: 1]];
  PASS_EQUAL(objectAt(cv, 0, 1), @"s", "an inserted section is loaded");
  PASS_EQUAL(objectAt(cv, 1, 2), @"y",
    "the sections after an inserted section move down");
  PASS([[cv visibleItems] count] == 6, "inserting a section adds its items");

  [source->sections removeObjectAtIndex: 0];
  [cv deleteSections: [NSIndexSet indexSetWithIndex: 0]];
  PASS_EQUAL(objectAt(cv, 0, 0), @"s",
    "the section after a deleted section takes its index");
  PASS(objectAt(cv, 0, 2) == nil, "no section is left past the last one");
  PASS([[cv visibleItems] count] == 3, "deleting a section removes its items");

  END_SET("NSCollectionView inserting and deleting items and sections")

  [pool release];
  return 0;
}
