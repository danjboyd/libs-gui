/* An NSCollectionViewLayoutInvalidationContext records the index paths it is
   told to invalidate: the items' in invalidatedItemIndexPaths, and the
   supplementary and decoration elements' by element kind in
   invalidatedSupplementaryIndexPaths and invalidatedDecorationIndexPaths.
   The three -invalidate... methods used to be empty, so the getters always
   answered nil.
*/
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSDictionary.h>
#include <Foundation/NSIndexPath.h>
#include <Foundation/NSSet.h>

#include <AppKit/NSCollectionViewLayout.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSCollectionViewLayoutInvalidationContext *context;
  NSIndexPath *a = [NSIndexPath indexPathForItem: 0 inSection: 0];
  NSIndexPath *b = [NSIndexPath indexPathForItem: 1 inSection: 0];
  NSIndexPath *c = [NSIndexPath indexPathForItem: 0 inSection: 1];
  NSSet *ab = [NSSet setWithObjects: a, b, nil];

  START_SET("NSCollectionViewLayoutInvalidationContext index paths")

  context = AUTORELEASE([NSCollectionViewLayoutInvalidationContext new]);
  PASS([context invalidatedItemIndexPaths] == nil,
    "a new context has no invalidated items");

  [context invalidateItemsAtIndexPaths: [NSSet setWithObject: a]];
  [context invalidateItemsAtIndexPaths: [NSSet setWithObjects: b, a, nil]];
  PASS_EQUAL([context invalidatedItemIndexPaths], ab,
    "the invalidated items accumulate");

  [context invalidateSupplementaryElementsOfKind: @"Header"
    atIndexPaths: [NSSet setWithObject: a]];
  [context invalidateSupplementaryElementsOfKind: @"Header"
    atIndexPaths: [NSSet setWithObject: b]];
  [context invalidateSupplementaryElementsOfKind: @"Footer"
    atIndexPaths: [NSSet setWithObject: c]];
  PASS_EQUAL([[context invalidatedSupplementaryIndexPaths]
    objectForKey: @"Header"], ab,
    "supplementary index paths accumulate by kind");
  PASS_EQUAL([[context invalidatedSupplementaryIndexPaths]
    objectForKey: @"Footer"], [NSSet setWithObject: c],
    "each supplementary kind has its own index paths");
  PASS([[context invalidatedSupplementaryIndexPaths] count] == 2,
    "only the invalidated supplementary kinds are recorded");

  PASS([context invalidatedDecorationIndexPaths] == nil,
    "no decoration is invalidated yet");
  [context invalidateDecorationElementsOfKind: @"Badge"
    atIndexPaths: [NSSet setWithObject: c]];
  PASS_EQUAL([context invalidatedDecorationIndexPaths],
    [NSDictionary dictionaryWithObject: [NSSet setWithObject: c]
                                forKey: @"Badge"],
    "decoration index paths are recorded by kind");

  END_SET("NSCollectionViewLayoutInvalidationContext index paths")

  [pool release];
  return 0;
}
