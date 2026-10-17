/* -[NSCollectionView performBatchUpdates:completionHandler:] runs the
   updates block, shows the data source's items as they are after it, and
   calls the completion handler with YES.  It used to be empty: neither
   block ran.
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
  NSMutableArray *objects;
}
@end
@implementation Source
- (NSInteger) collectionView: (NSCollectionView *)cv
       numberOfItemsInSection: (NSInteger)section
{
  return [objects count];
}
- (NSCollectionViewItem *) collectionView: (NSCollectionView *)cv
        itemForRepresentedObjectAtIndexPath: (NSIndexPath *)indexPath
{
  NSCollectionViewItem *item = AUTORELEASE([[NSCollectionViewItem alloc] init]);
  NSView *view = [[NSView alloc] initWithFrame: NSMakeRect(0, 0, 40, 30)];

  [item setView: view];
  RELEASE(view);
  [item setRepresentedObject: [objects objectAtIndex: [indexPath item]]];
  return item;
}
@end

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSCollectionView *cv;
  Source *source;
  __block BOOL updated = NO;
  __block BOOL completed = NO;
  __block BOOL finished = NO;

  START_SET("NSCollectionView performBatchUpdates:completionHandler:")

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
  source->objects = [NSMutableArray arrayWithObjects: @"a", @"b", nil];
  cv = AUTORELEASE([[NSCollectionView alloc]
    initWithFrame: NSMakeRect(0, 0, 400, 300)]);
  [cv setCollectionViewLayout:
    AUTORELEASE([[NSCollectionViewFlowLayout alloc] init])];
  [cv setDataSource: source];
  [cv reloadData];

  [cv performBatchUpdates: ^{
      updated = YES;
      [source->objects insertObject: @"new" atIndex: 0];
    }
	completionHandler: ^(BOOL f) {
      completed = YES;
      finished = f;
    }];
  PASS(updated, "the updates block runs");
  PASS(completed, "the completion handler is called");
  PASS(finished, "the completion handler is told the updates finished");
  PASS([[cv visibleItems] count] == 3, "the view shows the updated items");
  PASS_EQUAL([[cv itemAtIndexPath:
    [NSIndexPath indexPathForItem: 0 inSection: 0]] representedObject],
    @"new", "an inserted item is at its index path");

  PASS_RUNS([cv performBatchUpdates: nil completionHandler: nil],
    "nil blocks are accepted");

  END_SET("NSCollectionView performBatchUpdates:completionHandler:")

  [pool release];
  return 0;
}
