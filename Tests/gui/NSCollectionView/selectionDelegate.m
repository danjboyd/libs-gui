/* -[NSCollectionView setSelectionIndexPaths:] asks the delegate about the
   index paths it is about to select and deselect, and applies only what the
   delegate approves.  It used to store the proposed selection before asking
   the delegate, so a delegate narrowing the selection was ignored, and it
   never sent the deselection messages.
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

@interface Delegate : NSObject <NSCollectionViewDelegate>
{
@public
  NSIndexPath *refused;
  NSSet *shouldSelect;
  NSSet *didSelect;
  NSSet *shouldDeselect;
  NSSet *didDeselect;
}
@end
@implementation Delegate
- (void) dealloc
{
  RELEASE(shouldSelect);
  RELEASE(didSelect);
  RELEASE(shouldDeselect);
  RELEASE(didDeselect);
  [super dealloc];
}
- (void) reset
{
  DESTROY(shouldSelect);
  DESTROY(didSelect);
  DESTROY(shouldDeselect);
  DESTROY(didDeselect);
}
- (NSSet *) collectionView: (NSCollectionView *)cv
shouldSelectItemsAtIndexPaths: (NSSet *)indexPaths
{
  NSMutableSet *approved = [NSMutableSet setWithSet: indexPaths];

  ASSIGN(shouldSelect, indexPaths);
  if (refused != nil)
    {
      [approved removeObject: refused];
    }
  return approved;
}
- (void) collectionView: (NSCollectionView *)cv
didSelectItemsAtIndexPaths: (NSSet *)indexPaths
{
  ASSIGN(didSelect, indexPaths);
}
- (NSSet *) collectionView: (NSCollectionView *)cv
shouldDeselectItemsAtIndexPaths: (NSSet *)indexPaths
{
  NSMutableSet *approved = [NSMutableSet setWithSet: indexPaths];

  ASSIGN(shouldDeselect, indexPaths);
  if (refused != nil)
    {
      [approved removeObject: refused];
    }
  return approved;
}
- (void) collectionView: (NSCollectionView *)cv
didDeselectItemsAtIndexPaths: (NSSet *)indexPaths
{
  ASSIGN(didDeselect, indexPaths);
}
@end

int
main(int argc, char **argv)
{
  NSAutoreleasePool *pool = [NSAutoreleasePool new];
  NSCollectionView *cv;
  Delegate *delegate;
  NSIndexPath *p0 = [NSIndexPath indexPathForItem: 0 inSection: 0];
  NSIndexPath *p1 = [NSIndexPath indexPathForItem: 1 inSection: 0];
  NSIndexPath *p2 = [NSIndexPath indexPathForItem: 2 inSection: 0];
  NSSet *s01 = [NSSet setWithObjects: p0, p1, nil];
  NSSet *s12 = [NSSet setWithObjects: p1, p2, nil];

  START_SET("NSCollectionView selection delegate")

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

  delegate = AUTORELEASE([Delegate new]);
  cv = AUTORELEASE([[NSCollectionView alloc]
    initWithFrame: NSMakeRect(0, 0, 400, 300)]);
  [cv setSelectable: YES];
  [cv setAllowsMultipleSelection: YES];
  [cv setDelegate: delegate];

  [cv setSelectionIndexPaths: s01];
  PASS([delegate->shouldSelect isEqual: s01],
    "the delegate is asked about the paths to select");
  PASS([delegate->didSelect isEqual: s01],
    "the delegate is told about the selected paths");
  PASS(delegate->shouldDeselect == nil && delegate->didDeselect == nil,
    "the delegate is not asked to deselect when nothing is deselected");

  [delegate reset];
  [cv setSelectionIndexPaths: s12];
  PASS([delegate->shouldSelect isEqual: [NSSet setWithObject: p2]],
    "only the newly selected path is proposed for selection");
  PASS([delegate->shouldDeselect isEqual: [NSSet setWithObject: p0]],
    "the path dropped from the selection is proposed for deselection");
  PASS([delegate->didDeselect isEqual: [NSSet setWithObject: p0]],
    "the delegate is told about the deselected path");
  PASS([[cv selectionIndexPaths] isEqual: s12],
    "the selection is the new set");

  [delegate reset];
  delegate->refused = p0;
  [cv setSelectionIndexPaths: s01];
  PASS([[cv selectionIndexPaths] isEqual: [NSSet setWithObject: p1]],
    "a path the delegate refuses to select is not selected");
  PASS(delegate->didSelect == nil,
    "the delegate is not told about a refused selection");
  PASS([[cv selectionIndexes] isEqual: [NSIndexSet indexSetWithIndex: 1]],
    "the selection indexes follow the approved selection");

  [delegate reset];
  delegate->refused = p1;
  [cv deselectItemsAtIndexPaths: [NSSet setWithObject: p1]];
  PASS([[cv selectionIndexPaths] isEqual: [NSSet setWithObject: p1]],
    "a path the delegate refuses to deselect stays selected");
  PASS(delegate->didDeselect == nil,
    "the delegate is not told about a refused deselection");

  END_SET("NSCollectionView selection delegate")

  [pool release];
  return 0;
}
