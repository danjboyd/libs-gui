/* NSCollectionViewFlowLayout asks a delegate that implements
   collectionView:layout:minimumLineSpacingForSectionAtIndex: and
   collectionView:layout:minimumInteritemSpacingForSectionAtIndex: for the
   spacing of a section, instead of using its own. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSGeometry.h>
#include <Foundation/NSIndexPath.h>

#include <AppKit/NSApplication.h>
#include <AppKit/NSCollectionView.h>
#include <AppKit/NSCollectionViewFlowLayout.h>
#include <AppKit/NSCollectionViewLayout.h>

@interface SpacingDelegate : NSObject
{
@public
  int lineAsked;
  int interitemAsked;
}
@end

@implementation SpacingDelegate
- (CGFloat) collectionView: (NSCollectionView *)cv
                    layout: (NSCollectionViewLayout *)layout
minimumLineSpacingForSectionAtIndex: (NSInteger)section
{
  lineAsked++;
  return 30.0;
}

- (CGFloat) collectionView: (NSCollectionView *)cv
                    layout: (NSCollectionViewLayout *)layout
minimumInteritemSpacingForSectionAtIndex: (NSInteger)section
{
  interitemAsked++;
  return 20.0;
}
@end

int main()
{
  CREATE_AUTORELEASE_POOL(arp);
  NSCollectionView *cv;
  NSCollectionViewFlowLayout *l;
  SpacingDelegate *d;
  NSCollectionViewLayoutAttributes *a;
  NSRect f;

  START_SET("NSCollectionViewFlowLayout delegateSpacing")

  NS_DURING
    [NSApplication sharedApplication];
  NS_HANDLER
    if ([[localException name] isEqualToString: NSInternalInconsistencyException])
      SKIP("It looks like GNUstep backend is not yet installed")
  NS_ENDHANDLER

  cv = AUTORELEASE([[NSCollectionView alloc]
    initWithFrame: NSMakeRect(0, 0, 400, 400)]);
  l = AUTORELEASE([[NSCollectionViewFlowLayout alloc] init]);
  d = AUTORELEASE([[SpacingDelegate alloc] init]);
  [l setSectionInset: NSEdgeInsetsMake(0, 0, 0, 0)];
  [cv setDelegate: (id<NSCollectionViewDelegate>)d];
  [l setCollectionView: cv];

  a = [l layoutAttributesForItemAtIndexPath:
    [NSIndexPath indexPathForItem: 0 inSection: 0]];
  f = [a frame];
  PASS(d->lineAsked > 0,
       "the delegate is asked for the minimum line spacing");
  PASS(d->interitemAsked > 0,
       "the delegate is asked for the minimum interitem spacing");
  PASS(f.origin.y == 30.0,
       "the item is placed with the delegate's line spacing");
  PASS(f.origin.x == 20.0,
       "the item is placed with the delegate's interitem spacing");

  END_SET("NSCollectionViewFlowLayout delegateSpacing")

  DESTROY(arp);
  return 0;
}
