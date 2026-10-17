/* -[NSCollectionView scrollToItemsAtIndexPaths:scrollPosition:] scrolls the
   enclosing scroll view so that the items are visible.  It used to be empty.
   The view uses the theme and font backend, so the set is skipped when the
   backend is unavailable.
*/
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSGeometry.h>
#include <Foundation/NSIndexPath.h>
#include <Foundation/NSSet.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSCollectionView.h>
#include <AppKit/NSCollectionViewFlowLayout.h>
#include <AppKit/NSCollectionViewItem.h>
#include <AppKit/NSScrollView.h>
#include <AppKit/NSView.h>
#include <AppKit/NSWindow.h>

/* The flow layout answers the view's own size as its content size; give the
   view room for every item, as a layout that sizes its content does. */
@interface TallLayout : NSCollectionViewFlowLayout
@end
@implementation TallLayout
- (NSSize) collectionViewContentSize
{
  return NSMakeSize(180, 6000);
}
@end

@interface Source : NSObject <NSCollectionViewDataSource>
@end
@implementation Source
- (NSInteger) collectionView: (NSCollectionView *)cv
       numberOfItemsInSection: (NSInteger)section
{
  return 100;
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
@end

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSWindow *window;
  NSScrollView *scrollView;
  NSCollectionView *cv;
  NSIndexPath *last;
  NSRect frame;

  START_SET("NSCollectionView scrollToItemsAtIndexPaths:scrollPosition:")

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

  window = AUTORELEASE([[NSWindow alloc]
    initWithContentRect: NSMakeRect(0, 0, 200, 100)
	      styleMask: NSBorderlessWindowMask
		backing: NSBackingStoreBuffered
		  defer: YES]);
  [window setReleasedWhenClosed: NO];
  scrollView = AUTORELEASE([[NSScrollView alloc]
    initWithFrame: NSMakeRect(0, 0, 200, 100)]);
  [scrollView setHasVerticalScroller: YES];
  [window setContentView: scrollView];
  cv = AUTORELEASE([[NSCollectionView alloc]
    initWithFrame: NSMakeRect(0, 0, 180, 100)]);
  [cv setCollectionViewLayout: AUTORELEASE([[TallLayout alloc] init])];
  [scrollView setDocumentView: cv];
  [cv setDataSource: AUTORELEASE([Source new])];
  [cv reloadData];

  last = [NSIndexPath indexPathForItem: 99 inSection: 0];
  frame = [[[cv itemAtIndexPath: last] view] frame];
  PASS(NSContainsRect([scrollView documentVisibleRect], frame) == NO,
    "the last item starts out of view");

  [cv scrollToItemsAtIndexPaths: [NSSet setWithObject: last]
		 scrollPosition: NSCollectionViewScrollPositionNone];
  PASS(NSContainsRect([scrollView documentVisibleRect], frame),
    "the item is scrolled into view");

  [cv scrollToItemsAtIndexPaths: [NSSet setWithObject:
    [NSIndexPath indexPathForItem: 0 inSection: 0]]
		 scrollPosition: NSCollectionViewScrollPositionTop];
  PASS(NSContainsRect([scrollView documentVisibleRect],
    [[[cv itemAtIndexPath: [NSIndexPath indexPathForItem: 0 inSection: 0]]
      view] frame]),
    "the first item is scrolled back into view");

  PASS_RUNS([cv scrollToItemsAtIndexPaths: [NSSet set]
			   scrollPosition: NSCollectionViewScrollPositionNone],
    "no items is accepted");

  END_SET("NSCollectionView scrollToItemsAtIndexPaths:scrollPosition:")

  [pool release];
  return 0;
}
