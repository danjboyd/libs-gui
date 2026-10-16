/* A collection view tells its delegate
   collectionView:willDisplayItem:forRepresentedObjectAtIndexPath: for
   each item it displays, and
   collectionView:didEndDisplayingItem:forRepresentedObjectAtIndexPath:
   for each item it removes, when it reloads all its data or a section.
   Loading and unloading items used to tell the delegate nothing.  The
   view uses the theme and font backend, so the set is skipped when the
   backend is unavailable. */
#include "Testing.h"

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

@interface Source : NSObject <NSCollectionViewDataSource, NSCollectionViewDelegate>
{
@public
  NSMutableSet *displayed;
  NSMutableSet *ended;
  BOOL viewAdded;
}
@end
@implementation Source
- (id) init
{
  if ((self = [super init]) != nil)
    {
      displayed = [NSMutableSet new];
      ended = [NSMutableSet new];
    }
  return self;
}
- (void) dealloc
{
  RELEASE(displayed);
  RELEASE(ended);
  [super dealloc];
}
- (NSInteger) numberOfSectionsInCollectionView: (NSCollectionView *)cv
{
  return 2;
}
- (NSInteger) collectionView: (NSCollectionView *)cv
       numberOfItemsInSection: (NSInteger)section
{
  return section == 0 ? 3 : 2;
}
- (NSCollectionViewItem *) collectionView: (NSCollectionView *)cv
        itemForRepresentedObjectAtIndexPath: (NSIndexPath *)indexPath
{
  NSCollectionViewItem *item = AUTORELEASE([[NSCollectionViewItem alloc] init]);
  NSView *view = [[NSView alloc] initWithFrame: NSMakeRect(0, 0, 40, 30)];

  [item setView: view];
  RELEASE(view);
  return item;
}
- (void) collectionView: (NSCollectionView *)cv
        willDisplayItem: (NSCollectionViewItem *)item
        forRepresentedObjectAtIndexPath: (NSIndexPath *)indexPath
{
  if ([[item view] superview] == cv)
    {
      viewAdded = YES;
    }
  [displayed addObject: indexPath];
}
- (void) collectionView: (NSCollectionView *)cv
   didEndDisplayingItem: (NSCollectionViewItem *)item
   forRepresentedObjectAtIndexPath: (NSIndexPath *)indexPath
{
  [ended addObject: indexPath];
}
@end

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSCollectionView *cv;
  Source *source;

  START_SET("NSCollectionView display delegate")

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
  cv = AUTORELEASE([[NSCollectionView alloc]
    initWithFrame: NSMakeRect(0, 0, 400, 300)]);
  [cv setCollectionViewLayout:
    AUTORELEASE([[NSCollectionViewFlowLayout alloc] init])];
  [cv setDelegate: source];
  [cv setDataSource: source];
  [source->displayed removeAllObjects];
  [source->ended removeAllObjects];
  [cv reloadData];
  PASS([source->displayed count] == 5,
    "the delegate is told of each item displayed");
  PASS(source->viewAdded == NO,
    "the delegate is told before the item's view is added");

  [source->displayed removeAllObjects];
  [source->ended removeAllObjects];
  [cv reloadSections: [NSIndexSet indexSetWithIndex: 1]];
  PASS([source->ended count] == 2
    && [source->ended containsObject: [NSIndexPath indexPathForItem: 1 inSection: 1]],
    "reloading a section ends displaying its items");
  PASS([source->displayed count] == 2,
    "and displays its new items");

  [source->ended removeAllObjects];
  [cv reloadData];
  PASS([source->ended count] == 5,
    "reloading the data ends displaying every item");

  END_SET("NSCollectionView display delegate")

  [pool release];
  return 0;
}
