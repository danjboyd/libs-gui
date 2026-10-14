/* -[NSCollectionView reloadSections:] reloads the items of the given sections
   and leaves the other sections alone.  It used to hand a NULL buffer to
   -getIndexes:maxCount:inIndexRange:, so every call raised.  A reloaded
   section's old items are replaced, not kept beside the new ones.
   The view uses the theme and font backend, so the set is skipped when the
   backend is unavailable.
*/
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSGeometry.h>
#include <Foundation/NSIndexPath.h>
#include <Foundation/NSIndexSet.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSCollectionView.h>
#include <AppKit/NSCollectionViewFlowLayout.h>
#include <AppKit/NSCollectionViewItem.h>
#include <AppKit/NSView.h>

@interface Source : NSObject <NSCollectionViewDataSource>
{
@public
  NSInteger firstCount;
  NSInteger requests[2];
}
@end
@implementation Source
- (NSInteger) numberOfSectionsInCollectionView: (NSCollectionView *)cv
{
  return 2;
}
- (NSInteger) collectionView: (NSCollectionView *)cv
       numberOfItemsInSection: (NSInteger)section
{
  return section == 0 ? firstCount : 2;
}
- (NSCollectionViewItem *) collectionView: (NSCollectionView *)cv
        itemForRepresentedObjectAtIndexPath: (NSIndexPath *)indexPath
{
  NSCollectionViewItem *item = AUTORELEASE([[NSCollectionViewItem alloc] init]);
  NSView *view = [[NSView alloc] initWithFrame: NSMakeRect(0, 0, 40, 30)];

  [item setView: view];
  RELEASE(view);
  requests[[indexPath section]]++;
  return item;
}
@end

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSCollectionView *cv;
  Source *source;
  NSIndexPath *path;
  NSCollectionViewItem *old;

  START_SET("NSCollectionView reloadSections:")

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

  source = AUTORELEASE([Source new]);
  source->firstCount = 3;
  cv = AUTORELEASE([[NSCollectionView alloc]
    initWithFrame: NSMakeRect(0, 0, 400, 300)]);
  [cv setCollectionViewLayout:
    AUTORELEASE([[NSCollectionViewFlowLayout alloc] init])];
  [cv setDataSource: source];
  [cv reloadData];
  PASS([[cv visibleItems] count] == 5, "all five items are loaded");

  path = [NSIndexPath indexPathForItem: 0 inSection: 0];
  old = RETAIN([cv itemAtIndexPath: path]);
  source->requests[0] = source->requests[1] = 0;
  source->firstCount = 4;
  PASS_RUNS([cv reloadSections: [NSIndexSet indexSetWithIndex: 0]],
    "reloadSections: runs");
  PASS(source->requests[0] == 4,
    "the reloaded section's items are requested again");
  PASS(source->requests[1] == 0,
    "the other section's items are not requested");
  PASS([[cv visibleItems] count] == 6,
    "the reloaded section's old items are replaced");
  PASS([cv itemAtIndexPath: path] != old,
    "a reloaded index path has a new item");
  PASS([cv indexPathForItem: old] == nil,
    "a replaced item no longer has an index path");
  PASS([old view] != nil && [[old view] superview] == nil,
    "a replaced item's view is removed from the collection view");

  PASS_RUNS([cv reloadSections: [NSIndexSet indexSet]],
    "reloading no sections runs");
  PASS([[cv visibleItems] count] == 6,
    "reloading no sections leaves the items alone");
  RELEASE(old);

  END_SET("NSCollectionView reloadSections:")

  [pool release];
  return 0;
}
