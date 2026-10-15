/* The NSCollectionViewLayoutAttributes factories answer opaque attributes
   for their element's category, kind and index path, and attributes are
   opaque by default.  All four factories answered nil, and -init left the
   alpha at 0.  Layout attributes need no backend. */
#include "Testing.h"

#include <Foundation/NSAutoreleasePool.h>
#include <Foundation/NSIndexPath.h>
#include <AppKit/NSCollectionView.h>
#include <AppKit/NSCollectionViewLayout.h>

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSIndexPath *path = [NSIndexPath indexPathForItem: 2 inSection: 1];
  NSCollectionViewLayoutAttributes *a;

  START_SET("NSCollectionViewLayoutAttributes factories")

  a = [NSCollectionViewLayoutAttributes layoutAttributesForItemWithIndexPath: path];
  PASS(a != nil && [[a indexPath] isEqual: path] && [a alpha] == 1.0
    && [a representedElementCategory] == NSCollectionElementCategoryItem
    && [a representedElementKind] == nil,
    "item attributes have the item category and index path");

  a = [NSCollectionViewLayoutAttributes
    layoutAttributesForInterItemGapBeforeIndexPath: path];
  PASS(a != nil && [[a indexPath] isEqual: path]
    && [a representedElementCategory] == NSCollectionElementCategoryInterItemGap,
    "gap attributes have the gap category and index path");

  a = [NSCollectionViewLayoutAttributes
    layoutAttributesForSupplementaryViewOfKind: @"header" withIndexPath: path];
  PASS(a != nil && [[a representedElementKind] isEqual: @"header"]
    && [a representedElementCategory]
      == NSCollectionElementCategorySupplementaryView,
    "supplementary attributes have their kind");

  a = [NSCollectionViewLayoutAttributes
    layoutAttributesForDecorationViewOfKind: @"badge" withIndexPath: path];
  PASS(a != nil && [[a representedElementKind] isEqual: @"badge"]
    && [a representedElementCategory]
      == NSCollectionElementCategoryDecorationView,
    "decoration attributes have their kind");

  a = AUTORELEASE([[NSCollectionViewLayoutAttributes alloc] init]);
  PASS([a alpha] == 1.0, "attributes made with -init are opaque");

  END_SET("NSCollectionViewLayoutAttributes factories")

  [pool release];
  return 0;
}
