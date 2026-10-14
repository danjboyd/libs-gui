/* NSCollectionViewLayoutAttributes retains its index path, and a copy is a
   new object of the receiver's class with the receiver's values.  The index
   path used to be stored without being retained, and -copyWithZone: built a
   copy and returned the receiver instead, leaking the copy.
*/
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSGeometry.h>
#include <Foundation/NSIndexPath.h>

#include <AppKit/NSCollectionViewLayout.h>

@interface Attributes : NSCollectionViewLayoutAttributes
@end
@implementation Attributes
@end

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSCollectionViewLayoutAttributes *attrs;
  NSCollectionViewLayoutAttributes *copy;
  NSIndexPath *path;
  NSUInteger count;

  START_SET("NSCollectionViewLayoutAttributes ownership")

  path = [NSIndexPath indexPathForItem: 3 inSection: 1];
  attrs = AUTORELEASE([[Attributes alloc] init]);
  count = [path retainCount];
  [attrs setIndexPath: path];
  PASS([path retainCount] == count + 1,
    "setIndexPath: retains the index path");
  [attrs setIndexPath: nil];
  PASS([path retainCount] == count,
    "replacing the index path releases the old one");

  [attrs setIndexPath: path];
  [attrs setFrame: NSMakeRect(1, 2, 30, 40)];
  [attrs setAlpha: 0.5];
  [attrs setZIndex: 7];
  [attrs setHidden: YES];
  copy = AUTORELEASE([attrs copy]);
  PASS(copy != attrs, "a copy is a new object");
  PASS([copy isKindOfClass: [Attributes class]],
    "a copy has the receiver's class");
  PASS([[copy indexPath] isEqual: path], "a copy has the index path");
  PASS(NSEqualRects([copy frame], NSMakeRect(1, 2, 30, 40)),
    "a copy has the frame");
  PASS([copy alpha] == 0.5, "a copy has the alpha");
  PASS([copy zIndex] == 7, "a copy has the z index");
  PASS([copy isHidden], "a copy has the hidden flag");
  PASS([copy representedElementCategory]
    == [attrs representedElementCategory],
    "a copy has the represented element category");

  END_SET("NSCollectionViewLayoutAttributes ownership")

  [pool release];
  return 0;
}
