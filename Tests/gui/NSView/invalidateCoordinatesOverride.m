/* A subclass that overrides -_invalidateCoordinates must learn when an
 * ancestor moves, resizes or scrolls.
 *
 * NSView invalidates a view's cached coordinates, and those of its
 * descendants, when its frame or bounds change.  The recursion into the
 * descendants used to call NSView's own implementation through a cached
 * IMP, so a subclass override ran only when the view itself changed, never
 * when an ancestor did.  NSOpenGLView overrides it to move its native child
 * window; without the message it stays behind when a parent moves or a
 * scroll view scrolls.  This guards the recursion sending the message.
 *
 * Needs no window or display: coordinates are computed and invalidated
 * without one.
 */
#import "Testing.h"
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSException.h>
#import <Foundation/NSGeometry.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSView.h>

@interface NSView (InvalidateCoordinatesOverride)
- (void) _invalidateCoordinates;
@end

@interface InvalidationRecorder : NSView
{
@public
  int invalidations;
}
@end

@implementation InvalidationRecorder
- (void) _invalidateCoordinates
{
  invalidations++;
  [super _invalidateCoordinates];
}
@end

/* Converting a point computes the view's cached coordinates (and its
   ancestors'), which is what the invalidation has to clear.  */
static void
validate(NSView *view)
{
  (void)[view convertPoint: NSMakePoint(1, 1) toView: nil];
}

int
main(int argc, char **argv)
{
  CREATE_AUTORELEASE_POOL(arp);
  NSView *grandparent, *parent;
  InvalidationRecorder *child, *grandchild;

  START_SET("NSView -_invalidateCoordinates reaches subclass overrides")

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

  grandparent = AUTORELEASE([[NSView alloc]
    initWithFrame: NSMakeRect(0, 0, 400, 400)]);
  parent = AUTORELEASE([[NSView alloc]
    initWithFrame: NSMakeRect(10, 10, 300, 300)]);
  child = AUTORELEASE([[InvalidationRecorder alloc]
    initWithFrame: NSMakeRect(20, 20, 100, 100)]);
  grandchild = AUTORELEASE([[InvalidationRecorder alloc]
    initWithFrame: NSMakeRect(5, 5, 50, 50)]);
  [grandparent addSubview: parent];
  [parent addSubview: child];
  [child addSubview: grandchild];

  validate(grandchild);
  child->invalidations = 0;
  grandchild->invalidations = 0;
  [parent setFrameOrigin: NSMakePoint(30, 40)];
  PASS(child->invalidations > 0,
    "moving the parent sends -_invalidateCoordinates to the subclass child");
  PASS(grandchild->invalidations > 0,
    "and to the subclass grandchild");

  validate(grandchild);
  child->invalidations = 0;
  grandchild->invalidations = 0;
  [grandparent setFrameOrigin: NSMakePoint(7, 9)];
  PASS(child->invalidations > 0 && grandchild->invalidations > 0,
    "moving a more distant ancestor reaches them too");

  validate(grandchild);
  child->invalidations = 0;
  [parent setFrameSize: NSMakeSize(250, 260)];
  PASS(child->invalidations > 0,
    "resizing the parent reaches the subclass child");

  /* What a scroll view's clip view does when it scrolls.  */
  validate(grandchild);
  child->invalidations = 0;
  grandchild->invalidations = 0;
  [parent setBoundsOrigin: NSMakePoint(0, 25)];
  PASS(child->invalidations > 0 && grandchild->invalidations > 0,
    "changing the parent's bounds origin (scrolling) reaches them");

  /* The cached coordinates are still right after the move: the override
     must not stop the invalidation itself.  */
  validate(grandchild);
  [parent setFrameOrigin: NSMakePoint(0, 0)];
  [parent setBoundsOrigin: NSMakePoint(0, 0)];
  [grandparent setFrameOrigin: NSMakePoint(0, 0)];
  PASS(NSEqualPoints([grandchild convertPoint: NSMakePoint(0, 0)
                                       toView: grandparent],
                     NSMakePoint(25, 25)),
    "the subclass's converted coordinates follow its ancestors");

  END_SET("NSView -_invalidateCoordinates reaches subclass overrides")

  DESTROY(arp);
  return 0;
}
